# jj practice missions for this repo

A graduated ladder of eight missions (0 through 7) keyed to the natural
cadence of this dotfiles repo: small atomic commits, frequent flox
upgrades, occasional feat work, single contributor, low blast radius.

Every mission has the same five-part structure:

- **Goal** — the concept(s) it forces you to use
- **Trigger** — when to attempt it (most are opportunistic; one is deliberate)
- **Steps** — what to type
- **Checkpoint** — what should be true afterward
- **If it goes wrong** — the pre-loaded recovery move so you don't bail to git

The recovery move is load-bearing. Falling back to git is supposed to be a
*deliberate* choice, not a panic move. If you have the recovery command
already in your head, the panic move is `jj op undo` instead.

Companion docs:
- `mental-model.md` — the seven concepts behind these missions
- `cheatsheet.md` — git→jj translation table for any command that comes up

---

## Mission 0 — Pre-flight (deliberate, do this first)

One-time setup so every later mission has a clean slate. This closes the
real gap in your chezmoi management (the `allowed_signers` file is on
another machine but not yet under chezmoi).

### Goal

- Have `~/.ssh/allowed_signers` deployed and managed by chezmoi.
- Have the jj config deployed.
- Initialize jj in this repo, colocated with git.
- Confirm signature *verification* works end-to-end (`jj log` shows ✓ or
  `?` instead of erroring).

### Steps

```bash
# 1. Bring allowed_signers from your other machine. Two ways:
#    a) scp it over — replace <other-host>:
scp <other-host>:~/.ssh/allowed_signers ~/.ssh/allowed_signers
chmod 600 ~/.ssh/allowed_signers

#    b) OR recreate locally (the format is one line per signer):
#       <email-or-principal> <ssh-pubkey>
#    e.g.:
echo "ssoriche@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICznCAl6WoraDSM76FuSahtnEkVOGY26+nc9/NKbkN1K" > ~/.ssh/allowed_signers
chmod 600 ~/.ssh/allowed_signers

# 2. Bring the file under chezmoi management.
chezmoi add ~/.ssh/allowed_signers
# Lands as private_dot_ssh/allowed_signers in the chezmoi source tree
# (the private_ prefix preserves 600 permissions).

# 3. Confirm git knows about it (probably already set; add if not):
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers

# 4. Deploy the jj config (committed earlier in this session):
chezmoi apply ~/.config/jj/

# 5. Initialize jj in this repo, colocated with git:
cd ~/.local/share/chezmoi
jj git init --colocate

# 6. Verify both tools see the signing setup:
git log -1 --show-signature       # should not error about allowedSignersFile
jj log -r '@-' --no-graph         # should render with ✓ or ? (not raise)
```

### Checkpoint

- `git log -1 --show-signature` no longer prints
  `error: gpg.ssh.allowedSignersFile needs to be configured`.
- `jj log -r '@-'` renders the previous commit with a signature column
  showing `✓` (verified), `?` (unknown signer — fine for old commits
  before signing was set up), or `-` (no signature, fine for old
  commits).
- `.jj/` directory exists at the repo root.
- `git status` and `jj st` both work and show consistent views.

### If it goes wrong

- Bad allowed-signers format: `ssh-keygen` will tell you on next signed
  operation. The format is one line per signer:
  `<principal> <key-type> <key-base64>`.
- jj init misbehaves: `rm -rf .jj/` and try again. The git repo is
  untouched.
- chezmoi balks at adding `~/.ssh/allowed_signers`: confirm the file
  exists and is mode 600. The `private_` prefix in the source path
  matters — chezmoi will use it automatically based on the perms.

---

## Mission 1 — First signed commit in jj

The smallest possible jj commit, end-to-end, on a real change you'd
otherwise have done in git.

### Goal

- Make a real edit and watch it auto-snapshot into `@`.
- Use `jj describe` and `jj new` as your two main verbs.
- Verify the commit is signed and the verification displays correctly.

### Trigger

Next trivial change you'd otherwise have done in git: a typo, a comment
cleanup, a formatting fix. Pick something that takes ≤ 5 minutes so the
ceremony of using jj for the first time isn't bundled with thinking about
the change itself.

### Steps

