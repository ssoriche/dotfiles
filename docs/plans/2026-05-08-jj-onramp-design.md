# jj on-ramp for chezmoi — design

- **Date**: 2026-05-08
- **Status**: design complete, ready for implementation
- **Author**: Shawn (with Claude during a brainstorming session)
- **Implements**: a deliberate path for learning Jujutsu (jj) using this dotfiles repo as the practice substrate, with a graduation note for adopting jj on other projects later

## TL;DR

This document is the spec for a personal jj on-ramp. It produces:

1. A jj config managed via chezmoi (`private_dot_config/jj/config.toml`), tuned for a deep git veteran, with inline comments explaining every option.
2. Three companion docs at `docs/jj-onramp/{mental-model,cheatsheet,missions}.md` containing the conceptual ELI5, the git→jj translation table, and a graduated practice ladder.
3. One-time setup actions: `chezmoi`-add the SSH `allowed_signers` file, run `jj git init --colocate` in this repo.
4. A graduation note describing how to extend this setup to other projects (especially worktree-heavy ones) without committing to a specific migration plan now.

The repo is colocated (`jj git init --colocate`) so git tools, the soft-serve remote, and existing muscle memory all keep working as an escape hatch.

## Why this exists

The author is a deep git veteran who has tried to learn jj several times and falls back to git when stuck. The two root causes are: (a) jj's concepts feel slippery to a brain that has thought in git for ~20 years, and (b) without a forced practice ladder, the easy git fallback always wins. This repo is ideal practice substrate: trunk-based, small atomic changes, frequent natural opportunities for splitting (feature commits paired with chore upgrades), and low blast radius for mistakes.

## Scope

**In scope:**

- jj configuration and identity (signing, aliases, log template, behavior toggles)
- The seven concepts that need ELI5 explanation for a git veteran
- A comprehensive (not curated-thin) git→jj cheatsheet
- A graduated ladder of 8 practice missions (0–7) tied to the natural cadence of this repo
- A short graduation section describing what carries over to other projects and what choices remain open

**Out of scope (deliberate):**

- Practice missions for jj workspaces — this repo does not use worktrees, so there is no honest mission shape for them. Workspaces are covered conceptually only.
- Conflict resolution as a mission. jj's conflict-as-data model is excellent, but conflicts are rare in this repo's flow. Cheatsheet rows only; no mission.
- Pre-designed migration of `/Volumes/ziprecruiter/zr/` (the work bare-repo + worktrees layout) — too many unknowns. The graduation section captures inputs already decided so the future migration session can be short.
- Custom revsets, custom templates beyond the log oneline, fileset deep-dive, evolog deep-dive — added later only when real friction surfaces.
- Bare-repo restructure of this chezmoi repo. Out of scope; only mentioned as a graduation option.

## Layout and artifacts

### Repo-only documentation (chezmoi-ignored)

```
docs/
  plans/
    2026-05-08-jj-onramp-design.md         <- this document
  jj-onramp/
    mental-model.md                        <- ELI5 of the seven concepts
    cheatsheet.md                          <- comprehensive git→jj translation
    missions.md                            <- mission cards 0–7 with full structure
```

`docs/` is added to `.chezmoiignore` so nothing under it deploys. Lives in the repo so it's versioned and travels with the dotfiles.

### Chezmoi-deployed config

```
private_dot_config/jj/config.toml          -> ~/.config/jj/config.toml
private_dot_ssh/allowed_signers            -> ~/.ssh/allowed_signers   (Mission 0)
```

Both are plain (no template), no secrets, no per-machine overrides. `private_` prefix preserves the 600 permissions SSH and jj expect.

### Repo state changes

- `jj git init --colocate` from `~/.local/share/chezmoi/` adds `.jj/` next to `.git/`. Soft-serve never sees `.jj/` — only the local clone has it.
- `.gitignore` should already pick up `.jj/` (jj does this on init); verify after.

## The jj config

