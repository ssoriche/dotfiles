# jj mental model — seven concepts for a git veteran

Read this once, re-read it whenever a jj command does something surprising.
Each concept is framed as "what your git brain expects" then "what jj
actually does" — the gap between those two is where almost all of the early
confusion lives.

The order matters: each concept builds on the previous one. The first three
are the conceptual flip; the next three are the daily verbs; the seventh is
about parallel work and is included because you need it long-term, even
though the chezmoi repo never uses it.

---

## 1. The working-copy commit (`@`)

**Git brain expects**: a working tree that's separate from history. Edits
sit in "uncommitted changes," then `git add` stages them into the index,
then `git commit` snapshots the index into a commit. Three states: working
tree, index, commit. The first two are not part of history; only the third
is.

**jj reality**: there are no uncommitted changes. Your working tree *is* a
commit, called the *working-copy commit* and addressed as `@`. When you edit
a file, jj silently amends `@` so its tree matches what's on disk. When you
run any jj command, jj snapshots the working tree into `@` first
(transparently) before doing anything else. There is no index, no staging
area, no separate "modified" state — just commits, all the way down.

**Demonstration**: `jj st` after editing a file shows the changes "in" `@`,
not "to be committed" or "modified." `jj log` shows `@` as a commit in the
graph. If `@` has no description yet, that's normal — it's an undescribed
commit, not "uncommitted work."

