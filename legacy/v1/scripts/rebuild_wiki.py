#!/usr/bin/env python3
"""Rebuild the Quartz wiki from graphify-out/graph.json.

Fixes the issues that made the previous wiki unreadable:
  - Use god-node labels (already human-readable) as page titles instead of techy filenames
  - Drop stub communities (<3 nodes) so the index isn't 126 lines of dead links
  - Strip absolute /Users/... paths to repo-relative paths
  - Dedupe wikilinks so [[Page]] resolves unambiguously
  - Render edges grouped by relation and confidence so connections are scannable
"""
from __future__ import annotations

import json
import re
import shutil
from collections import Counter, defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
GRAPH = REPO / "graphify-out" / "graph.json"
# Canonical Obsidian-style vault. Sub-agents navigate this as markdown
# (per CLAUDE.md: "use graphify-out/wiki/index.md as the navigation entrypoint").
OUT = REPO / "graphify-out" / "wiki"
MIN_COMMUNITY_SIZE = 3
MAX_NODES_LISTED = 24  # cap "Key Concepts" so a 100-node page isn't a wall of bullets


EXT_RE = re.compile(r"\.(ts|tsx|js|jsx|mjs|cjs|py|md|mdx|json|toml|yaml|yml|css|scss|html)$", re.IGNORECASE)
SPECIAL = {
    "cn": "Class Name Helper",
    "page": "Page Component",
    "layout": "Layout Component",
    "route": "API Route",
    "types": "Type Definitions",
    "index": "Index",
    "wizard": "Wizard",
    "shell": "Shell",
    "nav": "Navigation",
    "agent": "Agent",
    "config": "Configuration",
    "errors": "Error Handlers",
    "main": "Main Module",
    "utils": "Utilities",
    "helpers": "Helpers",
}


def _titlecase(s: str) -> str:
    s = s.replace("_", " ").replace("-", " ").strip()
    if not s:
        return s
    return " ".join(w if w.isupper() else w[:1].upper() + w[1:] for w in s.split())


def humanise_label(label: str, src: str | None) -> str:
    """Map techy labels (cn.ts, page.tsx, "Follow-Up Pilot agent.md") to readable titles."""
    if not label:
        return "Untitled"
    raw = label.strip()

    # Strip any trailing file extension from the label, even if there's text before it
    # e.g. "Follow-Up Pilot agent.md" -> "Follow-Up Pilot agent"
    cleaned = EXT_RE.sub("", raw).strip()
    # Also handle "generate-iconsmjs" pattern (extension already mangled into stem)
    cleaned = re.sub(r"(mjs|cjs|tsx|jsx|tsx|js|ts)$", "", cleaned).strip() if cleaned.endswith(("mjs", "cjs")) else cleaned

    # If after cleaning the label is JUST a filename-stem (no spaces), apply special-case map
    is_pure_stem = bool(re.fullmatch(r"[\w.-]+", cleaned))
    if is_pure_stem:
        stem = cleaned
        ctx = ""
        if src:
            parts = src.replace("\\", "/").split("/")
            stem_idx = next((i for i, p in enumerate(parts) if p.startswith(stem)), -1)
            if stem_idx > 0:
                parent = parts[stem_idx - 1]
                if parent and parent != stem:
                    ctx = parent
        readable = SPECIAL.get(stem.lower(), _titlecase(stem))
        return f"{readable} ({ctx})" if ctx else readable

    # Multi-word label with extension previously stripped: just titlecase it lightly
    return cleaned


def slugify(s: str) -> str:
    s = re.sub(r"[^\w\s-]", "", s).strip().lower()
    s = re.sub(r"[\s_-]+", "-", s)
    return s or "untitled"


def relpath(p: str | None) -> str | None:
    if not p:
        return None
    repo_str = str(REPO)
    if p.startswith(repo_str):
        return p[len(repo_str):].lstrip("/")
    return p


