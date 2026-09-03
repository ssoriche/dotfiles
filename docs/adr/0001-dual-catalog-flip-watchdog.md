# Dual-catalog packages: a CI watchdog PRs the catalog flip; Renovate follows pkg-path

Some packages (claude-code, herdr) exist in both the nixpkgs catalog (bare
`pkg-path`) and the flox catalog (`flox/` prefix), and which side tracks
upstream faster flips over time — claude-code has gone nixpkgs→flox→nixpkgs→flox.
The lagging side is only stale, never broken, but stale is real capability loss:
nixpkgs' claude-code 2.1.245 shipped without model access flox's 2.1.258 had.
We decided a nightly Woodpecker cron (`.woodpecker/flox-catalog-lag.yaml`)
compares the two catalogs per package and opens a PR flipping `pkg-path` + pin
when the other side is strictly ahead, while Renovate's dedicated regex manager
captures its query name from the `pkg-path` line so it tracks whichever catalog
the manifest currently points at with no config edit on a flip.

## Considered Options

- **Renovate-native switching — rejected as impossible.** A Renovate dependency
  binds to exactly one packageName and datasource; a regex manager rewrites only
  the captured `currentValue`, never a different line (`pkg-path`) conditioned
  on which registry won; custom datasources take a single registry URL, so there
  is no "merge both feeds, take the max" — and even a merged feed couldn't say
  which catalog to resolve from.
- **Issue-filing watchdog instead of a PR — rejected.** Originally proposed on
  the theory that lag costs only staleness; the Fable 5.1 gap showed staleness
  is capability loss, so the watchdog does the work and a human only merges.
- **Watchdog edits renovate.json on flip — rejected.** Automating JSON surgery
  is fragile; instead the Renovate manager was made catalog-agnostic once
  (packageName captured from `pkg-path`), so a flip is a two-line manifest edit.

## Consequences

- The dual-catalog deps carry a `-pin` depName suffix (`claude-code-pin`) so a
  packageRule can disable the bare-key duplicates from the all-systems manager
  by depName alone. depName is the only workable discriminator: on the nixpkgs
  side of a flip both deps share a packageName, so a packageName match would
  disable both, and RE2 (no negative lookahead) can't exclude the keys from the
  all-systems manager's regex.
- Each dual-catalog manifest block must stay contiguous in
  pkg-path/pkg-group/version order: RE2 has no backreferences to tie the key
  across lines, so the manager matches the block as a unit and silently stops
  matching on reorder.
- Adding a dual-catalog package means updating three lists: `PACKAGES` in
  `flox-catalog-lag.sh`, the key alternation in the dedicated manager, and the
  disabling packageRule's `matchDepNames`.
- The flip commit is authored `woodpecker-ci+catalog@noreply.git.s8i.app`, not
  the relock bot's exact address, so flox-relock's `not_bot` string-equality
  guard still runs the PR resolution check and the post-merge relock.
- "Strictly ahead" is judged on the newest version resolvable on **all three**
  `[options].systems` (mirroring the Renovate datasource transform), so a flip
  can't land a pin one system cannot lock; ties don't flip.
- The pipeline rides the existing nightly cron (any `event: cron` pipeline
  fires on it — nothing to provision) and therefore shares the documented
  silent-death mode: if `forgejo_token` stops allowing the cron event, the
  pipeline stops compiling with no visible failure.
