#!/usr/bin/env python3
"""Report which process, if any, holds macOS "secure input".

Why this exists: AeroSpace's alt-* bindings stop firing while some other app
holds secure input. macOS lets an app call EnableSecureEventInput() to claim
exclusive keyboard access (it exists to protect password fields), and while
that claim is active no other process — AeroSpace included — sees the key
events. Buggy apps leave the claim stuck after the password field is gone.

The symptom is indistinguishable from AeroSpace being broken: the config is
fine, the process is healthy, `aerospace list-modes --current` says `main`,
and every binding is still registered. Restarting AeroSpace appears to "fix"
it, which sends you looking at AeroSpace instead of the app that actually
grabbed the keyboard.

IMPORTANT — the reported PID is a lead, not a verdict. macOS exposes a single
`kCGSSessionSecureInputPID`, and it commonly names the *frontmost* app rather
than the process that actually called EnableSecureEventInput. Observed here:
this script named WezTerm (the focused terminal), but quitting **1Password**
released the claim while WezTerm kept running untouched. Treat the named
process as "where the keyboard focus was", then work down the offenders list.

Confirmed culprit on this machine: 1Password — specifically its renderer
helper process, which hosts the password fields, not the main app. Closing the
1Password *window* tears that helper down and releases the claim; the main
process keeps running and stays unlocked, so there is no need to quit or
re-authenticate. Verified: the claim dropped the moment the renderer helper
exited, while the main 1Password process kept a 4-day uptime unbroken.

Others reported upstream
(github.com/nikitabobko/AeroSpace/discussions/1205): KeePassXC >= 2.7.10,
Proton Pass, Discord (with input monitoring enabled), Brave + Bitwarden,
Microsoft Outlook, Ferdium.

Two things that look relevant but are not. A terminal pane at a real password
prompt shows `-echo` *with* `icanon`; ordinary raw-mode TUIs are `-echo` with
`-icanon` and never trigger this — so a terminal being named while none of its
panes match that signature is a sign of misattribution, not a stuck terminal.
And WezTerm's `detect_password_input = false` does not help: that option only
swaps the cursor for a lock glyph, it does not gate secure event input.

To release a stuck claim, prefer locking and unlocking the screen — quitting
the holder is a last resort when it is a terminal full of live work.

Usage:
    aerospace-secure-input.py            # one-shot check, run it while broken
    aerospace-secure-input.py --watch    # poll and log every transition

Exit status is 0 when secure input is free, 1 when it is held, and 2 when the
console session could not be read — so it composes in a shell conditional.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import time

# The console session dict lives on IOResources. Printed as flat text rather
# than parsed as a plist: `ioreg -a` intermittently emits XML that plistlib
# rejects, and this only needs two scalars out of the dict.
IOREG_CMD = ("ioreg", "-w", "0", "-l", "-p", "IOService", "-r", "-c", "IOResources")

SECURE_INPUT_PID = re.compile(r'"kCGSSessionSecureInputPID"=(\d+)')
# Proof the session dict was actually read, so "no PID" means "not held"
# rather than "looked in the wrong place".
SESSION_MARKER = re.compile(r'"kCGSSessionUserNameKey"=')


def read_console_session() -> str | None:
    """Return the IOConsoleUsers text, or None if it could not be read."""
    try:
        out = subprocess.run(
            IOREG_CMD, capture_output=True, text=True, check=True
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return None
    return out if SESSION_MARKER.search(out) else None


def secure_input_pid() -> int | None | bool:
    """PID holding secure input, None if free, False if session unreadable."""
    session = read_console_session()
    if session is None:
        return False
    match = SECURE_INPUT_PID.search(session)
    return int(match.group(1)) if match else None


def describe(pid: int) -> str:
    """Human-readable owner of a PID, falling back to the bare number."""
    try:
        comm = subprocess.run(
            ("ps", "-p", str(pid), "-o", "comm="),
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return f"pid {pid} (process is gone — the claim is stuck)"

    # GUI apps report the full executable path; the bundle name is what the
    # user recognises in the menu bar.
    for part in comm.split(os.sep):
        if part.endswith(".app"):
            return f"{part[: -len('.app')]} (pid {pid}, {comm})"
    return f"{os.path.basename(comm)} (pid {pid})"


def report(pid: int | None | bool, *, prefix: str = "") -> int:
    if pid is False:
        print(f"{prefix}could not read the console session", file=sys.stderr)
        return 2
    if pid is None:
        print(f"{prefix}secure input is NOT held — AeroSpace can see alt-*")
        return 0
    print(f"{prefix}secure input is HELD, attributed to {describe(pid)}")
    print(
        f"{prefix}  ! that PID is often just the frontmost app, not the real"
        " holder — see this script's header"
    )
    print(
        f"{prefix}  → first: close the 1Password window (the confirmed culprit"
        " here) — it stays unlocked, no re-auth needed"
    )
    print(
        f"{prefix}  → or lock and unlock the screen; quitting the named app is"
        " a last resort if it holds live work"
    )
    return 1


def watch(interval: float) -> int:
    """Poll and print only transitions, so the log stays readable overnight."""
    print(f"watching secure input every {interval:g}s (ctrl-c to stop)")
    previous: int | None | bool = object()  # sentinel: force a first report
    try:
        while True:
            current = secure_input_pid()
            if current != previous:
                report(current, prefix=time.strftime("%H:%M:%S "))
                previous = current
            time.sleep(interval)
    except KeyboardInterrupt:
        return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--watch",
        action="store_true",
        help="poll continuously and log each transition instead of exiting",
    )
    parser.add_argument(
        "--interval",
        type=float,
        default=5.0,
        metavar="SECONDS",
        help="poll interval for --watch (default: %(default)s)",
    )
    args = parser.parse_args()

    if args.watch:
        return watch(args.interval)
    return report(secure_input_pid())


if __name__ == "__main__":
    sys.exit(main())
