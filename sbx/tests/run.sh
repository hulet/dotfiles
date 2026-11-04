#!/bin/sh
# Local checks for dotfiles/sbx/kits and sbxc. Run before pushing kit changes to
# main: sandboxes read kits from main directly, and dotfiles has no CI.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"  # dotfiles/sbx
lib="$root/kits/base/files/home/.local/lib"

if python3 -c 'import yaml' 2>/dev/null; then
  PY="python3 -I"
elif command -v uv >/dev/null 2>&1; then
  PY="uv run --quiet --no-project --with pyyaml python3 -I"
else
  echo "sbx/tests needs PyYAML: pip install pyyaml (or install uv)" >&2
  exit 2
fi
export PY

failed=0
run() { # run <name> <command...>
  name=$1
  shift
  if "$@"; then echo "ok   $name"; else echo "FAIL $name"; failed=1; fi
}

# shellcheck disable=SC2086  # $PY may be a multi-word command (uv run ...)
run "kit specs and catalogs" $PY "$here/check_specs.py" "$root"
run "downloads reject tampering" sh "$here/test_tampered_download.sh" "$root"
run "sbx-workspace-mounts.sh" sh "$here/test_workspace_mounts.sh" "$lib"
run "sbx-deps-install.sh" sh "$here/test_deps_install.sh" "$lib"
run "sbxc" zsh "$here/test_sbxc.zsh" "$root"
if command -v shellcheck >/dev/null 2>&1; then
  run "shellcheck" shellcheck -x -P SCRIPTDIR "$lib"/*.sh "$here"/*.sh
else
  echo "skip shellcheck (not installed)"
fi
exit "$failed"
