#!/bin/sh
# Install a project's dependencies from its lockfile into the sandbox-private
# directories that sbx-workspace-mounts.sh mounts. Runs as the agent user, at
# sandbox start and (docker/sbx-releases#420 workaround) at every session
# start.
#
# Only an unambiguous lockfile triggers an install: package-lock.json ->
# `npm ci`, uv.lock -> `uv sync --frozen`. Other projects (pip -e ., yarn,
# pnpm) are left to their own instructions. An install runs only when the
# lockfile's hash differs from the stamp left by the last successful install,
# so an unchanged project costs nothing. The stamp is removed before an install
# starts, so it only ever means "the last install fully succeeded".
#
# A new sandbox runs this twice at once (the startup command and the first
# session's SessionStart hook). `npm ci` empties node_modules, so the runs are
# serialized with a lock directory outside the private dirs; a second run waits
# (up to DEPS_INSTALL_WAIT seconds, default 600) so its session starts with the
# dependencies installed. A lock whose recorded pid is dead is taken over.
# DEPS_INSTALL_LOCK and DEPS_INSTALL_WAIT exist so tests can override both.
#
# It installs only into a directory that is a mount point, so it can never
# write into the host's own node_modules or .venv if the mount is missing.
# Failures warn and exit 0: the sandbox should start even when an install
# cannot; the next start retries.
set -u
workspace="${1:-${WORKSPACE_DIR:-}}"
[ -n "$workspace" ] || exit 0
if ! cd "$workspace"; then
  echo "sbx-deps-install: cannot cd to $workspace" >&2
  exit 0
fi

lock="${DEPS_INSTALL_LOCK:-${TMPDIR:-/tmp}/sbx-deps-install.lock}"
max_wait="${DEPS_INSTALL_WAIT:-600}"
waited=0
while ! mkdir "$lock" 2>/dev/null; do
  holder="$(cat "$lock/pid" 2>/dev/null)"
  if [ -n "$holder" ] && ! kill -0 "$holder" 2>/dev/null; then
    rm -rf "$lock"
    continue
  fi
  if [ "$waited" -ge "$max_wait" ]; then
    echo "sbx-deps-install: gave up waiting for $lock; not installing" >&2
    exit 0
  fi
  sleep 2
  waited=$((waited + 2))
done
trap 'rm -rf "$lock"' EXIT
echo $$ > "$lock/pid"

install_from() { # install_from <lockfile> <private-dir> <command...>
  lockfile=$1
  dir=$2
  shift 2
  [ -f "$lockfile" ] || return 0
  if ! mountpoint -q "$dir"; then
    echo "sbx-deps-install: $dir is not sandbox-private; not installing from $lockfile" >&2
    return 0
  fi
  stamp="$dir/.sbx-deps-install.sha256"
  hash="$(sha256sum "$lockfile" | cut -d' ' -f1)"
  [ "$(cat "$stamp" 2>/dev/null)" = "$hash" ] && return 0
  echo "sbx-deps-install: $lockfile changed; running $*"
  rm -f "$stamp"
  if "$@"; then
    echo "$hash" > "$stamp"
  else
    echo "sbx-deps-install: '$*' failed; the next start retries" >&2
  fi
}

install_from package-lock.json node_modules npm ci
install_from uv.lock .venv uv sync --frozen
exit 0
