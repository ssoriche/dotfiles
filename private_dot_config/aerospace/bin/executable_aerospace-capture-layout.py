#!/usr/bin/env python3
"""Capture the current AeroSpace workspace-to-monitor arrangement into the
chezmoi-managed aerospace.toml so the next time these displays are connected
the layout is restored automatically.

The script writes a single [workspace-to-monitor-force-assignment] block, fenced
by marker comments. Each workspace gets a *list* of monitor patterns; AeroSpace
picks the first one that matches an attached monitor, so the same block works
on multiple machines with different displays.

Monitor names are regex-escaped before being written (AeroSpace treats patterns
as case-insensitive regex), and 'built-in' is appended as a final fallback so
workspaces collapse to the laptop display when no external is attached.
"""

from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import shutil
import socket
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path
from typing import Dict, List, Optional, Tuple

MARKER_START = "# >>> aerospace-capture: managed block — edit via aerospace-capture-layout.py"
MARKER_END = "# <<< aerospace-capture"
SECTION_HEADER = "[workspace-to-monitor-force-assignment]"
FALLBACK_PATTERN = "built-in"
CONFIG_REL_PATH = Path("private_dot_config/aerospace/aerospace.toml")


# ---------------------------------------------------------------------------
# Small utilities
# ---------------------------------------------------------------------------


class ScriptError(RuntimeError):
    """Fatal error with a user-facing message."""


def die(msg: str, code: int = 1) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def run(cmd: List[str], *, capture: bool = True, check: bool = True) -> subprocess.CompletedProcess:
    try:
        return subprocess.run(
            cmd,
            check=check,
            capture_output=capture,
            text=True,
        )
    except FileNotFoundError as e:
        raise ScriptError(f"required command not found: {cmd[0]}") from e
    except subprocess.CalledProcessError as e:
        stderr = (e.stderr or "").strip()
        raise ScriptError(
            f"{' '.join(cmd)} failed (exit {e.returncode}){': ' + stderr if stderr else ''}"
        ) from e


def short_hostname() -> str:
    name = socket.gethostname()
    return name.split(".")[0] if name else "unknown-host"


# ---------------------------------------------------------------------------
# AeroSpace data acquisition
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Monitor:
    monitor_id: int
    monitor_name: str


@dataclass(frozen=True)
class WorkspacePlacement:
    workspace: str
    monitor_name: str


def list_monitors() -> List[Monitor]:
    proc = run(["aerospace", "list-monitors", "--json"])
    data = json.loads(proc.stdout)
    return [Monitor(int(m["monitor-id"]), m["monitor-name"]) for m in data]


def list_workspaces_with_monitors() -> List[WorkspacePlacement]:
    proc = run(
        [
            "aerospace",
            "list-workspaces",
            "--monitor",
            "all",
            "--empty",
            "no",
            "--format",
            "%{workspace}\t%{monitor-name}",
        ]
    )
    out: List[WorkspacePlacement] = []
    for line in proc.stdout.splitlines():
        if not line.strip():
            continue
        ws, _, mon = line.partition("\t")
        if not ws or not mon:
            raise ScriptError(f"could not parse list-workspaces row: {line!r}")
        out.append(WorkspacePlacement(ws.strip(), mon.strip()))
    return out


def display_fingerprint(monitors: List[Monitor]) -> str:
    return "|".join(sorted(m.monitor_name for m in monitors))


# ---------------------------------------------------------------------------
# Block parsing & emission
# ---------------------------------------------------------------------------


@dataclass
class Capture:
    host: str
    fingerprint: str
    last: str


@dataclass
class Block:
    captures: List[Capture] = field(default_factory=list)
    # Preserve insertion order of workspaces so re-runs produce stable diffs.
    assignments: "Dict[str, List[str]]" = field(default_factory=dict)


