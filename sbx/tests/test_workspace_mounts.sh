#!/bin/sh
# Stub bodies are single-quoted on purpose: they expand when the stub runs.
# shellcheck disable=SC2016
# Detector table, overrides and idempotency of sbx-workspace-mounts.sh.
# Fixture repos are created here at run time.
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/lib.sh"
script="${1:-$here/../kits/base/files/home/.local/lib}/sbx-workspace-mounts.sh"
check "script exists" [ -f "$script" ]

stub mount '[ -n "${FAIL_NM:-}" ] && case "$3" in */node_modules) exit 1;; esac
echo "mount $*" >> "$WORK/log"; echo "$3" >> "$WORK/mounted"'
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
mounts() { # mounts <args...>: run the script, fail loudly unless it exits 0
  sh "$script" "$@" >/dev/null 2>"$work/err"
  status=$?
  check "script exits 0 (args: $*)" [ "$status" -eq 0 ]
}

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

check "no workspace: exits 0 quietly" [ -z "$(env -u WORKSPACE_DIR sh "$script" 2>&1)" ]
env -u WORKSPACE_DIR sh "$script" >/dev/null 2>&1
check "no workspace: exit status 0" [ $? -eq 0 ]

r="$(repo "with space" package.json)"; mounts "$r"
check "workspace path with a space" has_line "$work/log" "mount --bind $work/scratch/with space-node_modules $r/node_modules"

r="$(repo symlink package.json)"; mkdir -p "$work/outside"; ln -s "$work/outside" "$r/node_modules"
mounts "$r"
check "symlinked node_modules: no mount" [ ! -s "$work/log" ]
check "symlinked node_modules: warning printed" grep -q "skipping" "$work/err"

r="$(repo plainfile package.json svelte.config.js node_modules)"; mounts "$r"
check "plain file node_modules: skipped" [ "$(grep -c node_modules "$work/log")" -eq 0 ]
check "plain file node_modules: others still mounted" has_line "$work/log" "mount --bind $work/scratch/plainfile-.svelte-kit $r/.svelte-kit"

r="$(repo badargs)"; mounts "$r" ../escape /abs/path a/../b ok
check "bad overrides rejected, good one kept" [ "$(wc -l < "$work/log")" -eq 1 ]
check "good override mounted" has_line "$work/log" "mount --bind $work/scratch/badargs-ok $r/ok"
check "rejection warned" grep -q "ignoring" "$work/err"

r="$(repo dots package.json)"; mounts "$r" . ./ x/. x/./y
check "dot overrides: nothing mounted" [ ! -s "$work/log" ]
check "dot overrides: warned" grep -q "ignoring" "$work/err"

r="$(repo failmount package.json svelte.config.js)"
FAIL_NM=1 sh "$script" "$r" >/dev/null 2>"$work/err"
check "failed mount: non-zero exit" [ $? -ne 0 ]
check "failed mount: warning" grep -q "could not mount" "$work/err"
check "failed mount: later dir still mounted" has_line "$work/log" "mount --bind $work/scratch/failmount-.svelte-kit $r/.svelte-kit"
check "failed mount: created dir removed" [ ! -e "$r/node_modules" ]

exit "$fail"
