---
name: terse-proposal
description: Write a terse, decision-oriented design proposal in a project's docs/proposals/ directory. Target 200-350 lines, decisions in tables, status block at top, no over-engineered meta-sections. Use when the user asks to "write a proposal", "propose X", "draft a design doc", "design proposal", or creates a file under any docs/proposals/ folder.
---

# Terse proposal

Working design proposals in the local style: terse, decision-oriented, tables over prose, no meta-section bloat.

## Before writing — always

1. Locate the target `docs/proposals/` directory (or nearest equivalent: `docs/designs/`, `docs/rfcs/`, etc.).
2. Glob it for existing proposals. Read 2-3 — at least one short, at least one medium — to absorb:
   - Filename convention (e.g. `CRULE-005-foo.md`, `RFC-12-bar.md`).
   - Status-block field set.
   - Section order, headings, table styles.
   - How decisions are tabulated.
3. **Match local convention.** Do not invent a new format if one exists.

If the directory has no existing proposals, fall back to the structure below and create an `index.md` alongside the new file.

## Default structure (when no local convention exists)

```
# <ID>-<slug>: <Title>

**Status**: Draft | Implemented | Superseded
**Risk**: Low | Medium | High — one-line why
**Tier scope**: where this applies
**Tracking**: [TICKET-123](url)
**Related**: sibling proposals, upstream issues, READMEs

---

## Problem
## What the current behaviour is (or: why existing workarounds aren't enough)
## Proposal
## Design details
## Failure modes        — table
## Rollout plan
## Non-goals
## Open questions
## Follow-ups
```

Optional sections — borrow from local convention. Not every proposal needs every section.

## Style rules

- **Target 200-350 lines.** Longer only if the design genuinely warrants it.
- **Decisions in tables.** Workarounds considered, options evaluated, failure-mode / mitigation pairs — read better as tables than prose.
- **No meta-sections.** Skip "Background context", "Glossary", "Document conventions" unless the local style uses them.
- **One-line justifications.** A risk score, threshold, or workaround choice should be defensible in one sentence. If it takes a paragraph, the design isn't ready.
- **Cite sources of truth.** Upstream issue numbers, incidents, READMEs — link them once and lean on them. Don't re-derive.
- **No PR template, no test plan section.** This is a design doc, not a PR description.

## Index maintenance

If `docs/proposals/index.md` (or equivalent) exists, add a row for the new proposal. If it doesn't and the directory has 3+ proposals, offer to create one.

Typical shape:

```md
# <component> Proposals

Design proposals for <component>.

| ID | Title | Status | Tracking |
|----|-------|--------|----------|
| [X-001](X-001-foo.md) | Foo | Draft | [TICK-1](url) |
```

## Anti-patterns to avoid

- Writing a 700-line proposal because the template "had room for it."
- Restating the problem three times across Background / Motivation / Problem.
- Filling every section even when one says "N/A" or "none yet."
- Speculating about future versions instead of writing one Follow-ups bullet.
- Inventing an ID prefix when the directory has an established one.
