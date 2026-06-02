#!/usr/bin/env python3
"""Save and restore window→workspace arrangements as named profiles.

This sits alongside AeroSpace's native `workspace-to-monitor-force-assignment`
(handled by aerospace-capture-layout.py). The force-assignment block only
controls which workspace lives on which monitor; it cannot move running
windows between workspaces. This tool fills that gap: define one profile per
display configuration (e.g. "dual" vs "builtin"), then apply on demand to
remap windows to their preferred workspaces.

Profiles live in ~/.config/aerospace/profiles.json and are deliberately NOT
tracked under chezmoi. The two laptops this is built for have intentionally
different workspace layouts, so syncing profiles between them would be wrong;
captured window titles also often contain sensitive content (internal repo
names, channel names) we don't want in a public dotfiles repo. The script
(the mechanism) is chezmoi-managed; the captured configuration (this file)
is per-machine and stays local.

Each profile is an ordered list of rules; for each window, the first matching
rule wins. A rule matches when its `app-id` equals the window's bundle id AND
the optional title constraint matches:

  * `title`        case-insensitive substring match against window-title
                   (what `capture` writes; safe for literal titles containing
                   regex metacharacters like *, (, ), etc.)
  * `title-regex`  Python regex via re.search (set this manually when you
                   need pattern matching beyond plain substrings)

If both are set, `title-regex` takes precedence. If neither is set, the rule
matches any window of the app.

Usage:
  aerospace-profile.py list                  Print profile names
  aerospace-profile.py show <name>           Print rules for a profile
  aerospace-profile.py current               Best-match guess against saved profiles
  aerospace-profile.py capture <name>        Snapshot current windows as draft rules
  aerospace-profile.py diff <name>           Show what apply would do (no moves)
  aerospace-profile.py apply <name>          Move windows to match the profile
"""

from __future__ import annotations

import argparse
import json
import re
import socket
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple

DEPLOYED_PROFILES_PATH = Path.home() / ".config" / "aerospace" / "profiles.json"


class ScriptError(RuntimeError):
    """Fatal error with a user-facing message."""


def die(msg: str, code: int = 1) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def run(cmd: List[str], *, capture: bool = True, check: bool = True) -> subprocess.CompletedProcess:
    try:
        return subprocess.run(cmd, check=check, capture_output=capture, text=True)
    except FileNotFoundError as e:
        raise ScriptError(f"required command not found: {cmd[0]}") from e
    except subprocess.CalledProcessError as e:
        stderr = (e.stderr or "").strip()
        raise ScriptError(
            f"{' '.join(cmd)} failed (exit {e.returncode}){': ' + stderr if stderr else ''}"
        ) from e


# ---------------------------------------------------------------------------
# Window enumeration
# ---------------------------------------------------------------------------

# Tab-separated so window titles (which can contain |, spaces, dashes, em-dashes,
# parens, etc.) survive. str.split('\t', 4) caps the split so a tab in a title
# stays attached to the title field instead of mangling the parse.
_LIST_FORMAT = "%{window-id}\t%{app-name}\t%{app-bundle-id}\t%{workspace}\t%{window-title}"


@dataclass(frozen=True)
class Window:
    window_id: int
    app_name: str
    app_id: str
    workspace: str
    title: str


def list_windows() -> List[Window]:
    proc = run(["aerospace", "list-windows", "--all", "--format", _LIST_FORMAT])
    windows: List[Window] = []
    for line in proc.stdout.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t", 4)
        if len(parts) < 4:
            raise ScriptError(f"could not parse list-windows row: {line!r}")
        wid, app, bid, ws = parts[0], parts[1], parts[2], parts[3]
        title = parts[4] if len(parts) == 5 else ""
        try:
            wid_int = int(wid)
        except ValueError as e:
            raise ScriptError(f"non-integer window-id {wid!r} in {line!r}") from e
        windows.append(
            Window(window_id=wid_int, app_name=app, app_id=bid, workspace=ws, title=title)
        )
    return windows


# ---------------------------------------------------------------------------
# Profiles model + I/O
# ---------------------------------------------------------------------------