def main() -> None:
    g = json.loads(GRAPH.read_text())
    nodes = g["nodes"]
    links = g["links"]
    hyperedges = g.get("hyperedges", [])

    by_id: dict[str, dict] = {n["id"]: n for n in nodes}
    deg: Counter[str] = Counter()
    for l in links:
        deg[l["source"]] += 1
        deg[l["target"]] += 1

    # Build community index
    comm_nodes: dict[int, list[dict]] = defaultdict(list)
    for n in nodes:
        comm_nodes[n.get("community", -1)].append(n)

    # First pass: build a lookup from node id → community title, so that when we
    # render "Key concepts" we can wikilink any concept that is itself a cluster anchor.
    used_titles: set[str] = set()
    comm_meta: dict[int, dict] = {}
    # Sort by size desc so the biggest community gets first claim on a popular title
    for c, nlist in sorted(comm_nodes.items(), key=lambda x: -len(x[1])):
        if len(nlist) < MIN_COMMUNITY_SIZE:
            continue
        god = max(nlist, key=lambda x: deg.get(x["id"], 0))
        base_title = humanise_label(god.get("label") or god.get("norm_label") or god["id"], god.get("source_file"))
        title = base_title
        n = 2
        while title in used_titles:
            title = f"{base_title} ({n})"
            n += 1
        used_titles.add(title)
        comm_meta[c] = {
            "title": title,
            "slug": slugify(title),
            "size": len(nlist),
            "god": god,
            "nodes": nlist,
        }

    # Edges scoped per community: link is "internal" if both endpoints are in the same kept community
    # Track outgoing community-to-community edges for cross-references
    cross_edges: dict[int, dict[int, int]] = defaultdict(lambda: defaultdict(int))
    internal_edges: dict[int, list[dict]] = defaultdict(list)
    for l in links:
        s_id, t_id = l["source"], l["target"]
        s_n, t_n = by_id.get(s_id), by_id.get(t_id)
        if not s_n or not t_n:
            continue
        sc, tc = s_n.get("community", -1), t_n.get("community", -1)
        if sc not in comm_meta and tc not in comm_meta:
            continue
        if sc == tc and sc in comm_meta:
            internal_edges[sc].append(l)
        elif sc in comm_meta and tc in comm_meta and sc != tc:
            cross_edges[sc][tc] += 1
            cross_edges[tc][sc] += 1

    # Wipe and rewrite content
    if OUT.exists():
        for f in OUT.glob("*.md"):
            f.unlink()
    OUT.mkdir(parents=True, exist_ok=True)

    # Build a label→title resolver: if a node's humanised label matches a cluster
    # title, render it as a wikilink in "Key concepts" so the global graph picks
    # up the edge.
    title_set = {m["title"] for m in comm_meta.values()}

    # Detect "thematic" cross-links beyond what the graphify edges captured.
    # Louvain clusters tightly, so most edges are intra-cluster. We boost
    # density by linking clusters that share a substantive folder or keyword.
    def folder_key(src: str | None) -> str | None:
        if not src:
            return None
        rel = relpath(src) or src
        parts = rel.split("/")
        # Group by first-two path segments (e.g. "docs/phase-2-agent-suite")
        return "/".join(parts[:2]) if len(parts) >= 2 else parts[0]

    folder_to_comms: dict[str, set[int]] = defaultdict(set)
    for c, m in comm_meta.items():
        for n in m["nodes"]:
            fk = folder_key(n.get("source_file"))
            if fk:
                folder_to_comms[fk].add(c)
    # For each cluster, the "siblings" are other clusters that share its dominant folder
    sibling_links: dict[int, list[int]] = defaultdict(list)
    for c, m in comm_meta.items():
        folder_count: Counter[str] = Counter()
        for n in m["nodes"]:
            fk = folder_key(n.get("source_file"))
            if fk:
                folder_count[fk] += 1
        if not folder_count:
            continue
        top_folder, _ = folder_count.most_common(1)[0]
        siblings = folder_to_comms[top_folder] - {c}
        # Cap at 6 siblings to avoid noise
        sibling_links[c] = list(siblings)[:6]

    written = 0
    for c, meta in comm_meta.items():
        title = meta["title"]
        slug = meta["slug"]
        nlist = sorted(meta["nodes"], key=lambda n: -deg.get(n["id"], 0))
        god = meta["god"]
        body: list[str] = []

        # Frontmatter — title is the human title, no techy filename
        body.append("---")
        body.append(f'title: "{title}"')
        body.append(f"community: {c}")
        body.append(f"size: {meta['size']}")
        body.append("---")
        body.append("")
        body.append(f"# {title}")
        body.append("")
        body.append(f"> Cluster of **{meta['size']} concepts**. Anchor: `{god.get('label', '?')}`.")
        body.append("")

        # Key concepts (top by degree)
        body.append("## Key concepts")
        body.append("")
        listed = nlist[:MAX_NODES_LISTED]
        for n in listed:
            node_label = humanise_label(n.get("label") or n["id"], n.get("source_file"))
            d = deg.get(n["id"], 0)
            file_loc = relpath(n.get("source_file"))
            # If this concept is itself a cluster, link to it so the graph view
            # picks up the edge between this cluster and the other.
            label_md = f"[[{node_label}]]" if node_label in title_set and node_label != title else f"**{node_label}**"
            line = f"- {label_md}"
            if d:
                line += f" — {d} connections"
            if file_loc:
                line += f" · `{file_loc}`"
            body.append(line)
        if len(nlist) > MAX_NODES_LISTED:
            body.append(f"- *(+{len(nlist) - MAX_NODES_LISTED} more)*")
        body.append("")

        # Cross-community links — every connection becomes a [[wikilink]] so the
        # global graph view renders dense, multi-hop relationships (the supernova look)
        crosses = sorted(cross_edges[c].items(), key=lambda x: -x[1])
        if crosses:
            body.append("## Connected clusters")
            body.append("")
            for other_c, weight in crosses:
                if other_c not in comm_meta:
                    continue
                other_title = comm_meta[other_c]["title"]
                strength = "●●●" if weight >= 5 else "●●" if weight >= 2 else "●"
                body.append(f"- {strength} [[{other_title}]] — {weight} link{'s' if weight != 1 else ''}")
            body.append("")

        # Internal relations summary
        rels = Counter(e["relation"] for e in internal_edges[c])
        if rels:
            body.append("## Internal relations")
            body.append("")
            for rel, count in rels.most_common():
                body.append(f"- `{rel}`: {count}")
            body.append("")

        # Sibling clusters — shared codebase area, even without a direct edge
        sibs = [s for s in sibling_links.get(c, []) if s in comm_meta]
        if sibs:
            body.append("## Same area of the codebase")
            body.append("")
            for s in sibs:
                body.append(f"- [[{comm_meta[s]['title']}]]")
            body.append("")

        # Source files (relative paths only)
        srcs = sorted({relpath(n.get("source_file")) for n in nlist if n.get("source_file")})
        srcs = [s for s in srcs if s]
        if srcs:
            body.append("## Source files")
            body.append("")
            for s in srcs[:20]:
                body.append(f"- `{s}`")
            if len(srcs) > 20:
                body.append(f"- *(+{len(srcs) - 20} more)*")
            body.append("")

        body.append("---")
        body.append("")
        body.append("*[[Index|← Back to map]]*")
        body.append("")

        (OUT / f"{slug}.md").write_text("\n".join(body))
        written += 1

    # Index page — only the surviving communities, sorted by size
    sorted_comms = sorted(comm_meta.values(), key=lambda m: -m["size"])
    idx: list[str] = []
    idx.append("---")
    idx.append('title: "Intel Force OS · Brain"')
    idx.append("---")
    idx.append("")
    idx.append("# The Brain")
    idx.append("")
    idx.append(
        f"> **{len(nodes)} concepts** across **{len(comm_meta)} clusters**, with **{len(links)} relationships** between them."
    )
    idx.append("")
    idx.append("Click any cluster to dive in. The graph in the corner is alive — drag, zoom, hover.")
    idx.append("")
    idx.append("## Major clusters")
    idx.append("")
    for m in sorted_comms:
        idx.append(f"- [[{m['title']}]] — {m['size']} concepts")
    idx.append("")
    pruned = sum(1 for c, ns in comm_nodes.items() if len(ns) < MIN_COMMUNITY_SIZE)
    if pruned:
        idx.append(f"*{pruned} small clusters (<{MIN_COMMUNITY_SIZE} concepts) hidden from this index. They still appear in the graph.*")
    idx.append("")
    (OUT / "index.md").write_text("\n".join(idx))

    print(f"Wrote {written} cluster pages + index.md")
    print(f"Pruned {pruned} stub communities")
    print(f"Total nodes covered: {sum(m['size'] for m in comm_meta.values())} / {len(nodes)}")


if __name__ == "__main__":
    main()