```bash
# Make your trivial edit in any managed file.
$EDITOR docs/jj-onramp/cheatsheet.md   # or whatever

# Look at the working-copy commit. It already has your edit in it.
jj st
# Working copy changes:
# M docs/jj-onramp/cheatsheet.md
# Working copy : <change-id> (no description set)
# Parent commit: <change-id> ...

# Describe @ — set the message.
jj describe -m "docs(jj-onramp): fix typo in cheatsheet"

# Open a fresh empty @ on top so further edits don't pile onto this one.
jj new

# Look at the log.
jj l
# Should show your described commit just below @, with a ✓ in the
# signature column.

# Push it. main is the bookmark; we move it to the just-described
# commit (the one before @, i.e. @-) before pushing.
jj b move main --to @-
jj git push --bookmark main
```

### Checkpoint

- `jj l` shows your commit with a ✓ in the signature column.
- `git log -1 --show-signature` (the git view) confirms the signature.
- The remote (soft-serve) has the commit on `main`.

### If it goes wrong

- Signed but ✓ missing → `allowed_signers` not configured correctly. Re-run
  Mission 0 step 6 verification.
- Pushed wrong content → `jj op log` to find the operation before the
  push; recover with `jj op restore <op-id>`. The commit on the remote
  is still pushed; rebase mainenance uses `jj git push --bookmark main`
  again with the corrected commit.
- Total panic → `jj op undo` repeatedly until `jj l` shows the original
  state. Then bail to git for this one change with `git checkout --
  <file>` and try Mission 1 again later.

---

## Mission 2 — A flox upgrade, single group

Use jj for a routine `chore(flox): upgrade ...` commit. Highest-frequency
change in this repo; getting comfortable here unlocks most of the
on-ramp.

### Goal

- See auto-snapshot work on a real, multi-file change (lockfile + maybe
  manifest).
- Practice the describe → new rhythm on a non-trivial change.

### Trigger

Next time you'd otherwise run `flox upgrade <group>`. Pick a fast-moving
group (e.g. `claude`, `opencode`) so the upgrade is meaningful.

### Steps

```bash
# Open a fresh @ on top of trunk's tip (main).
jj new main

# Run the upgrade.
flox upgrade --dry-run <group>      # see what would change
flox upgrade <group>                # do it

# jj has already snapshotted the changes into @.
jj st
# Working copy changes:
# M dot_flox/env/manifest.toml          (maybe)
# M dot_flox/env/private_manifest.lock  (always)

# Describe matching the existing commit style — see `git log --oneline -10`
# for examples of the convention.
jj describe -m "chore(flox): upgrade <group> group"

# Open a fresh @ and update the bookmark.
jj new
jj b move main --to @-

# Push.
jj git push --bookmark main
```

### Checkpoint

- `jj l` shows the upgrade commit with the conventional message style
  (`chore(flox): upgrade <group> group`) and a ✓ signature.
- Lockfile change is the canonical "one upgrade per commit" diff —
  matches the existing style in `git log`.

### If it goes wrong

- Upgrade made you regret it → `jj abandon @-` to drop the commit
  (assuming `@` is empty after `jj new`). Then run
  `flox upgrade --dry-run` to inspect again, decide differently.
- Lockfile churn looks weird → `jj d -r @-` to inspect the diff;
  `jj op undo` if the snapshot picked up unrelated edits.

---

## Mission 3 — Split a feat into atomic commits

Replace the `git add -p` mental model with `jj split`. This is the
mission that makes you faster than git.

### Goal

- Make several logically distinct changes without committing intent.
- Carve them into atomic commits with `jj split` (no staging area
  involved).

### Trigger

Next change touching multiple logically distinct files. Pattern from
recent history: `feat(nono): add initial profile` + `feat(flox): add
nono to default packages` were separate commits but could naturally
have been done as one work session and split.