The full file is written during implementation as `private_dot_config/jj/config.toml`. Every option carries an inline comment that explains what it does, what the default is when overridden, and any non-obvious tradeoff. The config doubles as a study guide.

Planned content, organized by purpose:

```toml
# ─── identity ──────────────────────────────────────────────────────────────
[user]
name  = "Shawn Sorichetti"
email = "ssoriche@users.noreply.github.com"   # personal/dotfiles email; work uses ZR address

# ─── ui shaped like git ────────────────────────────────────────────────────
[ui]
default-command = "log"                        # bare `jj` shows log instead of erroring
diff.format     = "git"                        # familiar git-style diffs, not color-words
pager           = "less -FRX"                  # general pager
diff-formatter  = ["delta", "--color-only"]    # delta does diffs (already your git pager)
show-cryptographic-signatures = true           # ✓/?/✗ column in `jj log`

# ─── log template that looks like home ─────────────────────────────────────
[templates]
# render approximating `git log --oneline --graph --decorate --pretty=...`
# short change-id, bookmarks/tags, author email-local, relative date, summary
log = "..."   # exact template written during implementation

# ─── behavior toggles a git veteran wants ──────────────────────────────────
[git]
auto-local-bookmark = true                     # remote branches → local bookmarks on fetch
                                               # default false; surprises git users badly
sign-on-push        = true                     # belt-and-suspenders: sign anything unsigned on push

[snapshot]
max-new-file-size = "10MiB"                    # guard against accidental binary auto-snapshot

# ─── ssh signing via 1password ─────────────────────────────────────────────
[signing]
backend  = "ssh"
behavior = "own"                               # sign your authored commits, leave others' alone
                                               # closest match to git's commit.gpgsign=true semantics

[signing.backends.ssh]
program        = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
key            = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICznCAl6WoraDSM76FuSahtnEkVOGY26+nc9/NKbkN1K"
allowed-signers = "~/.ssh/allowed_signers"     # for verification (the ✓ column)

# ─── aliases (deliberately small) ──────────────────────────────────────────
[aliases]
st   = ["status"]
l    = ["log"]
d    = ["diff"]
nb   = ["new"]                                  # placeholder; final form decides whether
                                                # to also create a bookmark on the new commit
sync = ["git", "fetch"]                         # stub; expand to fetch+rebase trunk during impl
```

### Open questions to resolve at write time

These are unknowns flagged for the implementation step, not blockers for the design.

1. **Exact key name for the SSH pubkey.** `signing.backends.ssh.key` is the most likely path based on the structure of jj 0.40's signing config, but it is not in `--include-defaults` output (no default value to introspect). Verify against `https://docs.jj-vcs.dev/latest/config/#commit-signing` during the write step. Fix in place if it's actually `signing.key` or similar.
2. **Whether jj inherits `gpg.ssh.allowedSignersFile` from git config.** If yes, the `signing.backends.ssh.allowed-signers` line is redundant. If no, the explicit pointer is required.
3. **Final shape of the `nb` alias.** Plain `jj new` or `jj new && jj bookmark create`? The latter forces bookmark hygiene; the former is more orthogonal. Decide based on which behavior reduces friction during the missions.
4. **`sync` alias content.** Stub above is just `git fetch`. Likely final form: fetch from remote, then rebase mutable bookmarks onto the new trunk tip.

## Mental model — the seven concepts

The companion `mental-model.md` covers these in order, each ~150 words with a "felt like X in git, actually Y in jj" framing. Order is chosen to defuse pain points before they form, not to march through textbook structure.

