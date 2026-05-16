# cortextOS KB surface — investigation (paused)

**Date:** 2026-05-16 (Week 0, Day 1)
**Audited SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383` (`packages/harness/cortextos/` reference pin)
**Status:** Investigation **paused**. One of four files read. Resumes after `docs/architecture/second-brain-design.md` lands.
**Surfaced by:** ADR-002 (in-progress, since superseded by the reframe — see "Why this document exists" below).

---

## Why this document exists

Day-1 audit of cortextOS Primitive 3 (`docs/architecture/cortexos-primitive-status.md`) surfaced that master brief §3.4 names four shadow files (`kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`) that **do not exist** at the verified SHA. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`.

Drafting ADR-002 began with the plan to read all four real files and pick one of three outcomes (full shadow / mixed shadow + new wrappers / abandon shadow). After reading **only `kb-setup.sh`**, the substrate of cortextOS's KB became clear, and that substrate is incompatible with the IFOS wiki data model in master brief §5. The ADR's scope is too narrow to absorb that finding — it would be designing the second brain inside an architectural decision record, on the side of an audit.

This document holds the partial investigation so:

1. The work already done is not lost.
2. The remaining reads (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`) are explicitly deferred until the second-brain design exists, so the reads can be done against a concrete IFOS data model rather than reverse-engineered.
3. Future sessions reading this know to consult `docs/architecture/second-brain-design.md` first, then resume here.

---

## What is cortextOS's KB substrate

From `kb-setup.sh` alone (other files unread), the substrate is named explicitly in `bus/kb-setup.sh:38, 49, 71, 82-95`:

- **Engine:** `mmrag.py` — a Python multimodal-RAG library at `$FRAMEWORK_ROOT/knowledge-base/scripts/mmrag.py`. Not a cortextOS-native module; an external Python dependency installed into a venv at `$FRAMEWORK_ROOT/knowledge-base/venv/`.
- **Vector DB:** ChromaDB. Per-instance per-org index at `$HOME/.cortextos/$INSTANCE_ID/orgs/$ORG/knowledge-base/chromadb/`.
- **Embedding provider:** Gemini. `embedding_model: "gemini-embedding-2-preview"` with `embedding_dimensions: 3072`. Migration logic at line 100-104 rewrites stale `text-embedding-004` references (the previous Gemini model, shut down 2026-01-14).
- **Chat model field:** `gemini_model: "gemini-2.5-flash"` — exists in config but unclear from setup alone whether mmrag uses it for query rewriting, summarisation, or just metadata.
- **Chunking:** `text_chunk_size: 1000` characters with `text_chunk_overlap: 200`. This is the load-bearing fact below.
- **Similarity threshold:** `similarity_threshold: 0.5` — cosine similarity cut-off.
- **Default collection:** `"shared"` — there is a per-collection logical scope above the per-org physical scope. Semantics of "collection" remain unread until `kb-collections.sh` is opened.
- **Per-instance isolation:** the KB root path includes `$CTX_INSTANCE_ID`, so IFOS's `ifos-v2` install and the personal install at `default` have **separate** KB indexes by construction. This is already correct against the master brief §3.1 submodule boundary.
- **Required secret:** `GEMINI_API_KEY` in `orgs/$ORG/secrets.env` (referenced in kb-setup's "next steps" output at line 118).

---

## Contract of `kb-setup.sh`

Captured verbatim from the Day-1 audit (`packages/harness/cortextos/bus/kb-setup.sh`, full file 121 lines).

- **CLI args:** `[--org ORG] [--instance ID]`. `--org` (or `CTX_ORG` env) is required; `--instance` defaults to `default`. Other env: `CTX_FRAMEWORK_ROOT`, `GEMINI_API_KEY`.
- **What it does to disk / state:**
  - Creates the per-instance per-org KB root at `$HOME/.cortextos/$INSTANCE_ID/orgs/$ORG/knowledge-base/` (line 35).
  - Makes a `chromadb/` subdirectory under it (line 36, 49).
  - Provisions a Python venv at `$FRAMEWORK_ROOT/knowledge-base/venv/` if absent (line 52-59). Cross-platform venv-bin resolution at line 62-66 (Windows `Scripts/`, Unix `bin/`).
  - Installs `$FRAMEWORK_ROOT/knowledge-base/scripts/requirements.txt` into the venv (line 71).
  - Writes a default `config.json` at `$KB_ROOT/config.json` if absent (line 82-95) with the eight-key schema documented above.
  - Migrates stale `text-embedding-004` references to `gemini-embedding-001` if found (line 100-104).
  - Test-imports `chromadb` and `google.genai` from the venv (line 108-112) — fails loudly if either is missing.
- **What it writes to stdout / exit code:**
  - Human-readable `[OK]` / `[MIGRATED]` lines per step.
  - Exit 0 on success.
  - Exit 1 if `--org` missing (line 30-32) or `mmrag.py` missing (line 75-78).
  - Pip / Python failures terminate via `set -euo pipefail` at line 8.
- **What it reads:**
  - `CTX_ORG / CTX_INSTANCE_ID / CTX_FRAMEWORK_ROOT` env.
  - `$FRAMEWORK_ROOT/.env` if present (line 14-15, allexport sourced).
  - `$FRAMEWORK_ROOT/knowledge-base/scripts/requirements.txt`.
  - `$FRAMEWORK_ROOT/knowledge-base/scripts/mmrag.py` (presence check at line 75-78, not parsed by the script itself).
- **Calls no external services.** The Gemini key is just persisted into workspace `.env`; no Gemini API call happens at setup time.
- **No Node dispatch.** Unlike most other `bus/*.sh` shimsthat exec into `node dist/cli.js bus <command>` (e.g. `bus/send-message.sh:22`), `kb-setup.sh` is pure bash doing real work. There is no TypeScript handler to read for this script.

---

## Files NOT yet read

Marked here so the next session knows the gap:

| File | Read? | Why deferred |
|---|---|---|
| `bus/kb-collections.sh` | **No** | Investigation paused after `kb-setup.sh` revealed substrate mismatch. Read against second-brain design once it lands. |
| `bus/kb-ingest.sh` | **No** | Same. |
| `bus/kb-query.sh` | **No** | Same. |
| `knowledge-base/scripts/mmrag.py` (the underlying Python library) | **No** | The shell wrappers are the contract surface; mmrag internals are not on our critical path until we know which (if any) we plan to call. |

---

## Central finding

**cortextOS's KB is a chunked-vector RAG store; the IFOS wiki in master brief §5 is an entity-document store. These data models do not compose without an adapter layer, and the adapter layer is large enough to be a design decision rather than a shadow-wrapper detail.**

Specifics:

- **cortextOS KB unit of storage:** a 1000-character chunk of text with 200-char overlap, embedded into a 3072-dimensional Gemini vector, indexed in ChromaDB, retrieved by cosine similarity ≥ 0.5. The natural read pattern is "give me text passages relevant to this query".
- **IFOS wiki unit of storage:** one markdown file per entity (Candidate, Client, Brief, Placement…) with structured YAML frontmatter (`id / entity_type / tenant_id / created_at / updated_at / provenance / importance_score / linked_entities`) and `[[wiki-link]]` references in body — per master brief §5.2 example at lines 357-369. The natural read pattern is "give me the canonical page for this entity, plus its backlinks".
- **What cortextOS's substrate cannot do natively (from `kb-setup.sh` alone):**
  - It has no concept of entity identity. Two ingests of the same logical entity create two unrelated chunk sets.
  - It has no concept of frontmatter or structured fields. Frontmatter would be ingested as text and chunked.
  - It has no concept of wiki-links between documents. `[[Candidate: Sarah Bowen]]` is just text.
  - It has no update-in-place. Re-ingesting a changed document creates new chunks; the old chunks remain unless explicitly deleted (mechanism unknown — needs `kb-ingest.sh` read).
  - It has no entity-type / tenant scoping inside a collection. Scoping is by ChromaDB collection name only (semantics still unread).
- **What cortextOS's substrate could plausibly serve in IFOS:**
  - **Read-only semantic search over wiki content** as one retrieval path inside a larger query — e.g., for the "find me a page that mentions X" use case, after the entity-document store has already given the canonical entity pages. mmrag could be a secondary, not primary, index.
  - **Indexing of ingested raw email/transcript chunks** (master brief §5.1 `raw/` directory tree). The chunked-vector model fits the "raw inbox-emails / calls / briefs" surface well; it only stops fitting at the `compiled/` entity-document boundary.
- **What this means for §3.4:** the master brief calls the seam between cortextOS and IFOS "the four `bus/kb-*.sh` shadow points." That framing assumed the same data model on both sides of the seam. With the substrate now known, the seam is not a four-file shadow but a much smaller boundary — to be defined in the second-brain design.

---

## What happens next

1. **Founder confirms Action 1** (this document).
2. **Claude writes `docs/architecture/second-brain-design.md`** answering:
   - Q1: What does cortextOS itself depend on its KB for? (Analyst theta-wave skill, autoresearch, etc. — read template skills.)
   - Q2: What does the IFOS second brain need to do? (Entity types, operations, storage substrate, index strategy, concurrency, hot/cold paths.)
   - Q3: How do agents call the second brain? (Option α shell wrappers / β MCP server / γ direct library — recommendation with rationale.)
3. **Claude writes `ADR-002` against the design.** The decision is binding; the design is the evidence.
4. **At that point, the remaining three `kb-*.sh` reads can resume** if the design recommends any interaction with cortextOS's KB (e.g. for the raw-ingest secondary-index use case above). Otherwise they stay deferred and we close the seam on the IFOS side only.

End of investigation hold-point.
