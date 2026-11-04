#!/bin/sh
# Detector table, overrides and idempotency of sbx-workspace-mounts.sh.
# Fixture repos are created here at run time.
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/lib.sh"
script="$1/sbx-workspace-mounts.sh"

stub mount 'echo "mount $*" >> "$WORK/log"; echo "$3" >> "$WORK/mounted"'
stub mountpoint '[ "$1" = -q ] && shift; grep -qxF -- "$1" "$WORK/mounted" 2>/dev/null'
stub chown ':'
export WORK="$work" SCRATCH_MOUNT_ROOT="$work/scratch"

repo() { # repo <name> <files...>: fresh fixture repo with empty files
  dir="$work/$1"
  shift
  mkdir -p "$dir"
  for f in "$@"; do touch "$dir/$f"; done
  : > "$work/log"
  : > "$work/mounted"
  echo "$dir"
}
mounts() { sh "$script" "$@" >/dev/null; }

r="$(repo node package.json)"; mounts "$r"
check "node: node_modules" has_line "$work/log" "mount --bind $work/scratch/node-node_modules $r/node_modules"
check "node: only one mount" [ "$(wc -l < "$work/log")" -eq 1 ]

r="$(repo py pyproject.toml)"; mounts "$r"
check "pyproject: .venv" has_line "$work/log" "mount --bind $work/scratch/py-.venv $r/.venv"

r="$(repo req requirements-dev.txt)"; mounts "$r"
check "requirements*.txt: .venv" has_line "$work/log" "mount --bind $work/scratch/req-.venv $r/.venv"

r="$(repo svelte package.json svelte.config.js)"; mounts "$r"
check "svelte: node_modules" has_line "$work/log" "mount --bind $work/scratch/svelte-node_modules $r/node_modules"
check "svelte: .svelte-kit" has_line "$work/log" "mount --bind $work/scratch/svelte-.svelte-kit $r/.svelte-kit"

r="$(repo empty)"; mounts "$r"
check "empty repo: no mounts" [ ! -s "$work/log" ]

r="$(repo again package.json)"; mounts "$r"; mounts "$r"
check "idempotent: second run mounts nothing new" [ "$(wc -l < "$work/log")" -eq 1 ]

r="$(repo args package.json)"; mounts "$r" build
check "arguments override detection" has_line "$work/log" "mount --bind $work/scratch/args-build $r/build"
check "arguments replace the detected list" [ "$(wc -l < "$work/log")" -eq 1 ]

r="$(repo envvar)"; SCRATCH_MOUNT_DIRS="dist out" sh "$script" "$r" >/dev/null
check "SCRATCH_MOUNT_DIRS overrides detection" [ "$(wc -l < "$work/log")" -eq 2 ]

r="$(repo noparent)"; mounts "$r" node_modules/.cache
check "never creates a missing parent" [ ! -e "$r/node_modules" ]

r="$(repo fromenv package.json)"; WORKSPACE_DIR="$r" sh "$script" >/dev/null
check "workspace falls back to WORKSPACE_DIR" has_line "$work/log" "mount --bind $work/scratch/fromenv-node_modules $r/node_modules"

check "no workspace: exits 0 quietly" env -u WORKSPACE_DIR sh "$script"
exit $fail
