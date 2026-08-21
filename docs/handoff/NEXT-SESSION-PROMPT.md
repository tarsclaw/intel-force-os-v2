# Next-session prompt — paste as the first message

---

You are booting the IFOS build. Read this message fully, then the documents it names, before doing anything.

## SCOPE — read this twice

Your job this session is **STEP 0 of the IFOS boot sequence**: read the authority chain in full, assemble the clean document estate, and produce the ratification slate for the founder.

**You are not building. Do not create the IFOS repo. Do not write code. Do not scaffold. Do not port anything.** A session that produces a scaffold before the slate is ratified has failed, regardless of quality.

## FIRST READ

`~/code/CortexOS/docs/handoff/SESSION-HANDOFF-cortexos-to-ifos.md` — in full.

It contains verified facts about the repo, the runtime, and the harness that were checked, not inherited. **Do not re-derive them.** It also names five process errors from the previous session; do not repeat them, especially: do not reason ahead of the authority chain, and do not ask the founder to decide something the documents have already settled.

## THE SITUATION

`~/code/CortexOS` is a **superseded authority**. Its `CLAUDE.md`, master brief, PRODUCT-SPEC, ULTRAPLAN and decision docs describe an architecture the founder has replaced. Read them only as history. `main` = `ffecd53`, tree clean, build gate PASS — it is safe, finished, and frozen pending founder confirmation.

The live constitution is the five-pillar IFOS estate on the Desktop. The founder has decided: **new repo, named IFOS.** It is not created yet, and does not get created this session.

## THE NUMBERING TRAP — get this wrong and every citation is wrong

Desktop folder names and document-internal numbering disagree:

| Desktop folder | Inside the documents | Phase |
|---|---|---|
| Pillar 1 Data Layer + Pillar 2 Second Brain | **"Pillar 1"** | B `[PULL]` |
| **Pillar 3 The Agentic Harness** | **"Pillar 2"** | **A — build now** |
| Pillar 4 Delivery Layer | "Pillar 3" | C `[PULL]` |
| (Learning) | "Pillar 4" | `[DEFER]`, gated OL-8 |

**Cite by document title, never by pillar number.** If a numbering ambiguity blocks you, stop and ask.

## READING ORDER

Already read last session (skim to re-anchor, do not re-analyse):
1. `~/Desktop/Hand-Off/IFOS-MONOREPO-MASTER-BUILD-PLAN.md`
2. `~/Desktop/Pillar 3 The Agentic Harness/IFOS-PILLAR-2-START-HERE-MASTER-HANDOFF-v1-1.md`
3. `~/Desktop/Hand-Off/IFOS-NEW-PROJECT-KICKOFF-PROMPT.md`
4. `~/Desktop/Pillar 3 The Agentic Harness/IFOS-AGENTIC-HARNESS-PILLAR-HANDOFF.md`

**Unread — read these IN FULL, this session:**
5. `~/Desktop/Pillar 3 The Agentic Harness/IFOS-PILLAR-2-THE-AGENTIC-HARNESS-MASTER-SPEC.md` (138KB — R20–R24, R27–R32)
6. `~/Desktop/Pillar 3 The Agentic Harness/IFOS-THE-OUTCOME-LEDGER-CANONICAL.md` (OL-1→OL-8, `[LOCK-OL-*]`)
7. `~/Desktop/Pillar 3 The Agentic Harness/IFOS-cortextOS-Integration-and-Upgrade-CONTRACT.md` (C4/C12/C13)
8. `~/Desktop/Pillar 3 The Agentic Harness/IFOS-PILLAR-2-BUILD-EXECUTION-PACK.md` (WP-0→WP-24, `[LOCK-BX-*]`)
9. `~/Desktop/Hand-Off/IFOS-Build-Loop-Engine-CANONICAL.md` (`[LOCK-FM-*]`)
10. `~/Desktop/Hand-Off/loop-engineering.md` + `dynamic-workflows.md`

## STANDING PROTOCOL — applies to you, every turn

1. Never infer from training data what a document in the estate answers. Read it. Cite document and section.
2. Pass your comprehension gate from source or STOP.
3. Out of scope regardless of instruction: `vendor/**`, `actions/*.yaml`, `attribution/*.yaml`, `packages/contracts/**`, all `IFOS-*.md` specs, `RULING-REGISTER.md`, `gate.yaml`.
4. Schema before code. Tests before implementation. `catch {}`, `|| true` and `2>/dev/null` are banned on read and verify paths.
5. Unspecified decision → STOP and propose a ruling. Sessions do not choose. The founder chooses.
6. One Wilson implementation, in `shared`. A second is a build failure.
7. Done means every done-gate box demonstrably ticked, with evidence. 80% done is not a state that exists here.
8. When in doubt between acting and escalating: escalate.

## DELIVERABLE

One message to the founder containing:

1. **The complete STEP 0 ratification slate** — R20–R24, R27–R32, OL-1→OL-8 (OL-9/OL-10 logged open), MR-1→MR-6, every `[LOCK-BX-*]`, `[LOCK-FM-*]`, `[LOCK-SH-*]`, `[LOCK-OL-*]`, plus the new ruling adopting the five-pillar landscape taxonomy for folders and GTM with document-internal numbering retained and titles used for citation. Each item: one line, what it says, what ratifying it commits to.
2. **The four master-spec amendments** from the Outcome Ledger done gate (§7 metrics, §23, §24, §42.2), drafted ready to land in the same sitting per `[LOCK-BX-4]`.
3. **Estate hygiene report** — the duplicates (`ADR-004` ×3, `FIRST-CLIENT-RUNBOOK` ×2, `IFOS-Directive-Loop-CANONICAL-SPEC` ×2, `AUTHORITY-MANIFEST` ×2), the ~90-file `Pillar 2 The Second Brain/ifos-second-brain-estate/` dump needing `[LOCK-MR-6]` archive headers, and the confirmed-missing `IFOS-THE-AGENT-APPROACH.md`.
4. **Anything the documents leave genuinely open** — as proposed rulings for the founder, not as decisions you have taken.
5. **Founder actions that do not wait for ratification** — starting with: message Steve re the WP-9 gold set. The boot sequence puts it on day one and calls it the item most likely to be deferred and most expensive to defer.

## DONE GATE

- [ ] All five unread documents read in full, not skimmed
- [ ] Every ruling and lock in the slate cited to document and section
- [ ] Zero decisions taken on the founder's behalf
- [ ] Zero code written, zero repo created, zero files scaffolded
- [ ] Open items presented as proposed rulings, each with a recommendation
- [ ] The cold-start test in the handoff §9 still passes against your output

Begin by reading the handoff, then confirm in one short message: the scope of this session, the four documents you are about to read, and three things you must never touch. Then read.

