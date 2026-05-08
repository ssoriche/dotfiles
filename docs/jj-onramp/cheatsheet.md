# git → jj cheatsheet

Comprehensive translation table. Each section has the direct command
mappings, then a **Notes** subsection for behavior differences worth
knowing, then (where relevant) a **No jj equivalent** subsection — the
*absence* of a concept trips you up more than any new verb.

⚠ marks an anti-pattern or footgun: a jj command that *looks* like the
git equivalent but does something subtly different.

Aliases assumed by this sheet:
- `b` → `bookmark` (jj default)
- `st` → `status` (jj default)
- `l` → `log` (custom in our config)
- `d` → `diff` (custom)
- `nb` → `bookmark create -r @-` (custom)
- `sync` → `git fetch` (custom)

---

## 1. Orient yourself

| I want to... | git | jj |
|---|---|---|
| See what changed in the working tree | `git status` | `jj st` |
| See one-line history | `git log --oneline` | `jj l` |
| See history with full descriptions | `git log` | `jj l -T builtin_log_compact_full_description` |
| See the full DAG (all commits, all bookmarks) | `git log --all --graph --oneline` | `jj l -r 'all()'` |
| Show the current commit (@) in detail | `git show HEAD` | `jj show` |
| Show a specific commit | `git show <sha>` | `jj show <change-id>` |
| What "branch" am I on | `git branch --show-current` | (no answer — see note) |
| What was the last command I ran | (no answer — `git reflog HEAD@{0}` approximates) | `jj op log -l 1` |
| Where does bookmark `foo` point | `git rev-parse foo` | `jj l -r foo` |

**Notes:**
- `jj l` defaults to a useful subset of history (`@` plus immutable heads
  ancestors and trunk), not the full graph. Add `-r 'all()'` to see
  everything; add `-r '::@'` for "ancestors of @" only.
