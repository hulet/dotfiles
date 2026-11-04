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
# so an unchanged project costs nothing.
#
# It installs only into a directory that is a mount point, so it can never
# write into the host's own node_modules or .venv if the mount is missing.
# Failures warn and exit 0: the sandbox should start even when an install
# cannot; the next start retries.
set -u
workspace="${1:-${WORKSPACE_DIR:-}}"
[ -n "$workspace" ] || exit 0
cd "$workspace" || exit 0

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
  if "$@"; then
    echo "$hash" > "$stamp"
  else
    echo "sbx-deps-install: '$*' failed; the next start retries" >&2
  fi
}

install_from package-lock.json node_modules npm ci
install_from uv.lock .venv uv sync --frozen
exit 0
