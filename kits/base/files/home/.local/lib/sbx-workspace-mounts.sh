#!/bin/sh
# Bind-mount a project's dependency and build directories from sandbox-local
# disk over the virtiofs workspace mount. Must run as root (mount).
#
# Why: the workspace is the host's checkout. Directories holding
# platform-specific builds would otherwise be shared, so the host's macOS
# install and the sandbox's Linux install overwrite each other; and some build
# tools lose races on virtiofs itself (rolldown's parallel mkdir fails with
# "File exists (os error 17)" in .svelte-kit). Each mount is private to the
# sandbox; the host keeps using its own directory.
#
# The list is detected from files in the workspace root (the table below),
# so a repo without those files gets no mounts. Arguments after the
# workspace, or SCRATCH_MOUNT_DIRS (space-separated), replace detection.
# Idempotent: an existing mount is skipped. Never creates a missing parent
# (e.g. node_modules/.cache when node_modules is absent). Covers the
# workspace root only, not git worktrees under it.
#
# The workspace comes from $1, falling back to $WORKSPACE_DIR: sudo strips the
# variable, both in the manual re-apply command and in the SessionStart hook
# that works around docker/sbx-releases#420 (see kits/base/spec.yaml).
set -eu
workspace="${1:-${WORKSPACE_DIR:-}}"
[ -n "$workspace" ] || exit 0
[ "$#" -eq 0 ] || shift
scratch_root="${SCRATCH_MOUNT_ROOT:-/var/tmp/sbx-workspace}"

has() { # has <file-or-glob...>: does the workspace root contain any of them?
  for pattern in "$@"; do
    for path in "$workspace"/$pattern; do
      [ -e "$path" ] && return 0
    done
  done
  return 1
}

if [ "$#" -gt 0 ]; then
  dirs="$*"
elif [ -n "${SCRATCH_MOUNT_DIRS:-}" ]; then
  dirs="$SCRATCH_MOUNT_DIRS"
else
  # Detector table: project has X -> make Y sandbox-private. Add a line per
  # ecosystem (e.g. Cargo.toml -> target, Gemfile -> vendor/bundle).
  dirs=""
  if has package.json; then dirs="$dirs node_modules"; fi
  if has pyproject.toml 'requirements*.txt'; then dirs="$dirs .venv"; fi
  if has svelte.config.js svelte.config.ts svelte.config.mjs; then dirs="$dirs .svelte-kit"; fi
fi

repo_name="$(basename "$workspace")"
for rel in $dirs; do
  dir="$workspace/$rel"
  [ -d "$(dirname "$dir")" ] || continue
  mountpoint -q "$dir" && continue
  scratch="$scratch_root/$repo_name-$(echo "$rel" | tr '/' '-')"
  mkdir -p "$scratch" "$dir"
  chown 1000:1000 "$scratch"
  mount --bind "$scratch" "$dir"
  echo "sbx-workspace-mounts: mounted $scratch on $dir"
done
