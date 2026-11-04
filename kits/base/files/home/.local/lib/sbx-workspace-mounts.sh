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
# workspace root only, not git worktrees under it. The mount points are empty
# directories that remain in the host checkout after the sandbox is gone.
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
rc=0
set -f # override entries are literal paths, never globs
for rel in $dirs; do
  case "$rel" in
    /* | .. | ../* | */.. | */../*)
      echo "sbx-workspace-mounts: ignoring $rel (must be relative, without ..)" >&2
      continue
      ;;
  esac
  dir="$workspace/$rel"
  [ -d "$(dirname "$dir")" ] || continue
  if [ -L "$dir" ] || { [ -e "$dir" ] && [ ! -d "$dir" ]; }; then
    echo "sbx-workspace-mounts: skipping $dir (symlink or not a directory)" >&2
    continue
  fi
  mountpoint -q "$dir" && continue
  scratch="$scratch_root/$repo_name-$(echo "$rel" | tr '/' '-')"
  created=0
  [ -d "$dir" ] || created=1
  if mkdir -p "$scratch" "$dir" && chown 1000:1000 "$scratch" && mount --bind "$scratch" "$dir"; then
    echo "sbx-workspace-mounts: mounted $scratch on $dir"
  else
    echo "sbx-workspace-mounts: could not mount $dir" >&2
    if [ "$created" -eq 1 ]; then rmdir "$dir" 2>/dev/null || true; fi
    rc=1
  fi
done
set +f
exit "$rc"