1. **The working-copy commit (`@`)** — there are no "uncommitted changes." Your working tree *is* a commit. Editing a file silently amends it. The single biggest mental flip; everything else builds on it.
2. **Change ID vs commit hash** — every revision has two IDs. The change-id is stable across edits; the commit hash changes when content does. In git, identity = SHA. In jj, identity = change-id; the SHA is more like a snapshot pointer. Explains why log output looks weird.
3. **Anonymous heads, no "current branch"** — you don't `checkout` branches; you create commits. Bookmarks are *pointers* you place on commits, not *contexts* you live inside. A commit without any bookmark is fine and normal.
4. **`jj new` is the everyday verb** — replaces `git checkout -b`, `git commit`, and most `git switch` use. It means "make a new empty commit on top of X and put the working copy there." Half of git's verbs collapse into one.
5. **Squash / split / move = the staging area, but better** — `jj split` is `git add -p` carving into a real new commit, not an invisible index. `jj squash --into` moves changes from any commit to any other. There is no "amend" because every commit is amendable any time.
6. **Operation log = reflog + stash + safety net** — every jj command is an operation. `jj op log` shows them; `jj op restore <id>` rolls the entire repo back atomically. This is why jj is safe to learn.
7. **Workspaces are jj's worktrees, with sharper edges** — `jj workspace add ../path` parallels `git worktree add`. Each workspace has its own working-copy commit. Same commit can be checked out in multiple workspaces (git refuses; jj shrugs). In colocated mode, `git worktree list` and `jj workspace list` show overlapping but not identical views — prefer the jj command for management.

## Cheatsheet

The companion `cheatsheet.md` is an "I want to..." | git | jj table, comprehensive rather than thin. ~50 rows organized into 8 sections:

1. **Orient yourself** — status, log, current branch
2. **Inspect changes** — diff, show, blame
3. **Commit work** — commit, amend, add -p
4. **Rewrite history** — rebase, cherry-pick, fixup, autosquash, absorb
5. **Bookmarks (branches)** — create, move, delete, list, push
6. **Sync with remotes** — fetch, pull, push, force-push
7. **Undo / recovery** — reflog, reset, stash, restore
8. **Workspaces** — add, list, forget (short section, flagged "not used in this repo")

Format opinions:

- Each row carries a one-line note explaining a non-obvious tradeoff or behavior difference.
- Multi-step git workflows that collapse into single jj commands show the collapse explicitly. Example: `git stash; git checkout other; git checkout -; git stash pop` collapses to `jj new other` then `jj edit @-`. Showing the collapse is the clearest "jj is git but better" demonstration.
- Anti-patterns flagged with ⚠. Example: `jj edit <rev>` puts the working copy *on* that revision so subsequent edits amend it directly — which is not what a git veteran's instinct expects. The ⚠ saves a foot-shot.
- A short "no jj equivalent" subsection per category where relevant. The *absence* of a concept is what trips you up most: "there is no staging area," "there is no detached HEAD state, every commit is reachable."
- The fixup/autosquash collapse is called out specifically because it's the highest-value workflow win for this user: `git commit --fixup <sha>` + `git rebase -i --autosquash` collapses to `jj squash --into <rev>` in one step. `git absorb` maps directly to `jj absorb`.

## Practice missions

The companion `missions.md` contains full mission cards. Every mission has the same five-part structure:

- **Goal** — which concept(s) it targets
- **Trigger** — when in normal repo work to attempt it (most are opportunistic)
- **Steps** — what to type
- **Checkpoint** — what `jj log` should look like after, and any verification commands
- **If it goes wrong** — the pre-loaded recovery move (the cheap escape hatch back to git, or the jj command to recover). Pre-loading recovery means falling back to git becomes a deliberate choice instead of a panic move.

### Mission 0 — Pre-flight (deliberate, do this first)

- **Goal**: setup so Mission 1's signature-verification checkpoint is honest
- **Trigger**: do this once, before any other mission
- **Steps**:
  1. Bring `allowed_signers` over from the other machine (scp, or recreate the line locally — typically `<email> <pubkey>`)
  2. `chezmoi add ~/.ssh/allowed_signers` → lands as `private_dot_ssh/allowed_signers` in source tree
  3. `chezmoi apply ~/.ssh/allowed_signers` to deploy on this machine
  4. Confirm `git config --global gpg.ssh.allowedSignersFile` points at `~/.ssh/allowed_signers`; add if missing
  5. Add jj config (the file from this design) via `chezmoi apply ~/.config/jj/`
  6. `cd ~/.local/share/chezmoi && jj git init --colocate`
  7. `jj log` — should render without errors and show recent commits