# Lines inside the block we recognise.
_CAPTURE_LINE_RE = re.compile(
    r"^#\s+(?P<host>[^:]+):\s+(?P<fp>.*?)\s+\(last:\s+(?P<last>[^)]+)\)\s*$"
)
_ASSIGN_LINE_RE = re.compile(
    r"^\s*(?P<key>[A-Za-z0-9_-]+|'[^']*'|\"[^\"]*\")\s*=\s*\[(?P<list>[^\]]*)\]\s*$"
)
_SINGLE_QUOTED_RE = re.compile(r"'([^']*)'")
_DOUBLE_QUOTED_RE = re.compile(r'"([^"]*)"')


def _unquote_key(raw: str) -> str:
    if (raw.startswith("'") and raw.endswith("'")) or (
        raw.startswith('"') and raw.endswith('"')
    ):
        return raw[1:-1]
    return raw


def _parse_pattern_list(raw: str) -> List[str]:
    items = _SINGLE_QUOTED_RE.findall(raw)
    if not items:
        items = _DOUBLE_QUOTED_RE.findall(raw)
    return items


def parse_block(text: str) -> Tuple[Optional[Block], Optional[Tuple[int, int]]]:
    """Return (block, (start_line, end_line_inclusive)) or (None, None) if absent.

    Line indices are 1-based and inclusive; suitable for slicing back into the
    file via str.splitlines(keepends=True).
    """
    lines = text.splitlines()
    start = end = None
    for i, line in enumerate(lines):
        if line.rstrip() == MARKER_START:
            start = i
        elif start is not None and line.rstrip() == MARKER_END:
            end = i
            break
    if start is None or end is None:
        return None, None

    block = Block()
    for line in lines[start + 1 : end]:
        s = line.strip()
        if not s:
            continue
        if s == SECTION_HEADER:
            continue
        # Capture comment lines: '#   host: fp  (last: date)'
        m_cap = _CAPTURE_LINE_RE.match(s)
        if m_cap:
            block.captures.append(
                Capture(m_cap["host"].strip(), m_cap["fp"].strip(), m_cap["last"].strip())
            )
            continue
        if s.startswith("# captures:") or s.startswith("#"):
            # Header/blank/other comments — ignore (we re-emit them).
            continue
        m_a = _ASSIGN_LINE_RE.match(s)
        if m_a:
            key = _unquote_key(m_a["key"].strip())
            block.assignments[key] = _parse_pattern_list(m_a["list"])
            continue
        # Unknown line inside our managed block — preserve nothing; we own it.
        # We intentionally don't error so manual additions are simply rewritten.
    return block, (start, end)


def _emit_key(key: str) -> str:
    if re.fullmatch(r"[A-Za-z0-9_-]+", key):
        return key
    # Quote anything fancier.
    escaped = key.replace("'", r"\'")
    return f"'{escaped}'"


def _emit_value(value: str) -> str:
    # TOML literal strings (single quotes) don't process escapes, so a regex
    # like r'DELL P2721Q \(1\)' survives intact.
    if "'" in value:
        # Fall back to basic string with escapes if literal quoting is unsafe.
        escaped = value.replace("\\", "\\\\").replace('"', '\\"')
        return f'"{escaped}"'
    return f"'{value}'"


def emit_block(block: Block) -> str:
    lines: List[str] = [MARKER_START]
    if block.captures:
        lines.append("# captures:")
        for cap in block.captures:
            lines.append(f"#   {cap.host}: {cap.fingerprint}  (last: {cap.last})")
    lines.append(SECTION_HEADER)
    for key, patterns in block.assignments.items():
        rendered = ", ".join(_emit_value(p) for p in patterns)
        lines.append(f"{_emit_key(key)} = [{rendered}]")
    lines.append(MARKER_END)
    return "\n".join(lines)


def splice_block(original: str, new_block: str) -> str:
    lines = original.splitlines(keepends=True)
    start = end = None
    for i, raw in enumerate(lines):
        if raw.rstrip("\n").rstrip() == MARKER_START:
            start = i
        elif start is not None and raw.rstrip("\n").rstrip() == MARKER_END:
            end = i
            break

    new_block_with_trailing = new_block.rstrip() + "\n"
    if start is not None and end is not None:
        replacement = [new_block_with_trailing]
        return "".join(lines[:start] + replacement + lines[end + 1 :])

    if original and not original.endswith("\n"):
        original = original + "\n"
    if original and not original.endswith("\n\n"):
        original = original + "\n"
    return original + new_block_with_trailing


