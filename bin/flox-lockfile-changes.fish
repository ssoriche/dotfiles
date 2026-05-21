#!/usr/bin/env fish
# Print the bullet-list diff of dot_flox/env/private_manifest.lock between two
# refs, formatted for jj describe / git commit messages.
#
# Defaults: jj `@-` vs `@` if .jj/ exists, otherwise git HEAD vs working tree.

function _usage
    echo "Usage: flox-lockfile-changes.fish [<old-ref>] [<new-ref>]"
    echo "       flox-lockfile-changes.fish -h | --help"
end

argparse h/help -- $argv
or begin
    _usage >&2
    exit 2
end

if set -q _flag_help
    _usage
    exit 0
end

if test (count $argv) -gt 2
    _usage >&2
    exit 2
end

set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
if test -z "$repo_root"
    echo "flox-lockfile-changes: not inside a git repository" >&2
    exit 2
end

set -l lockfile_rel dot_flox/env/private_manifest.lock
if not test -f "$repo_root/$lockfile_rel"
    echo "flox-lockfile-changes: $lockfile_rel not found in $repo_root" >&2
    exit 2
end

set -l use_jj 0
if test -d "$repo_root/.jj"
    set use_jj 1
end

switch (count $argv)
    case 0
        if test $use_jj -eq 1
            set -g old_ref '@-'
            set -g new_ref '@'
        else
            set -g old_ref HEAD
            set -g new_ref WORKTREE
        end
    case 1
        set -g old_ref $argv[1]
        if test $use_jj -eq 1
            set -g new_ref '@'
        else
            set -g new_ref WORKTREE
        end
    case 2
        set -g old_ref $argv[1]
        set -g new_ref $argv[2]
end

# Emit "pname version" lines, sorted unique, for the lockfile at $ref.
# jj/git stderr is left visible so bad refs surface a clear error.
function _extract --argument-names ref lockfile_rel repo_root use_jj
    if test "$ref" = WORKTREE
        jq -r '.packages[] | "\(.pname) \(.version)"' "$repo_root/$lockfile_rel" | sort -u
        return
    end

    if test $use_jj -eq 1
        jj --repository "$repo_root" file show -r $ref $lockfile_rel \
            | jq -r '.packages[] | "\(.pname) \(.version)"' | sort -u
    else
        git -C "$repo_root" show "$ref:$lockfile_rel" \
            | jq -r '.packages[] | "\(.pname) \(.version)"' | sort -u
    end
end

diff \
    (_extract $old_ref $lockfile_rel $repo_root $use_jj | psub) \
    (_extract $new_ref $lockfile_rel $repo_root $use_jj | psub) \
    | rg '^[<>]' | sed 's/^< /  - /; s/^> /  + /'

# diff exits 1 when files differ; that's success here.
exit 0
