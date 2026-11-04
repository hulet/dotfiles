#!/bin/sh
# Lockfile installs, stamps, the mount-point safety check and failure
# handling of sbx-deps-install.sh.
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/lib.sh"
script="$1/sbx-deps-install.sh"

stub mountpoint '[ "$1" = -q ] && shift; grep -qxF -- "$1" "$WORK/mounted" 2>/dev/null'
stub npm 'echo "npm $*" >> "$WORK/log"; exit "${NPM_EXIT:-0}"'
stub uv 'echo "uv $*" >> "$WORK/log"'
export WORK="$work"

r="$work/node"
mkdir -p "$r/node_modules"
echo v1 > "$r/package-lock.json"
echo node_modules > "$work/mounted"
: > "$work/log"

sh "$script" "$r" >/dev/null 2>&1
check "first run: npm ci" has_line "$work/log" "npm ci"
sh "$script" "$r" >/dev/null 2>&1
check "unchanged lockfile: no second install" [ "$(wc -l < "$work/log")" -eq 1 ]
echo v2 > "$r/package-lock.json"
sh "$script" "$r" >/dev/null 2>&1
check "changed lockfile: installs again" [ "$(wc -l < "$work/log")" -eq 2 ]

echo v3 > "$r/package-lock.json"
: > "$work/log"
NPM_EXIT=1 sh "$script" "$r" >/dev/null 2>&1
status=$?
check "failed install still exits 0" [ "$status" -eq 0 ]
sh "$script" "$r" >/dev/null 2>&1
check "failed install is retried next run" [ "$(grep -c '^npm ci$' "$work/log")" -eq 2 ]

r="$work/unmounted"
mkdir -p "$r/node_modules"
echo v1 > "$r/package-lock.json"
: > "$work/mounted"
: > "$work/log"
out="$(sh "$script" "$r" 2>&1)"
check "never installs into a directory that is not a mount" [ ! -s "$work/log" ]
check "warns when the directory is not private" sh -c 'echo "$1" | grep -q "not sandbox-private"' _ "$out"

r="$work/py"
mkdir -p "$r/.venv"
echo v1 > "$r/uv.lock"
echo .venv > "$work/mounted"
: > "$work/log"
sh "$script" "$r" >/dev/null 2>&1
check "uv.lock: uv sync --frozen" has_line "$work/log" "uv sync --frozen"

r="$work/none"
mkdir -p "$r"
: > "$work/log"
sh "$script" "$r" >/dev/null 2>&1
check "no lockfile: nothing runs" [ ! -s "$work/log" ]
exit $fail