@dataclass
class Rule:
    app_id: str
    workspace: str
    title: Optional[str] = None         # Case-insensitive substring match.
    title_regex: Optional[str] = None   # Python regex (re.search). Wins over `title`.

    def to_json(self) -> dict:
        d: Dict[str, str] = {"app-id": self.app_id, "workspace": self.workspace}
        if self.title is not None:
            d["title"] = self.title
        if self.title_regex is not None:
            d["title-regex"] = self.title_regex
        return d

    @classmethod
    def from_json(cls, raw: dict) -> "Rule":
        try:
            return cls(
                app_id=raw["app-id"],
                workspace=str(raw["workspace"]),
                title=raw.get("title"),
                title_regex=raw.get("title-regex"),
            )
        except KeyError as e:
            raise ScriptError(f"rule missing required field: {e}") from e

    def matches(self, window: Window) -> bool:
        if window.app_id != self.app_id:
            return False
        if self.title_regex is not None:
            try:
                return re.search(self.title_regex, window.title) is not None
            except re.error as e:
                raise ScriptError(
                    f"invalid regex {self.title_regex!r} in rule for {self.app_id}: {e}"
                ) from e
        if self.title is not None:
            return self.title.lower() in window.title.lower()
        return True


@dataclass
class Profile:
    name: str
    rules: List[Rule] = field(default_factory=list)

    def to_json(self) -> dict:
        return {"rules": [r.to_json() for r in self.rules]}

    @classmethod
    def from_json(cls, name: str, raw: dict) -> "Profile":
        rules_raw = raw.get("rules", [])
        if not isinstance(rules_raw, list):
            raise ScriptError(f"profile {name!r}: 'rules' must be a list")
        return cls(name=name, rules=[Rule.from_json(r) for r in rules_raw])

    def lookup(self, window: Window) -> Optional[Rule]:
        for rule in self.rules:
            if rule.matches(window):
                return rule
        return None


@dataclass
class ProfileStore:
    path: Path
    profiles: Dict[str, Profile] = field(default_factory=dict)

    @classmethod
    def load(cls, path: Path) -> "ProfileStore":
        if not path.exists():
            return cls(path=path, profiles={})
        try:
            data = json.loads(path.read_text())
        except json.JSONDecodeError as e:
            raise ScriptError(f"{path}: invalid JSON: {e}") from e
        profiles_raw = data.get("profiles", {})
        if not isinstance(profiles_raw, dict):
            raise ScriptError(f"{path}: top-level 'profiles' must be an object")
        profiles = {
            name: Profile.from_json(name, raw)
            for name, raw in profiles_raw.items()
        }
        return cls(path=path, profiles=profiles)

    def save(self) -> None:
        payload = {
            "profiles": {
                name: self.profiles[name].to_json()
                for name in sorted(self.profiles.keys())
            }
        }
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.path.with_suffix(self.path.suffix + ".tmp")
        tmp.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n")
        tmp.replace(self.path)


# ---------------------------------------------------------------------------
# Plan computation
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class PlanItem:
    window: Window
    target_workspace: Optional[str]  # None means "no rule matched"
    rule: Optional[Rule]

    @property
    def needs_move(self) -> bool:
        return self.target_workspace is not None and self.target_workspace != self.window.workspace


def compute_plan(profile: Profile, windows: List[Window]) -> List[PlanItem]:
    plan: List[PlanItem] = []
    for w in windows:
        rule = profile.lookup(w)
        target = rule.workspace if rule is not None else None
        plan.append(PlanItem(window=w, target_workspace=target, rule=rule))
    return plan


def print_plan(plan: List[PlanItem]) -> None:
    if not plan:
        print("(no windows)")
        return
    moves = unmatched = unchanged = 0
    for item in plan:
        w = item.window
        title = w.title or "<no title>"
        label = f"{w.app_name} [{w.window_id}] '{title}'"
        if item.target_workspace is None:
            print(f"  {label}: ws {w.workspace} (no rule matched)")
            unmatched += 1
        elif item.needs_move:
            print(
                f"  {label}: ws {w.workspace} -> ws {item.target_workspace}"
            )
            moves += 1
        else:
            print(f"  {label}: ws {w.workspace} (already in place)")
            unchanged += 1
    print()
    print(f"summary: {moves} moves, {unchanged} unchanged, {unmatched} unmatched")


# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------


def resolve_store_path(override: Optional[Path]) -> Path:
    if override is not None:
        return override
    # Prefer the deployed location so users don't need chezmoi in PATH for
    # read-only operations. Capture writes both source and deployed (handled
    # in cmd_capture).
    if DEPLOYED_PROFILES_PATH.exists():
        return DEPLOYED_PROFILES_PATH
    return DEPLOYED_PROFILES_PATH  # default new-file location


def cmd_list(args: argparse.Namespace) -> int:
    store = ProfileStore.load(resolve_store_path(args.profiles))
    if not store.profiles:
        print("(no profiles defined yet — try `capture <name>`)")
        return 0
    for name in sorted(store.profiles):
        n = len(store.profiles[name].rules)
        print(f"{name}  ({n} rule{'s' if n != 1 else ''})")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    store = ProfileStore.load(resolve_store_path(args.profiles))
    profile = store.profiles.get(args.name)
    if profile is None:
        die(f"no profile named {args.name!r}. Known: {', '.join(sorted(store.profiles)) or '(none)'}")
    print(json.dumps({args.name: profile.to_json()}, indent=2, ensure_ascii=False))
    return 0


def cmd_capture(args: argparse.Namespace) -> int:
    store_path = resolve_store_path(args.profiles)
    store = ProfileStore.load(store_path)

    if args.name in store.profiles and not args.yes:
        ans = input(f"profile {args.name!r} already exists. Overwrite? [y/N] ").strip().lower()
        if ans not in {"y", "yes"}:
            print("aborted.")
            return 0

    windows = list_windows()
    if not windows:
        die("no windows returned from aerospace list-windows; is AeroSpace running?")

    # Group by (app_id, title) so identical entries collapse. Multiple windows
    # of the same app with different titles emit separate rules; the user can
    # then turn titles into regex generalisations.
    rules: List[Rule] = []
    seen: set = set()
    for w in windows:
        # Skip empty/transient windows that AeroSpace sometimes lists with no
        # title and a workspace we wouldn't want to pin — caller can re-add.
        key = (w.app_id, w.title, w.workspace)
        if key in seen:
            continue
        seen.add(key)
        rules.append(
            Rule(
                app_id=w.app_id,
                workspace=w.workspace,
                title=w.title if w.title else None,
            )
        )

    # Stable order: titled rules first (more specific), then fallback (no title).
    # Within each group, sort by app_id then title.
    def sort_key(r: Rule) -> Tuple[int, str, str]:
        return (0 if r.title else 1, r.app_id, r.title or "")

    rules.sort(key=sort_key)

    store.profiles[args.name] = Profile(name=args.name, rules=rules)

    if args.dry_run:
        print(json.dumps({args.name: store.profiles[args.name].to_json()}, indent=2, ensure_ascii=False))
        return 0

    store.save()
    print(f"wrote {len(rules)} rule(s) to {store_path}")

    print()
    print(f"draft rules written. Edit {store_path} to:")
    print("  - shorten titles to distinctive substrings (e.g. 'Productivity')")
    print("  - delete overly-specific titles where any window of that app should match")
    print("  - swap 'title' for 'title-regex' if you need real regex matching")
    print("  - reorder: first match wins, so put specific rules before fallbacks")
    return 0


def cmd_diff(args: argparse.Namespace) -> int:
    store = ProfileStore.load(resolve_store_path(args.profiles))
    profile = store.profiles.get(args.name)
    if profile is None:
        die(f"no profile named {args.name!r}.")
    plan = compute_plan(profile, list_windows())
    print(f"plan for profile {args.name!r}:")
    print_plan(plan)
    return 0