- **Checkpoint**: `git log --show-signature -1` no longer errors about `allowedSignersFile`; `jj log` shows the recent commits with signature column populated
- **If it goes wrong**: nothing here is destructive; if jj init misbehaves, `rm -rf .jj/` and try again. The git repo is untouched.

### Mission 1 — First signed commit in jj

- **Goal**: working-copy commit (concept #1), `jj new` verb (#4), signing verification end-to-end
- **Trigger**: next trivial change you'd otherwise have done in git (typo, comment cleanup)
- **Steps**:
  1. Make the trivial edit
  2. `jj st` to see the change in `@`
  3. `jj describe -m "fix(area): description"` to set the commit message
  4. `jj new` to start a fresh empty commit on top
  5. `jj log` — confirm the previous commit shows ✓ in the signature column
  6. `jj git push --bookmark main` (or whichever bookmark — see step 6 caveats below)
- **Checkpoint**: `jj log` shows your commit signed (✓); `git log -1 --show-signature` agrees
- **If it goes wrong**: `jj op log` to see the operation history; `jj op restore <id>` to roll back. Worst case, `git reset --hard origin/main` and try again — soft-serve doesn't have anything yet.

### Mission 2 — A flox upgrade, single group

- **Goal**: see auto-snapshot work; see how `jj st` always shows clean trees because edits flow into `@` (concepts #1, #2)
- **Trigger**: next routine `flox upgrade <group>` from your normal cadence
- **Steps**:
  1. `jj new` on top of trunk to start a clean working-copy commit
  2. `flox upgrade --dry-run <group>`
  3. `flox upgrade <group>`
  4. `jj st` — note the lockfile change is already in `@`, no `git add` step
  5. `jj describe -m "chore(flox): upgrade <group> group"`
  6. `jj new`; push
- **Checkpoint**: commit lands matching the existing `chore(flox): upgrade ...` style and is signed
- **If it goes wrong**: `jj abandon @-` to discard the upgrade commit; `jj op restore` if things got weirder. The lockfile reverts because the commit was the working-copy commit.

### Mission 3 — Split a feat into atomic commits

- **Goal**: replace the `git add -p` mental model with `jj split` (concept #5)
- **Trigger**: next change touching multiple logically distinct files. Recent example: `feat(nono): add initial profile` + `feat(flox): Add nono to default packages` could have been one big change split into two.
- **Steps**:
  1. Make all the edits without committing intent (just edit; everything flows into `@`)
  2. `jj describe -m "WIP"` to mark it
  3. `jj split` — interactive; select hunks for the *first* commit
  4. After split, `jj log` shows two commits where there was one
  5. `jj describe @-` and `jj describe @` to give them real messages
- **Checkpoint**: `jj log` shows two atomic commits with conventional-commit messages, both signed
- **If it goes wrong**: `jj op restore` rolls the split back. The original combined commit returns; try again.

### Mission 4 — The fixup workflow

- **Goal**: replace `git commit --fixup` + `git rebase -i --autosquash`, and `git absorb`, with their jj equivalents (concepts #2, #5)
- **Trigger**: first time you realize a forgotten detail belongs in an earlier commit
- **Steps**:
  - **Manual fixup (replaces `--fixup` + autosquash)**:
    1. Make the missing edit (lands in `@` as usual)
    2. `jj squash --into <change-id-of-target>` — moves the working-copy changes into the target commit in one step
  - **Automatic fixup (replaces `git absorb`)**:
    1. Make several missing edits across different files
    2. `jj absorb` — distributes each hunk to the closest mutable ancestor that touched the same lines
- **Checkpoint**: the target commit's diff now includes the fix; the change-id is stable, the commit hash changed
- **If it goes wrong**: `jj op restore` rolls back. The change-id stability means the target commit is easy to find again.

### Mission 5 — Stack two unrelated changes

- **Goal**: replace the "I'm on a branch" mental model (concepts #3, #4)
- **Trigger**: next time you'd otherwise have stash-juggled or context-switched
- **Steps**:
  1. From trunk: `jj new -m "feat(a): description"` — make change A
  2. `jj new trunk -m "feat(b): description"` — start change B from trunk again, not from A. Now you have two parallel descendants of trunk.
  3. `jj bookmark create feat-a -r <change-id-of-a>` and similarly for `feat-b`
  4. `jj git push --bookmark feat-a` then `jj git push --bookmark feat-b` — two PRs to soft-serve
- **Checkpoint**: `jj log` shows trunk with two parallel descendants, each carrying a bookmark; soft-serve has both refs
- **If it goes wrong**: `jj abandon` either commit to drop it; bookmarks can be deleted with `jj bookmark delete`

### Mission 6 — Disaster recovery rehearsal (deliberate, not opportunistic)

- **Goal**: build muscle memory for the safety net (concept #6) — the only mission you do *deliberately* rather than wait for
- **Trigger**: scheduled, on a calm day. You cannot learn the safety net by waiting to need it; you have to rehearse.
- **Steps**:
  1. Before starting, `jj op log` once to note the current operation id
  2. Do something obviously bad: `jj abandon` an important commit, or `jj squash --into` the wrong target
  3. Confirm `jj log` reflects the damage
  4. `jj op log` to see the operation that caused it
  5. `jj op restore <id-from-step-1>` to roll back
  6. Confirm `jj log` shows the original state
- **Checkpoint**: repo state matches step 1 exactly; you have personally watched `op restore` undo a bad operation
- **If it goes wrong (i.e., this is a real disaster, not a rehearsal)**: same procedure works. The whole point is that this *is* the recovery procedure.

### Mission 7 — Sync with soft-serve, rebase, push

- **Goal**: full remote-interaction loop (bookmarks, push semantics) — closes the on-ramp
- **Trigger**: next time trunk moves on soft-serve while you have local work
- **Steps**:
  1. `jj git fetch`
  2. `jj log` — see the remote bookmark advanced past your local one
  3. `jj rebase -d trunk -b <your-bookmark>` to move your bookmark commits onto the new trunk tip
  4. `jj git push --bookmark <your-bookmark>` — should succeed; `git.sign-on-push` ensures rebased commits are signed
- **Checkpoint**: soft-serve shows your branch fast-forwarded with signed commits
- **If it goes wrong**: rebase conflicts surface as conflict-as-data in jj — see `cheatsheet.md` "rewrite history" section for resolution. If wedged, `jj op restore` to before the rebase and try again.

## Graduation — how to extend later

Tight scope here: capture inputs already decided so the future migration session is short. Resist the urge to pre-design.

### What carries over with no re-thinking

- The jj config is in chezmoi, so it deploys everywhere on first `chezmoi apply`. SSH signing, aliases, log template, behavior toggles — already work on every machine.
- The mental model and cheatsheet are universal. They don't change per repo.
- Mission 6 (disaster recovery rehearsal) is repo-agnostic. Re-run it once on each repo you adopt jj into; takes 5 minutes.

### Mapping `/Volumes/ziprecruiter/zr/` to jj

Existing layout: `.bare/` holds the bare repo, `.git` (file) at the parent contains `gitdir: ./.bare`, sibling directories are formal git worktrees. The parent dir itself works as a checkout via the `.git` file → `.bare` indirection.

Two integration paths in jj, each with real tradeoffs. This decision is the load-bearing call when migrating; everything else flows from it.

- **Path A: Non-colocated, jj on top of the bare** — `jj git init --git-repo .bare` from the parent, then `jj workspace add ../shawns.feature` for each. jj uses `.bare` as its git backing store; each workspace gets its own `.jj/` dir.
  - **Wins**: cleanest jj mental model, no two-tool overlap.
  - **Loses**: workspace dirs are no longer git worktrees, so `git status` etc. inside them stops working.
- **Path B: Keep git worktrees, add jj colocated per worktree** — leave the bare repo and its worktrees as-is; run `jj git init --colocate` inside each worktree directory you want to use jj in.
  - **Wins**: every dir still works as a git worktree; gradual adoption (some dirs jj, some not).
  - **Loses**: each worktree carries both `.git` and `.jj` state; jj's workspace concept overlaps confusingly with git's worktree concept since both are now in play.

**Likely picks**: Path B for migration of an existing repo (preserves tools and lets you adopt incrementally), Path A for new projects from scratch. But this is genuinely the kind of decision worth its own brainstorming session when you reach it — too many unknowns about how your existing tools and CI interact with jj for it to be pre-decided here.

### Graduation checklist

When adopting jj on a new project:

1. Decide Path A vs Path B per repo, *before* any commits.
2. Confirm `chezmoi apply ~/.config/jj/` has run on the machine; signing config travels with you.
3. Test signing in the new repo before doing real work — `jj describe` a no-op, push, verify ✓ in `jj log`.
4. Run Mission 6 (disaster recovery rehearsal) once in the new repo.
5. First real action: `jj op log` so you've seen the safety net before you need it.
6. If the project uses worktrees, decide your jj workspace naming convention up front (likely mirror the existing branch-naming convention).
7. If the project's CI verifies signatures, confirm `git.sign-on-push = true` is doing its job before relying on it.

## Implementation plan (handed off to writing-plans skill)

The next phase produces the actual artifacts. Loose order:

1. Add `docs/` to `.chezmoiignore` (already done as part of this commit).
2. Resolve the open questions in section "The jj config" by reading the jj 0.40 docs.
3. Write `private_dot_config/jj/config.toml` with the full TOML described above and inline comments per option.
4. Write `docs/jj-onramp/mental-model.md` from the seven-concept outline.
5. Write `docs/jj-onramp/cheatsheet.md` from the eight-section outline (~50 rows).
6. Write `docs/jj-onramp/missions.md` expanding each mission card with full prose and example output.
7. Mission 0 (one-time): `chezmoi`-add `~/.ssh/allowed_signers` from the other machine, deploy, then `jj git init --colocate` here.
8. Commit each artifact as its own conventional-commit, separately, so the diff history of the on-ramp is itself a worked example of the workflow.

## Decisions log

One-liner per decision, with rationale:

- **Colocated, not native** — escape hatch for falling back to git; required for soft-serve via git as the remote.
- **`docs/` chezmoi-ignored** — versioned but not deployed; lives with the dotfiles wherever they go.
- **Comments throughout the config** — config doubles as study guide; reduces "what does this option do" lookups during the on-ramp.
- **Five aliases only** — learn jj's verbs, not a re-skinned git on top.
- **`default-command = "log"`** — no-op-safe bare `jj`, mirrors the type-then-think reflex.
- **`pager = less`, `diff-formatter = delta`** — two pagers each doing what they're best at; matches existing git setup.
- **Signing in v1** — unsigned-commit regression would pull the user back to git; SSH signing via `op-ssh-sign` mirrors existing git config.
- **`behavior = "own"`** — closest match to git's `commit.gpgsign=true` semantics.
- **`git.sign-on-push = true`** — belt-and-suspenders so nothing leaves the machine unsigned.
- **`auto-local-bookmark = true`** — flips a default that surprises git users; remote branches → local bookmarks on fetch.
- **Mission 0 covers `allowed_signers`** — closes a real gap in the user's chezmoi management; makes Mission 1's signature-verification checkpoint honest.
- **Mission 6 is deliberate, not opportunistic** — disaster recovery cannot be learned by waiting; rehearsal is the only way.
- **No workspace mission** — this repo doesn't use worktrees; faking a mission for it would be dishonest practice.
- **Comprehensive cheatsheet, not curated thin** — author wants to see the full surface area; thin feels like something is being hidden.
- **Graduation kept short** — capture decided inputs, resist pre-designing the future migration. Future-Shawn does that brainstorming when actually ready.