**Why the flip matters**: every operation in jj works on commits, including
your in-progress edits. Want to move your in-progress edits into the
previous commit? `jj squash --into @-`. Want to see what they look like as a
diff? `jj diff` (with no args, that's the diff *of* `@`). The verb
collapses that git's add/commit/amend trinity provided are now just
"manipulate commits," because everything is a commit.

---

## 2. Change ID vs commit hash

**Git brain expects**: a commit is identified by its SHA. If the SHA
changes, it's a different commit. Tools like `git rebase` produce new SHAs
because the rewritten commits are technically new objects; this is why
force-push exists, and why amending a pushed commit is awkward.

**jj reality**: every revision has *two* identifiers. The **change ID**
(displayed first, lowercase letters like `qmrwsl…`) is *stable across
rewrites* — it identifies the logical change, no matter how its contents
evolve. The **commit hash** (also called the commit ID, hex) changes
whenever the commit's contents do, just like git's SHA.

In jj, the *identity* is the change ID; the commit hash is more like a
snapshot pointer. If you `jj squash` a fix into commit `qmr`, the change ID
`qmr` stays the same; only the commit hash underneath it changes. Anywhere
you'd reach for "the SHA" in git, reach for the change ID in jj instead.

**Demonstration**: `jj log` displays both — change ID first, commit hash
later in the line. After `jj squash --into qmr`, `jj log` still shows `qmr`
in the same position with a new commit-hash suffix. Run `jj evolog -r qmr`
to see all the historical commit hashes that change ID has had.

**Why the flip matters**: it makes "edit an old commit" cheap. The thing
you cared about — the commit's identity — is unchanged, so anything that
referenced `qmr` (other commits, your memory, your scrollback) is still
correct. This is the foundation that makes `jj squash`, `jj absorb`, and
the no-rebase-ceremony amend workflow safe.

---

## 3. Anonymous heads, no "current branch"

**Git brain expects**: you are always *on* a branch. `HEAD` points at a
branch, the branch points at a commit. `git checkout` switches which branch
HEAD is on. A commit with no branch attached is a "detached HEAD" — a scary
warning state.

**jj reality**: bookmarks (jj's word for "branches") are *pointers you place
on commits*, not contexts you live inside. There is no "current branch."
You don't switch branches — you switch *commits*, and bookmarks happen to
follow when you tell them to. A commit with no bookmark is fine, normal,
and not a warning state. It's just a commit. jj calls a commit with no
bookmark and no descendants an *anonymous head*; it shows up in `jj log`
without a name and is fully usable.

**Demonstration**: after `jj new` on top of trunk, you have a new commit
with no bookmark. You can edit, describe, even push it (if you give the
push a bookmark name). Nothing "moved" because there was no branch to move.
Compare to git, where the equivalent gymnastic is: detach HEAD, commit, then
either name a branch or lose the work.

**Why the flip matters**: you stop thinking in terms of branch state and
start thinking in terms of commit graph. "Where am I?" becomes "what's `@`
pointing at and what bookmarks are nearby?" rather than "which branch am I
on?". Bookmarks become labels for *destinations* (the things you push), not
*locations* (where you currently sit).

---

## 4. `jj new` is the everyday verb

**Git brain expects**: a vocabulary of context-switching verbs. `git
checkout -b feature` to start work, `git commit -m` to save it,
`git checkout main` to leave, `git switch -` to come back, `git stash` to
park. Different verbs for different transitions.

**jj reality**: most of those collapse into `jj new`. `jj new <rev>` means
"make a new empty commit on top of `<rev>` and put the working copy
there." That single verb covers:

- `git checkout -b feature trunk` → `jj new trunk`
  (then later `jj bookmark create feature -r @-` if you want the bookmark)
- `git commit -m` → `jj describe -m` then `jj new`
  (describe the current commit, then start a fresh one)
- `git checkout main` → `jj new main`
- `git stash; ...; git stash pop` → `jj new other; ...; jj edit @-`
  (don't park work — just leave it as a commit and come back to it by name)

**Demonstration**: a typical "start a feature, save progress, switch to
another task, come back" sequence in jj is `jj new trunk` → edit/describe →
`jj new trunk` (start the second task) → edit/describe → `jj edit <change-id-of-first>`
to resume the first one. No stash, no checkout, no branch creation, no
context switch ceremony.

**Why the flip matters**: once you internalize "make a new commit on top of
X" as the fundamental motion, half of git's verbs become redundant. The
mental cost is dropping the "I'm on a branch" model from concept #3.

---

## 5. Squash / split / move = the staging area, but better

**Git brain expects**: a staging area as the only fine-grained tool for
carving up changes. `git add -p` to stage hunks, `git commit` to snapshot,
`git commit --amend` to fix the most recent commit, `git rebase -i` to
reorder/squash/edit older ones, `git commit --fixup` + autosquash for
deferred fixups. Five tools, five mental models.

**jj reality**: every history rewrite is just "move some changes from one
commit to another." There is no staging area to carve into; instead you
carve commits directly.

| Want to... | jj verb |
|---|---|
| Carve a commit into multiple commits | `jj split` |
| Combine two commits | `jj squash` |
| Move changes from `@` into an earlier commit | `jj squash --into <rev>` |
| Auto-distribute changes into ancestors that touched the same lines | `jj absorb` |
| Reorder commits | `jj rebase` |

`jj split` opens the same hunk-picker UI as `git add -p`, but the hunks you
pick become a *new commit* immediately, not an invisible index. `jj squash
--into` moves working-copy changes into any target commit in one step —
replacing both `git commit --amend` (when target is `@-`) and the
`git commit --fixup` + `git rebase --autosquash` two-step (when target is
older). `jj absorb` mirrors the `git-absorb` tool's auto-distribution.

**Demonstration**: forgot to add a doc string to the function in commit
`qmr` two commits back. In git: stash, fixup commit, rebase autosquash,
unstash. In jj: edit the file, then `jj squash --into qmr`. Done. Change ID
`qmr` is unchanged; commit hash updated.

**Why the flip matters**: there's no "amend the most recent" vs
"interactive-rebase older" distinction. Every commit is amendable any time.
The whole `--fixup`/`autosquash` ceremony exists in git only because amends
to non-tip commits require a rebase; in jj they don't.

---

## 6. The operation log replaces reflog, stash, and your fear

**Git brain expects**: the reflog as a recovery tool of last resort —
opaque, scary, occasionally life-saving when you've reset --hard the wrong
thing. Stash as a separate parking lot. `git reset --hard` as a one-way
trip.

**jj reality**: every jj command is an *operation*, recorded in a per-repo
operation log. `jj op log` displays them; `jj op restore <op-id>` rolls the
*entire repo state* back to that operation atomically. Not just `@`, not
just one ref — every bookmark, every commit, the working copy, all of it.
Operations include things like "snapshot working copy at 14:02:01" and
"squash commit qmr into @-" and "abandon commit xyz."

**Demonstration**: deliberately mess up. `jj abandon qmr` an important
commit. `jj log` shows it gone. `jj op log` shows the abandon operation.
`jj op restore <op-id-of-the-snapshot-just-before-the-abandon>` and the
commit is back, exactly as it was. This is Mission 6 from the missions
doc; do it on a calm day to build muscle memory before you need it.

**Why the flip matters**: in git you cope with risk by being careful and
hoping the reflog still has what you need. In jj, every operation is
trivially undoable. This changes how you experiment — you can `jj squash`
something, look at the result, and `jj op undo` (alias for `jj op restore`
to the previous op) if you don't like it. The operation log makes jj
genuinely safer to learn than git was.

---

## 7. Workspaces are jj's worktrees, with sharper edges

**Git brain expects**: `git worktree add ../path branch-name` to create a
sibling working directory sharing the same `.git` repo, each on a different
branch, with the constraint that the same branch can only be checked out in
one worktree at a time.

**jj reality**: `jj workspace add ../path` does the same thing — sibling
working directory, shared repo data — but the model is sharper.

- **Each workspace has its own working-copy commit.** Where a git worktree
  is "this directory is on branch X," a jj workspace is "this directory's
  `@` points at commit Y." There's no concept of "this workspace is on a
  bookmark" — there's just `<workspace-name>@` for each workspace's
  working-copy commit. The default workspace is named `default@`; others
  inherit their name from the directory.
- **The same commit can be checked out in multiple workspaces.** Git
  refuses; jj shrugs. Two workspaces can both point at trunk and edit
  independently — each diverges into its own working-copy commit.
- **Cleanup is two-step.** `jj workspace forget <name>` removes a
  workspace from jj's tracking; the directory still exists. Delete it
  separately if you want it gone.
- **Colocated interaction.** When you `jj workspace add` in a colocated
  repo, jj creates a git worktree under the hood. So `git worktree list`
  and `jj workspace list` show overlapping-but-not-identical views. Always
  prefer the jj command for management; treat git's view as read-only.

**This concept is included for life beyond this repo.** This chezmoi repo
doesn't use worktrees and won't use workspaces — chezmoi has a canonical
source dir, so workspaces are awkward here. But your `/Volumes/ziprecruiter/zr/`
work setup is heavily worktree-driven, and the concept is what bridges this
on-ramp into jj adoption there. See the design doc's Graduation section for
the two integration paths (jj-on-top-of-bare vs. colocated-per-worktree).

---

## What's deliberately NOT in v1

- **Filesets** (jj's path-pattern language): power-user feature; you only
  need it once you start writing custom revsets and templates.
- **Conflict-as-data**: jj stores conflicts inside commits and lets you
  resolve them with normal commits. Beautiful model, rare in this repo's
  workflow. Cheatsheet has the basics; deep-dive when you hit a conflict.
- **Custom revsets**: the default revset language is fine. Custom aliases
  are a YAGNI until you find yourself typing the same long expression twice.
- **`jj evolog`** (per-commit history of rewrites): exists, useful for
  archaeology, not load-bearing for daily use.
- **Workspaces in this repo's missions**: see concept #7 — workspaces live
  in your work setup, not here.

If any of these become friction during the missions, that's the signal to
expand this doc.
