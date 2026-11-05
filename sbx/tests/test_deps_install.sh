#!/bin/sh
# Stub bodies are single-quoted on purpose: they expand when the stub runs.
# shellcheck disable=SC2016
# Lockfile installs, stamps, the mount-point safety check and failure
# handling of sbx-deps-install.sh.
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/lib.sh"
script="$1/sbx-deps-install.sh"
check "script exists" [ -f "$script" ]

stub mountpoint '[ "$1" = -q ] && shift; grep -qxF -- "$1" "$WORK/mounted" 2>/dev/null'
stub npm 'echo "npm $*" >> "$WORK/log"; exit "${NPM_EXIT:-0}"'
stub uv 'echo "uv $*" >> "$WORK/log"'
export WORK="$work"
export DEPS_INSTALL_LOCK="$work/lock"

r="$work/node"
mkdir -p "$r/node_modules"
echo v1 > "$r/package-lock.json"
echo node_modules > "$work/mounted"
: > "$work/log"

sh "$script" "$r" >/dev/null 2>&1
check "first run: npm ci" has_line "$work/log" "npm ci"
sh "$script" "$r" >/dev/null 2>&1
check "lock released after a run" no_file "$work/lock"
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
check "not a mount: exits 0" [ $? -eq 0 ]
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
check "no lockfile: exits 0" [ $? -eq 0 ]
check "no lockfile: nothing runs" [ ! -s "$work/log" ]

sh "$script" "$work/py" >/dev/null 2>&1
check "unchanged uv.lock: no second uv sync" [ "$(wc -l < "$work/log")" -eq 0 ]

# A failed install after a success must not leave the old stamp behind.
r="$work/stale"
mkdir -p "$r/node_modules"
echo node_modules > "$work/mounted"
echo v1 > "$r/package-lock.json"
: > "$work/log"
sh "$script" "$r" >/dev/null 2>&1
echo v2 > "$r/package-lock.json"
NPM_EXIT=1 sh "$script" "$r" >/dev/null 2>&1
check "failed install removes the stale stamp" no_file "$r/node_modules/.sbx-deps-install.sha256"
echo v1 > "$r/package-lock.json"
sh "$script" "$r" >/dev/null 2>&1
check "reverting to the old lockfile installs again" [ "$(wc -l < "$work/log")" -eq 3 ]

r="$work/with space"
mkdir -p "$r/node_modules"
echo v1 > "$r/package-lock.json"
: > "$work/log"
sh "$script" "$r" >/dev/null 2>&1
check "workspace path with a space" has_line "$work/log" "npm ci"

out="$(sh "$script" "$work/missing" 2>&1)"
check "missing workspace: exits 0" [ $? -eq 0 ]
check "missing workspace: says so" sh -c 'echo "$1" | grep -q "sbx-deps-install: cannot cd to"' _ "$out"

# Lock held by a live process: wait, give up, install nothing.
r="$work/locked"
mkdir -p "$r/node_modules"
echo v1 > "$r/package-lock.json"
: > "$work/log"
mkdir "$work/lock"
echo $$ > "$work/lock/pid"
DEPS_INSTALL_WAIT=2 sh "$script" "$r" >/dev/null 2>&1
check "live lock: exits 0" [ $? -eq 0 ]
check "live lock: nothing runs" [ ! -s "$work/log" ]
check "live lock: left in place" [ -d "$work/lock" ]
rm -rf "$work/lock"

# Lock left by a dead process: taken over.
mkdir "$work/lock"
echo 999999 > "$work/lock/pid"
DEPS_INSTALL_WAIT=2 sh "$script" "$r" >/dev/null 2>&1
check "dead lock: install runs" has_line "$work/log" "npm ci"
check "dead lock: lock released" no_file "$work/lock"
exit "$fail"
