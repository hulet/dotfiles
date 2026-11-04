# shellcheck shell=sh
# shellcheck disable=SC2034  # fail, work and real_uname are used by the scripts that source this file
# Shared helpers for tests/sbx-kits. Source it; it sets `fail` and `work`.
set -u
# Resolve tools before PATH changes; tests stub some of them.
chmod_bin="$(command -v chmod)"
real_uname="$(command -v uname)"
fail=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"
PATH="$work/bin:$PATH"

# macOS has shasum but not always sha256sum; the kit scripts call sha256sum.
if ! command -v sha256sum >/dev/null 2>&1; then
  printf '#!/bin/sh\nexec shasum -a 256 "$@"\n' > "$work/bin/sha256sum"
  "$chmod_bin" +x "$work/bin/sha256sum"
fi

check() { # check <description> <command...>: record a failure, keep going
  desc=$1
  shift
  if "$@"; then :; else echo "  not ok: $desc" >&2; fail=1; fi
}

has_line() { # has_line <file> <exact line>
  [ -f "$1" ] && grep -qxF -- "$2" "$1"
}

no_file() { [ ! -e "$1" ]; }

stub() { # stub <name> <sh body>: put a stub command first on PATH
  printf '#!/bin/sh\n%s\n' "$2" > "$work/bin/$1"
  "$chmod_bin" +x "$work/bin/$1"
}
