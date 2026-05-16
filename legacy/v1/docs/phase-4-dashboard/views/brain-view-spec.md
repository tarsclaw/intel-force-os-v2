# Brain View Specification

**Read-only browser into the tenant's vault. Filesystem tree + semantic search + file preview, all served from the live git-backed vault.**

> **Audience:** the engineer implementing CC16 (Brain view) and the operator/tenant using it.
>
> **Status:** v1.0. Lives at `/t/[tenantSlug]/brain`.
>
> **Why "Brain":** it's the tenant's institutional knowledge, indexed and searchable. The agents write to it; the humans read from it. Naming the view matches the mental model.

---

## 1. Purpose

The vault is where every agent's output lives. Proposals, content drafts, onboarding packets, SOPs, reports — all files in the git-backed vault. The Brain view lets a tenant:

1. Browse the vault structure (directories, files)
2. Preview any file in the browser (no download required)
3. Search semantically across all vault content (not just filename match)
4. See recent changes (what agents have written lately)
5. Click through to an output file from an Operations/Activity row

Read-only by design. All editing happens in Obsidian against the git-synced clone on the tenant's own machine. The dashboard is the shared-access layer.

---

## 2. Why not just let them open GitHub?

The vault IS a GitHub repo. Couldn't we just give tenants a deploy key and let them browse GitHub directly?