# ---------------------------------------------------------------------------
# Merge logic
# ---------------------------------------------------------------------------


def merge_capture(
    existing: Optional[Block],
    *,
    host: str,
    fingerprint: str,
    captured: List[WorkspacePlacement],
    today: str,
) -> Block:
    block = Block() if existing is None else Block(
        captures=list(existing.captures),
        assignments={k: list(v) for k, v in existing.assignments.items()},
    )

    # Update or insert this host's capture record.
    for i, cap in enumerate(block.captures):
        if cap.host == host:
            block.captures[i] = Capture(host=host, fingerprint=fingerprint, last=today)
            break
    else:
        block.captures.append(Capture(host=host, fingerprint=fingerprint, last=today))

    # For each visible workspace, prepend this monitor pattern (regex-escaped),
    # preserve other-host patterns already present, ensure 'built-in' fallback.
    for placement in captured:
        new_pattern = re.escape(placement.monitor_name)
        existing_list = block.assignments.get(placement.workspace, [])
        merged = [new_pattern]
        for p in existing_list:
            if p == new_pattern:
                continue
            if p == FALLBACK_PATTERN:
                continue  # we add this at the very end
            merged.append(p)
        merged.append(FALLBACK_PATTERN)
        block.assignments[placement.workspace] = merged

    # Stable ordering: numeric workspaces first sorted numerically, then others
    # alphabetically. Keeps diffs predictable across machines.
    def sort_key(k: str) -> Tuple[int, object]:
        try:
            return (0, int(k))
        except ValueError:
            return (1, k)

    block.assignments = {
        k: block.assignments[k] for k in sorted(block.assignments.keys(), key=sort_key)
    }
    return block


# ---------------------------------------------------------------------------
# I/O glue
# ---------------------------------------------------------------------------


def chezmoi_source_path() -> Path:
    proc = run(["chezmoi", "source-path"])
    return Path(proc.stdout.strip())


def default_config_path() -> Path:
    return chezmoi_source_path() / CONFIG_REL_PATH


def read_file(path: Path) -> str:
    try:
        return path.read_text()
    except FileNotFoundError as e:
        raise ScriptError(f"config file not found: {path}") from e


def write_file_atomic(path: Path, content: str) -> None:
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(content)
    tmp.replace(path)


def prompt_yes(question: str, default_no: bool = True) -> bool:
    suffix = " [y/N] " if default_no else " [Y/n] "
    try:
        answer = input(question + suffix).strip().lower()
    except EOFError:
        return False
    if not answer:
        return not default_no
    return answer in {"y", "yes"}


def unified_diff(old: str, new: str, label: str) -> str:
    return "".join(
        difflib.unified_diff(
            old.splitlines(keepends=True),
            new.splitlines(keepends=True),
            fromfile=f"{label} (current)",
            tofile=f"{label} (proposed)",
            n=3,
        )
    )


# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------


def cmd_show(args: argparse.Namespace) -> int:
    host = short_hostname()
    monitors = list_monitors()
    placements = list_workspaces_with_monitors()
    fp = display_fingerprint(monitors)

    print(f"host:        {host}")
    print(f"fingerprint: {fp}")
    print("monitors:")
    for m in monitors:
        print(f"  [{m.monitor_id}] {m.monitor_name}")
    print("workspaces (non-empty):")
    if not placements:
        print("  (none — is AeroSpace running, with windows open?)")
    for p in placements:
        print(f"  {p.workspace:<6} -> {p.monitor_name}")
    return 0