def cmd_apply(args: argparse.Namespace) -> int:
    store = ProfileStore.load(resolve_store_path(args.profiles))
    profile = store.profiles.get(args.name)
    if profile is None:
        die(f"no profile named {args.name!r}.")
    plan = compute_plan(profile, list_windows())
    moves = [item for item in plan if item.needs_move]

    if not moves:
        print(f"profile {args.name!r}: nothing to move.")
        unmatched = [item for item in plan if item.target_workspace is None]
        if unmatched:
            print(f"  ({len(unmatched)} window(s) had no matching rule)")
        return 0

    print(f"plan for profile {args.name!r}:")
    print_plan(plan)
    print()

    if not args.yes:
        ans = input(f"apply {len(moves)} move(s)? [y/N] ").strip().lower()
        if ans not in {"y", "yes"}:
            print("aborted.")
            return 0

    failures = 0
    for item in moves:
        w = item.window
        try:
            run(
                [
                    "aerospace",
                    "move-node-to-workspace",
                    "--window-id",
                    str(w.window_id),
                    item.target_workspace,  # type: ignore[arg-type]
                ]
            )
        except ScriptError as e:
            failures += 1
            print(f"  failed: {w.app_name} [{w.window_id}] -> ws {item.target_workspace}: {e}", file=sys.stderr)
    if failures:
        die(f"{failures} of {len(moves)} moves failed", code=1)
    print(f"applied {len(moves)} move(s).")
    return 0


def cmd_current(args: argparse.Namespace) -> int:
    store = ProfileStore.load(resolve_store_path(args.profiles))
    if not store.profiles:
        die("no profiles defined yet — try `capture <name>` first")
    windows = list_windows()
    if not windows:
        die("no windows returned from aerospace list-windows")

    print(f"comparing {len(windows)} window(s) against {len(store.profiles)} profile(s):")
    best: Optional[Tuple[str, int, int, int]] = None  # (name, matched, in_place, total)
    for name in sorted(store.profiles):
        profile = store.profiles[name]
        plan = compute_plan(profile, windows)
        in_place = sum(1 for p in plan if p.target_workspace is not None and not p.needs_move)
        matched = sum(1 for p in plan if p.target_workspace is not None)
        total = len(plan)
        print(f"  {name:<20}  {in_place}/{total} in place, {matched}/{total} matched a rule")
        if best is None or (in_place, matched) > (best[2], best[1]):
            best = (name, matched, in_place, total)
    if best is not None:
        print()
        print(f"best match: {best[0]!r} ({best[2]}/{best[3]} windows already in expected workspace)")
    return 0


# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="aerospace-profile",
        description="Save/restore window→workspace arrangements as named profiles.",
    )
    p.add_argument(
        "--profiles",
        type=Path,
        default=None,
        help=f"Path to profiles.json (default: {DEPLOYED_PROFILES_PATH})",
    )
    sub = p.add_subparsers(dest="command", required=True)

    s_list = sub.add_parser("list", help="List defined profiles.")
    s_list.set_defaults(func=cmd_list)

    s_show = sub.add_parser("show", help="Print a profile's rules.")
    s_show.add_argument("name")
    s_show.set_defaults(func=cmd_show)

    s_cap = sub.add_parser("capture", help="Snapshot current windows into a profile as draft rules.")
    s_cap.add_argument("name")
    s_cap.add_argument("--yes", "-y", action="store_true", help="Overwrite existing profile without prompting.")
    s_cap.add_argument("--dry-run", action="store_true", help="Print proposed rules; do not write.")
    s_cap.set_defaults(func=cmd_capture)

    s_diff = sub.add_parser("diff", help="Show what `apply` would do.")
    s_diff.add_argument("name")
    s_diff.set_defaults(func=cmd_diff)

    s_apply = sub.add_parser("apply", help="Move windows to match a profile.")
    s_apply.add_argument("name")
    s_apply.add_argument("--yes", "-y", action="store_true", help="Skip confirmation prompt.")
    s_apply.set_defaults(func=cmd_apply)

    s_cur = sub.add_parser("current", help="Best-match guess against saved profiles.")
    s_cur.set_defaults(func=cmd_current)

    return p


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return args.func(args)
    except ScriptError as e:
        die(str(e))
    except KeyboardInterrupt:
        die("interrupted", code=130)


if __name__ == "__main__":
    sys.exit(main())