No:
- GitHub UI is terrible for reading markdown with Obsidian-style `[[wikilinks]]`
- Links to agent outputs from Operations would be external jumps to GitHub
- Tenants without GitHub accounts would need one
- Audit trail is split across two systems
- Search across the vault from GitHub requires indexing by GitHub's code search — doesn't support semantic search
- Tenants have no business knowing their vault is on GitHub (it's an implementation detail)

So: the dashboard renders vault content natively. Simpler for tenants, auditable for us, semantic-search-capable.

---

## 3. Layout

Desktop (`≥ 1024px`):

```
┌─────────────────────────────────────────────────────────────────────┐
│  Tenant chrome                                                       │
├──────────────┬──────────────────────────────────────────────────────┤
│              │                                                      │
│  SIDEBAR     │  MAIN                                                │
│              │                                                      │
│  [🔍 search] │  ─ breadcrumb: vault > clients > meadowlane >       │
│              │                                                      │
│  📁 brand    │  📄 2026-05-15-may-report.md                         │
│  📁 clients  │                                                      │
│    📁 meadow │  ─────────────────────────────────────────────      │
│      📁 prop │  ---                                                 │
│      📁 cont │  type: monthly-report                                │
│    📁 willow │  client: Meadow Lane Dental                          │
│  📁 content  │  period_start: 2026-05-02                            │
│    📁 long   │  ...                                                 │
│  📁 sops     │  ---                                                 │
│  📁 reports  │                                                      │
│  📁 daily    │  # May 2026 — Meadow Lane Dental                     │
│              │                                                      │
│              │  (rendered markdown)                                 │
│              │                                                      │
│  [recent ↓]  │                                                      │
│  May 15 ...  │  ──────────────────────────────                     │
│  May 14 ...  │  Metadata: size 4KB, modified 2h ago,               │
│  May 13 ...  │  drafted by reporting-engine@1.0.0                  │
│              │                                                      │
└──────────────┴──────────────────────────────────────────────────────┘
```

Mobile: sidebar collapses; search is primary. File preview is full-screen when opened.

---

## 4. Sidebar — file tree

### 4.1 Structure

Hierarchical tree starting at vault root. Collapsed by default except the path to the currently-viewed file.

### 4.2 Entry display

| Type | Rendering |
|---|---|
| Directory | `📁` + name + count of files inside (e.g., `clients (3)`) |
| Markdown file | `📄` + filename (without `.md`) |
| JSON file | `{ }` + filename |
| YAML | `⚙️` + filename |
| Other | Generic doc icon + filename |

Hidden files (starting with `.`) are not shown. `.gitignore`, `.obsidian/`, etc. filtered out.

### 4.3 Actions

- Click a directory → expands/collapses inline
- Click a file → loads in main pane (no navigation, just state change — fast)
- Right-click menu: "Copy path", "Copy content", "Download"

### 4.4 Recent files

Below the tree, a "Recent" section showing the 10 most recently modified files across the vault. Useful when you know "something was updated today but I forget where."

### 4.5 Size

Browser-rendered tree works well up to ~1000 files per tenant. Beyond that (rare), the tree becomes lazy-loaded (directory expansion triggers a fetch). We build for both from day one.

---

## 5. Search

### 5.1 Search bar

Top of sidebar. Always visible. Placeholder: "Search the vault..."

On focus, shows recent searches (stored in localStorage).

### 5.2 Search types

Two modes, toggle-able:

**Mode A — Exact / filename**
- Filename and path matching
- Fast (purely Postgres against path index)
- Results: file list with path and last modified

**Mode B — Semantic** (default)
- Full-content semantic search via `vault-search` CLI (Cohere embeddings + pgvector)
- Slightly slower (~200ms p95)
- Results: chunk matches with context snippet + file link

Toggle between modes with a small icon in the search bar. Default to semantic.

### 5.3 Filters

Below the search bar:
- Tag filter (dropdown populated from tags the vault actually uses)
- File type filter (all / markdown / json / yaml / other)
- Modified since (dropdown: any / today / last 7 days / last 30 days)
- Author (drafted_by frontmatter field — if populated — dropdown of agents + "human edit")

### 5.4 Results

List in the main pane (not sidebar). Each result:

```
┌───────────────────────────────────────────────────────────┐
│  📄 2026-05-15-may-report.md                              │
│  clients/meadowlane-dental/reports/                       │
│                                                           │
│  ...performance was up 11 percentage points month over    │
│  month, with **conversion** to consultations reaching     │
│  43.6% compared to 32.5% in April...                      │
│                                                           │
│  Tags: monthly-report, reporting-engine                   │
│  Modified: 2026-06-01  Similarity: 82%                    │
└───────────────────────────────────────────────────────────┘
```

Semantic-mode results show the relevant chunk (not the whole file) with matched terms highlighted.

### 5.5 No results

Friendly empty state: "No results for `{query}`. Try semantic search (toggle above) if you're looking for a concept rather than exact wording."

---

## 6. File preview — main pane

### 6.1 Markdown rendering

Files ending in `.md` are rendered with markdoc (a safe, token-based renderer that doesn't eval user-generated content).

Supports:
- Standard markdown (headings, lists, code blocks, tables, etc.)
- YAML frontmatter — rendered as a collapsible metadata block at top
- Mermaid diagrams — rendered client-side via mermaid.js
- Obsidian-style `[[wikilinks]]` — converted to `<a>` tags that navigate to the linked file in the Brain view
- Task lists (`- [ ] task`, `- [x] done`)
- Footnotes

Not supported:
- HTML passthrough (security)
- Arbitrary embeds

### 6.2 Code blocks

Rendered with Shiki for syntax highlighting. Theme matches the dashboard (dark + emerald accent).

### 6.3 JSON / YAML files

Rendered with Shiki as well, in their native syntax. Pretty-printed.

### 6.4 Other file types

- Images (jpg, png, webp, svg): rendered inline
- PDFs: iframe-embedded PDF viewer
- Office files (docx, xlsx): preview unavailable — show download button

### 6.5 Large files

Files > 1MB: show a warning + download button instead of rendering. "This file is 2.3 MB. Preview may be slow. [Render anyway] [Download]".

### 6.6 Metadata footer

Below every previewed file:

```
─────────────────────────────────────────────
Path: /vault/clients/meadowlane-dental/reports/2026-05-15-may-report.md
Size: 4.2 KB
Modified: 2026-06-01 09:12 (by reporting-engine@1.0.0, git commit abc1234)
Tags: monthly-report, reporting-engine
[Download] [Copy path] [View on GitHub]  (last only visible to platform admins)
```

---

## 7. Breadcrumbs

Top of main pane:

```
vault > clients > meadowlane-dental > reports > 2026-05-15-may-report.md
```

Each segment is clickable — navigates into that directory view (main pane shows directory listing).

---

## 8. Recent changes timeline

Below the preview (or in a dedicated `/brain/recent` sub-route), a vertical timeline of vault changes:

```
Today
  09:12  reporting-engine wrote 2026-05-15-may-report.md
  04:00  librarian updated 2 files (nightly sweep)
Yesterday
  14:23  content-creator wrote 2026-05-14-patient-guide.md
  14:24  repurposer wrote 3 derivatives
  09:00  human edit — brand/voice-profile.md (Priya)
Last week
  ...
```

Each entry clicks through to the file at that version (git-backed, so past versions are accessible).

### 8.1 Comparing versions

Right-click any past entry → "Compare with current". Opens a diff view (side-by-side markdown diff). Useful for auditing what an agent changed vs a human edit.

---

## 9. Data flow

### 9.1 File tree

- On view load, tRPC `vault.listDir({ tenantId, path: '/' })` returns top-level
- Expanding a directory triggers `vault.listDir` with that path
- Cached client-side via React Query; 30s TTL

### 9.2 File content

- Clicking a file triggers `vault.getFile({ tenantId, path })`
- Response includes content + frontmatter + metadata
- No client-side caching for file content (always fetch fresh; files can change mid-session as agents run)

### 9.3 Search

- Search input debounced (300ms)
- tRPC `vault.search({ tenantId, query, tagFilter, topK })` → backend calls the `vault-search` CLI
- Results rendered in main pane; click a result → loads the file

### 9.4 Recent changes

- `vault.recentChanges({ tenantId, limit })` → reads last N git commits for this tenant's repo
- Refreshed every 60s via React Query

---

## 10. Permissions

- `tenant_owner`, `tenant_member`, `tenant_viewer` — full read access to their own tenant's vault
- `platform_admin`, `platform_operator`, `platform_readonly` — full read access to any tenant's vault
- No-one gets write access via the Brain view. Writes happen via:
  - Agent invocations (writing to their tenant container's volume, which git-syncs)
  - Obsidian on the tenant's local machine (also git-synced)

Rate limit: 30 `vault.getFile` requests per minute per user (to prevent accidental DoS by scripted tools).

---

## 11. What about the actual git history / commits?

Platform admins can see the underlying git repo via a "View on GitHub" link on any file. Tenants cannot. They see a simplified version (the recent changes timeline) that doesn't expose GitHub as an implementation detail.

---

## 12. Edge cases

### 12.1 File was deleted

If the tenant navigated to `/brain/vault/clients/old/proposal.md` and the file has been deleted (agent archived it, or human deleted via Obsidian):

- Show: "This file was deleted on 2026-05-20. [View last version] [Go up a level]"
- `View last version` loads the content as it existed in the previous commit

### 12.2 File is being actively written

If the operator opens a file that an agent is currently writing to (rare race condition — file exists but content is partial):

- `vault.getFile` returns what's on disk at read time
- No consistency guarantee; this is unchanged behaviour
- Librarian re-indexes on every nightly sweep, so semantic search catches up

### 12.3 Binary file accidentally rendered

If somehow a binary slips into `/vault/`:
- Content-type detection on the server
- If binary, return metadata + "This file is binary and can't be previewed. [Download]"

### 12.4 Tenant has no vault yet

First-day tenants haven't had any agents run yet. Vault is mostly empty — just brand/ and sops/ templates from the minimal-vault-structure seed.

Empty state: "Your vault is brand new. Once agents run, outputs will appear here. Check back after your first webhook triggers."

---

## 13. Performance

| Target | Metric |
|---|---|
| Tree load (root) | < 200ms |
| Directory expansion | < 150ms |
| File preview | < 400ms for files < 500KB |
| Semantic search response | < 500ms p95 |
| Recent changes load | < 300ms |

Optimisations:
- tRPC `vault.listDir` response cached server-side for 10s
- File content fetched from the tenant container's mounted volume, not from GitHub (faster)
- Semantic search leverages pre-indexed pgvector embeddings (no re-embedding at query time)

---

## 14. Accessibility

- Tree is navigable with arrow keys (up/down, left/right to collapse/expand)
- Focused tree item announced with role + position ("file, 3 of 7")
- Markdown renderings have proper heading hierarchy (H1 is the filename, H2 for frontmatter block, etc.)
- Images require alt text (warning shown if frontmatter's `images: []` array has entries without alt)

---

## 15. Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `⌘/Ctrl + K` | Command palette (global) |
| `⌘/Ctrl + P` | Quick file open (fuzzy search filename) |
| `⌘/Ctrl + Shift + F` | Focus search bar |
| `J` / `K` | Navigate tree |
| `Enter` | Open focused file |
| `⌘/Ctrl + ←` | Go back in navigation history |
| `⌘/Ctrl + →` | Go forward |

Command palette includes "Go to file..." that replaces `⌘P` on smaller viewports.

---

## 16. Implementation checklist (for CC16)

- [ ] Route `/t/[slug]/brain` + `/admin/tenants/[tenantId]/brain`
- [ ] File tree component (shadcn/ui `<Collapsible>` recursively) with lazy loading for large vaults
- [ ] Markdoc renderer with Mermaid + Shiki plugins
- [ ] Wikilink resolver (`[[file]]` → route to `/brain/vault/...` by filename match)
- [ ] Search bar with mode toggle
- [ ] Filter UI (tags, file type, modified, author)
- [ ] `vault.listDir`, `vault.getFile`, `vault.search`, `vault.recentChanges` procedures (already in router spec)
- [ ] Recent changes timeline
- [ ] File metadata footer
- [ ] Deleted file handling (git history lookup)
- [ ] E2E tests: browse tree, preview markdown, search semantically, view recent changes
- [ ] Performance benchmarks against a tenant with 1000 files

---

## 17. What's deferred to v1.1

- **Edit-in-place** (with confirmation + git commit) — not for v1; tenants use Obsidian
- **Cross-tenant vault search** for operators (searching "how did we phrase X for any client") — nice but not critical
- **Pin favourites** — shortcuts to frequently-accessed files
- **Share link** — generate a public link to a specific vault file (for sharing proposals with external parties)
- **Comments** — annotate a file with a comment visible to team members

---

## 18. Related

- `phase-3-platform/services/vault-search-spec.md` — the CLI this view calls
- `api/trpc-router-spec.md` §5.5 (vault procedures)
- `phase-1-poc-stack/platform-specs/minimal-vault-structure.md` — starting structure
- Every Phase 2 agent writes into the vault — the Brain view is how those outputs are seen