def cmd_capture(args: argparse.Namespace) -> int:
    host = short_hostname()
    config_path: Path = args.config or default_config_path()

    monitors = list_monitors()
    placements = list_workspaces_with_monitors()
    if not placements:
        die(
            "no non-empty workspaces returned from `aerospace list-workspaces`. "
            "Is AeroSpace running with at least one window assigned?"
        )

    fp = display_fingerprint(monitors)
    today_str = date.today().isoformat()

    original = read_file(config_path)
    existing_block, _ = parse_block(original)

    # Same-displays prompt: if this host previously captured the same fingerprint,
    # ask before overwriting.
    if existing_block is not None and not args.yes:
        prior = next((c for c in existing_block.captures if c.host == host), None)
        if prior is not None and prior.fingerprint == fp:
            if not prompt_yes(
                f"A capture for host '{host}' with the same displays already exists "
                f"(last: {prior.last}). Update it?",
                default_no=True,
            ):
                print("aborted.")
                return 0

    merged = merge_capture(
        existing_block,
        host=host,
        fingerprint=fp,
        captured=placements,
        today=today_str,
    )

    new_block_text = emit_block(merged)
    new_text = splice_block(original, new_block_text)

    if new_text == original:
        print("no changes needed — current arrangement already matches the saved layout.")
        return 0

    diff = unified_diff(original, new_text, str(config_path))

    if args.dry_run:
        print("--- proposed generated block ---")
        print(new_block_text)
        print("--- diff against chezmoi source ---")
        sys.stdout.write(diff if diff else "(no textual diff)\n")
        return 0

    print("--- proposed generated block ---")
    print(new_block_text)
    print()
    if not args.yes and not prompt_yes(
        f"Write to {config_path}?", default_no=False
    ):
        print("aborted.")
        return 0

    backup = config_path.with_suffix(config_path.suffix + ".bak")
    shutil.copyfile(config_path, backup)
    write_file_atomic(config_path, new_text)
    print(f"wrote {config_path} (backup: {backup})")

    if args.no_apply:
        print("--no-apply: skipping `chezmoi apply` and `aerospace reload-config`.")
        return 0

    # chezmoi apply, then validate via dry-run reload, then commit reload.
    try:
        run(["chezmoi", "apply"], capture=False)
    except ScriptError as e:
        print(f"chezmoi apply failed: {e}", file=sys.stderr)
        print("restoring backup and re-applying.", file=sys.stderr)
        shutil.copyfile(backup, config_path)
        run(["chezmoi", "apply"], capture=False, check=False)
        return 1

    dry = subprocess.run(
        ["aerospace", "reload-config", "--dry-run"],
        capture_output=True,
        text=True,
    )
    if dry.returncode != 0:
        sys.stderr.write(dry.stderr or dry.stdout)
        print("aerospace reload --dry-run failed: restoring backup.", file=sys.stderr)
        shutil.copyfile(backup, config_path)
        run(["chezmoi", "apply"], capture=False, check=False)
        return 1

    run(["aerospace", "reload-config"], capture=False)
    print("applied and reloaded.")
    return 0


# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="aerospace-capture-layout",
        description=(
            "Capture the current AeroSpace workspace→monitor arrangement into "
            "the chezmoi-managed aerospace.toml. Default action is capture."
        ),
    )
    p.add_argument(
        "--show",
        action="store_true",
        help="Print current host, monitors and workspace placements; no writes.",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the proposed block and a diff without writing.",
    )
    p.add_argument(
        "--yes",
        "-y",
        action="store_true",
        help="Skip confirmation prompts.",
    )
    p.add_argument(
        "--no-apply",
        action="store_true",
        help="Write source but skip `chezmoi apply` and `aerospace reload-config`.",
    )
    p.add_argument(
        "--config",
        type=Path,
        default=None,
        help="Override path to the chezmoi-source aerospace.toml.",
    )
    return p


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        if args.show:
            return cmd_show(args)
        return cmd_capture(args)
    except ScriptError as e:
        die(str(e))
    except KeyboardInterrupt:
        die("interrupted", code=130)


if __name__ == "__main__":
    sys.exit(main())