- "What branch am I on" has no jj answer because you aren't *on* a
  bookmark; you're at a specific commit `@`. The closest question is
  "what bookmarks are near @?" — answered by `jj l` (bookmarks are shown
  on each commit they're attached to).
- `jj st` shows what's "in" `@`, not "to be committed." It's listing the
  contents of the working-copy commit, which always exists.

**No jj equivalent:**
- *"Uncommitted changes"* — there's no such state. Edits flow into `@`
  immediately. If you see a commit named "(no description set)" in
  `jj log`, that's `@` with edits but no description yet; describe it
  with `jj describe -m "..."`.
- *"Current branch"* — bookmarks are pointers, not locations.

---

## 2. Inspect changes

| I want to... | git | jj |
|---|---|---|
| Diff working tree vs last commit | `git diff` | `jj d` |
| Diff staged changes | `git diff --staged` | (no equivalent — see note) |
| Diff one file | `git diff -- foo.txt` | `jj d foo.txt` |
| Diff a specific commit | `git show <sha>` | `jj show <change-id>` |
| Diff between two commits | `git diff A..B` | `jj d --from A --to B` |
| Show changes a commit introduces | `git show <sha>` | `jj show <change-id>` |
| Who touched this line | `git blame foo.txt` | `jj file annotate foo.txt` |
| Stat-only summary of changes | `git diff --stat` | `jj d --stat` |
| List files changed in a commit | `git show --stat <sha>` | `jj show --stat <change-id>` |

**Notes:**
- `jj d` (no args) diffs `@` against its parent — i.e. shows your current
  in-progress changes. Same intuition as `git diff` for "what am I
  working on right now."
- `jj diff --from A --to B` is the canonical syntax. The shorter
  `jj diff -r A..B` works but is less explicit.
- Our config sets `ui.diff-formatter = ["delta", "--color-only"]`, so
  output renders through delta exactly like your `git diff` does.

**No jj equivalent:**
- *Staged changes diff* — there is no staging area, so there's nothing
  to diff "staged vs unstaged." If you want to preview "what would the
  next commit look like if I stopped editing now," that's just
  `jj d` — `@` is already a real commit.

---

## 3. Commit work

| I want to... | git | jj |
|---|---|---|
| Save current state as a commit with message | `git add . && git commit -m "..."` | `jj describe -m "..."` then `jj new` |
| Just set the message on the current commit | `git commit --amend -m "..."` | `jj describe -m "..."` |
| Open editor to write the message | `git commit` | `jj describe` |
| Stage and commit only some hunks | `git add -p; git commit` | `jj split` (interactive hunk picker) |
| Amend the last commit | `git commit --amend` | `jj squash --into @-` |
| Just amend the message, not contents | `git commit --amend -m "..."` | `jj describe @- -m "..."` |
| Fixup an older commit (deferred) | `git commit --fixup <sha>` then `git rebase -i --autosquash` | `jj squash --into <change-id>` |
| Auto-distribute fixes to ancestors | `git absorb` | `jj absorb` |
| Make a fresh empty commit on top | (no clean equivalent) | `jj new` |
| Make a fresh commit on a different parent | `git checkout <sha>` then commit | `jj new <change-id>` |

**Notes:**
- The "save current state" workflow has *no add-then-commit ceremony*.
  Edits live in `@`; you describe `@`; then `jj new` opens a fresh empty
  commit so further edits don't pile onto the described one.
- `jj split` shows the same hunk-picker UI you know from `git add -p`
  (using jj's built-in TUI editor unless you've configured otherwise).
  Selected hunks become a new commit; unselected hunks stay in the
  original. The result is two atomic commits, not staged-vs-unstaged.
- `jj squash --into <rev>` is a single command for the entire
  fixup-then-autosquash workflow. The change-id of the target stays
  stable; only its commit hash changes. This is the highest-value
  workflow win for a `--fixup`-heavy git user.
- `jj describe` with no `-m` opens `$EDITOR`. Saving an empty buffer
  leaves the description empty; the commit shows as
  `(no description set)` in `jj log`. To recover, run `jj describe`
  again.

**No jj equivalent:**
- *`git add` to stage a file* — there's nothing to stage to. Tracking is
  decided by `.gitignore`/`.jjignore`, not by add. To force-track an
  ignored file, use `jj file track`.
- *`git commit --amend` for content changes* — collapses into
  `jj squash --into @-`, which is more general (it works for any
  ancestor, not just `@-`).

---

## 4. Rewrite history

| I want to... | git | jj |
|---|---|---|
| Rebase onto a new base | `git rebase trunk` | `jj rebase -d trunk()` |
| Rebase a specific bookmark | `git rebase trunk feature` | `jj rebase -d trunk() -b feature` |
| Move a single commit | `git rebase -i` (move it) | `jj rebase -r <change-id> -d <new-parent>` |
| Move a commit AND its descendants | `git rebase -i` (move + carry) | `jj rebase -s <change-id> -d <new-parent>` |
| Squash two adjacent commits | `git rebase -i` + squash | `jj squash --from <child> --into <parent>` |
| Reword an older commit | `git rebase -i` + reword | `jj describe <change-id>` |
| Drop a commit | `git rebase -i` + drop | `jj abandon <change-id>` |
| Edit a commit's content | `git rebase -i` + edit, then commit --amend | `jj edit <change-id>` (⚠ see note), then edit files, then `jj new` |
| Cherry-pick a commit onto here | `git cherry-pick <sha>` | `jj duplicate -d @ <change-id>` |
| Move a commit (no copy) | (no clean equivalent) | `jj rebase -r <change-id> -d <new-parent>` |
| Split one commit into two | `git rebase -i` + edit + split manually | `jj split -r <change-id>` |

**Notes:**
- `jj rebase -r` vs `-s` vs `-b` is the most common gotcha. `-r` moves a
  *single* revision (and its descendants get reparented onto the moved
  commit's *original parents*). `-s` moves a commit *and its descendants*
  together. `-b` moves an entire bookmark (commit + all ancestors past
  the destination's tip).
- ⚠ **`jj edit <rev>` puts the working copy ON that revision.**
  Subsequent edits amend it directly. This is `git checkout <sha>` semantics
  but more potent because amends happen automatically. To start a fresh
  commit on top of `<rev>` instead, use `jj new <rev>`.
- Squash-during-rebase, reorder-during-rebase, drop-during-rebase, and
  reword-during-rebase are *separate verbs* in jj
  (`squash`/`rebase -r`/`abandon`/`describe`). There's no single
  "interactive rebase" because each verb is already atomic and undoable.
- `jj duplicate` is "cherry-pick" (creates a new commit with the same
  diff at a new location). `jj rebase -r` is "move" (no copy; the original
  is gone).

**No jj equivalent:**
- *`git rebase -i` as a single interactive session* — jj makes you
  perform each operation as its own command. This is intentional: each
  is independently undoable via `jj op undo`, and you don't have to
  hold a multi-step plan in your head.
- *Stop-mid-rebase to manually fix conflicts* — if a rebase produces
  conflicts, jj stores them *as data inside the resulting commits*
  rather than blocking on a conflict prompt. You then resolve by
  editing those commits like any other. See *Conflicts* notes at the
  bottom.

---

## 5. Bookmarks (branches)

| I want to... | git | jj |
|---|---|---|
| List local bookmarks | `git branch` | `jj b list` |
| List all (local + remote) | `git branch -a` | `jj b list -a` |
| Create on `@` | `git branch foo` | `jj b create foo` |
| Create on `@-` (anchor previous commit) | (awkward in git) | `jj nb foo` (alias for `jj b create -r @- foo`) |
| Create on a specific commit | `git branch foo <sha>` | `jj b create foo -r <change-id>` |
| Move a bookmark to `@` | `git branch -f foo` | `jj b move foo --to @` |
| Move a bookmark to a specific commit | `git branch -f foo <sha>` | `jj b move foo --to <change-id>` |
| Delete a local bookmark | `git branch -d foo` | `jj b delete foo` |
| Delete a remote bookmark | `git push origin --delete foo` | `jj b forget foo` then `jj git push --deleted` |
| Rename a bookmark | `git branch -m old new` | `jj b rename old new` |
| Track a remote bookmark | `git checkout -b foo origin/foo` | `jj b track foo@origin` (auto with our config for `origin`) |

**Notes:**
- The "switch to a branch" verb (`git checkout foo`) doesn't have one
  obvious jj equivalent — see section 4 for the actual intentions:
  "start a new commit on top of foo" is `jj new foo`; "put the working
  copy literally on foo's commit" is `jj edit foo` (⚠ amends apply).
  Most of the time you want `jj new foo`.
- Our config sets `remotes.origin.auto-track-bookmarks = "*"`, so newly
  fetched remote bookmarks become local bookmarks automatically. Without
  that, you'd manually `jj b track foo@origin` for each one.
- `jj b forget` removes jj's awareness of a bookmark without deleting it
  on the remote. Use `delete` to remove locally; combine with
  `jj git push --deleted` to propagate to origin.

**No jj equivalent:**
- *Detached HEAD* — every commit is reachable; you can be at a commit
  with no bookmark on it (an *anonymous head*) and that's a normal
  state, not a warning.
- *"The current branch"* — covered in concept #3 of the mental model.

---

## 6. Sync with remotes

| I want to... | git | jj |
|---|---|---|
| Fetch from origin | `git fetch` | `jj sync` (alias for `jj git fetch`) |
| Fetch from a specific remote | `git fetch foo` | `jj git fetch --remote foo` |
| Pull (fetch + integrate) | `git pull` | `jj sync` then `jj rebase -d 'trunk()' -r 'mutable()'` |
| Push the current branch | `git push` | `jj git push --bookmark <name>` (no "current" — see note) |
| Push all bookmarks | `git push --all` | `jj git push --all-bookmarks` |
| Push and create the remote bookmark | `git push -u origin foo` | `jj git push --bookmark foo --allow-new` |
| Push a deletion | `git push origin --delete foo` | `jj git push --deleted` (after `jj b delete foo`) |
| Force-push (after rebase) | `git push --force-with-lease` | `jj git push` (jj's default is safer than `--force`; use `--allow-backwards` only if it complains) |
| List remotes | `git remote -v` | `jj git remote list` |
| Add a remote | `git remote add foo url` | `jj git remote add foo url` |

**Notes:**
- jj never pushes "the current branch" because there isn't one. You
  always specify what to push: a specific bookmark via `--bookmark`, or
  all of them via `--all-bookmarks`. This is annoying once and then
  prevents the entire class of "I pushed the wrong branch" mistakes.
- `git.sign-on-push = true` (in our config) ensures any unsigned mutable
  commits get signed at push time. Belt-and-suspenders against the
  `signing.behavior = "own"` setting somehow missing one.
- jj's force-push is *commit-equivalent-aware*: it refuses if the remote
  has commits you don't have, but doesn't require `--force` when you've
  rewritten history that's already pushed. The mental model: jj knows
  the change-id graph, so "I rewrote commit qmr" is a clean update from
  jj's perspective, even though the commit hash changed.

**No jj equivalent:**
- *Pushing an anonymous head* — bookmarks only. If you want your
  commit on origin, anchor it with `jj nb <name>` first.
- *`git pull` as one command* — kept as two intentionally so the rebase
  step is explicit, not reflexive.

---

## 7. Undo / recovery

| I want to... | git | jj |
|---|---|---|
| Discard working-tree changes to a file | `git checkout -- foo` | `jj restore foo` |
| Discard ALL working-tree changes | `git checkout -- .` | `jj restore` |
| Reset to a clean working tree on the parent | `git reset --hard HEAD~` | `jj abandon @` (creates fresh empty `@` on parent) |
| Reset hard to a specific commit | `git reset --hard <sha>` | `jj op restore <op-id>` (whole-repo undo) |
| See the operation history | `git reflog` | `jj op log` |
| Undo the last operation | (no clean equivalent — usually reflog + reset) | `jj op undo` |
| Restore to a specific operation | `git reset --hard HEAD@{N}` | `jj op restore <op-id>` |
| Stash work for later | `git stash` | (no equivalent — see note) |
| Resume stashed work | `git stash pop` | (no equivalent — see note) |
| Recover a "lost" commit | `git reflog` → reset --hard | `jj op log` → `jj op restore` |

**Notes:**
- `jj op log` is the killer feature. *Every* jj command is recorded;
  *every* operation is undoable atomically with `jj op undo` (last) or
  `jj op restore <op-id>` (any prior state). This includes the working
  copy, all bookmarks, and all commits — not just one ref.
- `jj abandon @` creates a fresh empty `@` on the parent. The previous
  `@` (with its description and changes) is gone *from the visible
  graph* but not from the operation log — `jj op undo` brings it back.
- `jj restore` (no args) is interactive when used without paths; it
  restores all paths in `@` to match the parent. With paths, it
  restores only those paths.

**No jj equivalent:**
- *`git stash`* — and you don't need one. The git pattern of "stash, do
  something else, come back" is in jj just "leave the work as a commit,
  do something else, `jj edit <change-id>` to come back." The work is
  always a commit; there's nowhere else for it to live.
- *`git reset --soft`* — there's no index to reset into. The closest
  intent is `jj squash --into @-` which moves changes from `@` into the
  parent without abandoning either.

---

## 8. Workspaces

> Not used in this repo. Included for transferring this on-ramp to other
> projects. See the design doc's Graduation section for the two
> integration paths with bare-repo + worktree layouts.

| I want to... | git | jj |
|---|---|---|
| Create a sibling working dir | `git worktree add ../foo` | `jj workspace add ../foo` |
| List all worktrees / workspaces | `git worktree list` | `jj workspace list` |
| Remove tracking of one | `git worktree remove ../foo` | `jj workspace forget foo` (then delete dir) |
| Move a worktree | `git worktree move old new` | (manual: forget + add at new path) |

**Notes:**
- In a colocated repo, a jj workspace creates a git worktree under the
  hood. So `git worktree list` and `jj workspace list` show
  overlapping-but-not-identical views. Always prefer the jj command for
  management; treat git's view as read-only.
- The same commit can be checked out in multiple jj workspaces. Git
  refuses; jj allows it. Each workspace's `@` evolves independently.
- Each workspace's working-copy commit is named `<workspace-name>@`.
  The default workspace is `default@`.

---

## Conflicts (brief)

jj stores conflicts *inside commits* rather than blocking on a prompt.
This is the most controversial-looking but powerful difference from git.

- A rebase that would conflict in git produces a conflicted commit in
  jj. `jj log` shows it with a `conflicted` marker.
- Resolve by editing the conflicted commit (`jj edit <change-id>`,
  resolve the markers in files, `jj new`) — same workflow as resolving
  any other commit.
- Or, resolve interactively in jj's TUI: `jj resolve`.
- The whole DAG keeps moving while a conflict exists; you don't get
  stuck mid-rebase. Resolve at your leisure.

This is rare in this repo's flow (small atomic commits, trunk-based,
single contributor) but worth knowing for graduation.

---

## Negative space — what does NOT exist in jj

The absence of these git concepts is what trips a git veteran up most.
Internalize the negative space and the rest follows.

- **No staging area / index.** Edits flow into `@` immediately. There is
  nothing to `git add`.
- **No `HEAD` pointer separate from a commit.** `@` *is* a commit. There
  is no detached-HEAD state because nothing was attached.
- **No "current branch."** Bookmarks are pointers, not contexts. You're
  always on a commit; the bookmarks are nearby labels.
- **No "uncommitted changes."** What git calls uncommitted is in jj
  the working-copy commit `@`, which is a real commit you can describe,
  squash, split, etc.
- **No interactive rebase.** Each operation that interactive-rebase
  combines (squash/edit/reword/drop/reorder) is its own atomic verb in
  jj.
- **No stash.** Just leave work as a commit and come back with
  `jj edit <change-id>`.
- **No `--force` push as a routine action.** jj's push is
  commit-equivalent-aware and refuses unsafe history-divergence even
  without `--force-with-lease` ceremony.

---

## Anti-pattern catalog (⚠ section index)

Quick reference for the gotchas above:

- ⚠ **`jj edit <rev>`** — puts working copy *on* `<rev>`; subsequent
  edits amend it. Use `jj new <rev>` if you want a fresh commit on top.
- ⚠ **`jj rebase -r` vs `-s`** — `-r` moves one commit (descendants
  reparent onto its parent); `-s` moves a commit *and* its descendants
  together. `-b` moves an entire bookmark.
- ⚠ **`jj abandon @`** — looks like `git reset`, but the "abandoned"
  commit is gone from `jj log`. Recover with `jj op undo`.
- ⚠ **Empty description in `jj describe`** — saving an empty editor
  buffer sets an empty description. The commit shows as
  `(no description set)`. Run `jj describe` again to fix.
- ⚠ **Pushing without a bookmark** — anonymous heads can't be pushed.
  Anchor with `jj nb <name>` first.
- ⚠ **Forgetting to `jj new` after `jj describe`** — further edits
  pile into the just-described commit and amend it. `jj new` between
  "this is done" and "now I'm starting something else."