Concretely, a good Mission 3 candidate is "add a new package": you'd
edit `dot_flox/env/manifest.toml` (the manifest add) AND
`private_dot_config/<tool>/...` (the tool's config files) in one work
session, then split them into two commits.

### Steps

```bash
# Open a fresh @ on top of main.
jj new main

# Make ALL the edits you want. Don't worry about commit boundaries yet.
$EDITOR dot_flox/env/manifest.toml
$EDITOR private_dot_config/<tool>/...

# Mark @ with a placeholder so you can find it.
jj describe -m "WIP: split me"

# Run jj split. It opens an interactive UI showing every changed hunk.
# Select the hunks for the FIRST commit (e.g. just the manifest add).
# Save and exit; jj creates two commits where there was one.
jj split

# Now @- is "first half" (still says WIP) and @ is "second half"
# (also still says WIP, with the description carried).
jj l

# Re-describe each commit with its real conventional message.
jj describe @- -m "feat(flox): add <tool> package"
jj describe @  -m "feat(<tool>): add initial config"

# Push each, with bookmarks if you want them as separate PRs.
# For trunk-based work in this repo, just move main forward and push.
jj b move main --to @
jj git push --bookmark main
```

### Checkpoint

- `jj l` shows two atomic commits, each with a conventional-commit
  message and ✓ signature.
- `git log --oneline -3` (the git view) confirms both commits exist
  with stable hashes and signatures.

### If it goes wrong

- Picked the wrong hunks → `jj op undo` rolls the split back. The two
  commits collapse back into one. Try `jj split` again.
- Realized the split should have been three commits → `jj split` the
  resulting commits further.
- The hunk picker confuses you → press `?` in the TUI for help, or
  `q` to abort and keep the original commit.

---

## Mission 4 — The fixup workflow

Replace `git commit --fixup` + `git rebase -i --autosquash`, and
`git absorb`, with their jj equivalents in one mission. This is
probably the highest-value workflow win for you.

### Goal

- Use `jj squash --into <rev>` to do "manual fixup" in one step (no
  separate autosquash phase).
- Use `jj absorb` to do "automatic fixup" across multiple ancestors.

### Trigger

First time, after committing something, you realize a forgotten detail
belongs in an earlier commit.

### Steps — manual fixup

```bash
# Suppose you described and `jj new`d two commits ago. You realize the
# commit two back (call it qmr) is missing a comment in foo.txt.

# Make the missing edit.
$EDITOR foo.txt

# jj has snapshotted it into @. Move it into qmr in one step.
jj squash --into qmr

# qmr's change-id is unchanged; its commit hash updated. Check:
jj show qmr           # should now contain the comment
jj evolog -r qmr      # shows the prior commit hash for the same change-id
```

### Steps — automatic fixup (absorb)

```bash
# Suppose you've made several small edits across files that all
# logically belong in earlier commits in the local stack.

# After making the edits:
jj st                 # see the changes in @
jj absorb             # auto-distribute each hunk to the closest mutable
                      # ancestor that touched the same lines

# What absorb did: each hunk was moved to the most-likely target.
# Hunks that couldn't be uniquely placed stay in @.
jj op show -p         # inspect what absorb decided, hunk-by-hunk
```

### Checkpoint

- The target commits' diffs now include the fix.
- Change-ids are stable; commit hashes have changed.
- `jj evolog` shows the rewrite history per change.

### If it goes wrong

- Wrong squash target → `jj op undo` rolls the squash back.
- Absorb picked the wrong destination → `jj op undo`, then do manual
  squash with the explicit `--into <change-id>`.
- Squashed into an immutable commit (e.g. one already on origin/main)
  → jj will refuse with a clear error. Either abandon the change or
  rebase the immutable commit's mutable descendants first.

---

## Mission 5 — Two parallel changes, two PRs

Replace the "I'm on a branch" mental model. Make two unrelated changes
on top of trunk *at the same time*, push as two separate bookmarks.

### Goal

- Hold two in-progress commits without context switching.
- See bookmarks anchored on specific commits, not "switched to."
- Push two PRs from one local repo state.

### Trigger

Next time you'd otherwise have stash-juggled or context-switched. A
common shape in this repo: a flox upgrade you want to do *and* an
unrelated feat or doc change you want to do, both starting from the
same trunk tip.

### Steps

```bash
# Start change A from main.
jj new main
$EDITOR ...                          # do the change A work
jj describe -m "feat(a): description"

# Start change B — also from main, NOT from A.
jj new main
$EDITOR ...                          # do the change B work
jj describe -m "feat(b): description"

# `jj l` now shows main with two parallel descendants:
#   o  <change-b> @ feat(b): description
#   | o  <change-a>   feat(a): description
#   |/
#   o  <main>         (last trunk commit)

# Anchor each with a bookmark for pushing.
jj b create feat-a -r <change-id-of-a>
jj b create feat-b -r <change-id-of-b>

# Push both. Soft-serve gets two refs that can become two PRs.
jj git push --bookmark feat-a
jj git push --bookmark feat-b
```

### Checkpoint

- `jj l` shows trunk with two parallel descendants, each carrying its
  own bookmark.
- Soft-serve has both `feat-a` and `feat-b` as refs.
- You did not stash, did not branch-switch, did not lose context.

### If it goes wrong

- Started B on top of A by mistake (B's parent is A, not main) →
  `jj rebase -r <change-id-of-b> -d main` to move B onto main alone.
- Created the wrong bookmark name → `jj b rename old new` or
  `jj b delete <name>` and create again.
- Pushed but want to drop one bookmark → `jj b delete feat-a` then
  `jj git push --deleted` to propagate.

---

## Mission 6 — Disaster-recovery rehearsal (deliberate)

The only mission you do *deliberately* rather than wait for. You cannot
learn the safety net by waiting to need it; rehearsal is the only way.
Schedule this for a calm half-hour.

### Goal

- Build muscle memory for `jj op log` and `jj op restore`.
- See firsthand that *every* operation is undoable.
- Earn the right to experiment freely in jj from this point on.

### Trigger

Deliberate. Pick a calm day. Repeat once on each new repo you adopt jj into.

### Steps

```bash
# Note the current operation id BEFORE doing anything.
jj op log -l 1
# Output line starts with an op id, e.g. "abcd1234".
# Memorize / copy this; it's your "safe state" anchor.

# Now do something obviously bad. Pick one:
jj abandon main             # drops the commit @ points at, including main
# or:
jj squash --into <random-old-change-id>   # squash @ into the wrong place
# or:
jj b delete main && jj git push --deleted # delete bookmark locally
                                          # (don't actually push this; the
                                          # local part is enough to demo)

# Confirm the damage.
jj l                        # main is gone or in the wrong place

# See the operation that caused it.
jj op log -l 5              # the most recent op should be visible
                            # with its op-id and a description

# Roll back to the safe state.
jj op restore abcd1234      # use the op-id you memorized

# Confirm recovery.
jj l                        # main is back where it was
git status                  # also clean
```

### Checkpoint

- The repo state matches step 1 exactly.
- You have personally watched `jj op restore` undo a bad operation.
- You know the op-log lookup → restore flow without re-reading this doc.

### If it goes wrong

- Recovery itself goes wrong → `jj op undo` repeatedly walks backwards
  one op at a time. Eventually you'll be back at a safe state. The op
  log itself is append-only; you cannot lose it.
- This *is* the recovery procedure for real disasters. The whole point
  of the rehearsal is that the procedure is the same either way.

---

## Mission 7 — Sync with soft-serve, rebase, push

Close the on-ramp with the full remote-interaction loop.

### Goal

- Use `jj sync` (alias for `jj git fetch`) to pull remote state.
- Rebase your local mutable commits onto the new trunk tip.
- Push the rebased work, including the safety net of `git.sign-on-push`.

### Trigger

Next time trunk moves on soft-serve while you have local work in
progress. (If you're the only contributor to this repo, you may have to
manufacture this — push from a workspace on another machine, or
manually push a no-op commit from a different clone.)

### Steps

```bash
# Fetch.
jj sync                              # alias for `jj git fetch`

# See the picture.
jj l
# main@origin has advanced past your local main; your in-progress
# bookmark `feat-a` is now behind.

# Rebase your mutable commits onto the new trunk tip.
jj rebase -d 'trunk()' -r 'mutable()'

# `jj l` shows feat-a now sitting on top of the new trunk.

# Push it.
jj git push --bookmark feat-a
```

### Checkpoint

- Soft-serve shows `feat-a` at the same commit as your local
  `jj l -r feat-a`, fast-forwarded onto the new trunk tip.
- All commits in `feat-a` show as signed (✓ in `jj l`).

### If it goes wrong

- Rebase produced conflicts → jj stores them as conflict markers
  *inside* the affected commits (conflict-as-data). `jj l` shows the
  commits with a `conflicted` marker. Resolve by editing the
  conflicted files in the relevant commit:
  ```bash
  jj edit <change-id-of-conflicted-commit>
  $EDITOR <conflicted-files>
  jj new                  # back to a fresh @ when done
  ```
- Push refused with "non-fast-forward" → someone pushed since your
  fetch. `jj sync` again, rebase again, push again.
- Truly stuck → `jj op log` to find the op before the rebase; restore.

---

## Graduation checkpoint

After Mission 7 you have:

- Run jj on real, signed, conventional commits in a real repo.
- Carved a multi-file change into atomic commits without a staging
  area.
- Done both manual and automatic fixups in single steps.
- Held two parallel changes without context-switching.
- Personally watched `jj op restore` recover a deliberately-broken
  state.
- Synced with a remote, rebased, and pushed signed work.

You are not "fluent" — fluency comes from a few hundred more commits.
But you have *every concept* in muscle memory at least once, and the
escape hatches (`jj op undo`, the colocated git escape, the cheatsheet)
are in your pocket.

When you're ready to adopt jj on other projects — especially the
worktree-heavy `/Volumes/ziprecruiter/zr/` setup — re-read the design
doc's Graduation section and use the seven-item checklist there.
