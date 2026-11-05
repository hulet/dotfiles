#!/bin/sh
# Stub bodies are single-quoted on purpose: they expand when the stub runs.
# shellcheck disable=SC2016
# sbxc against a stub sbx: create and re-attach paths, kit-name validation.
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/lib.sh"
sbxc="${1:-$here/..}/sbxc"
check "sbxc is executable" [ -x "$sbxc" ]

# `sbx ls -q` prints $EXISTING (or fails if $LS_FAILS is set); anything else is logged.
stub sbx 'if [ "$1" = ls ]; then
  if [ -n "${LS_FAILS:-}" ]; then echo "sbx: daemon not running" >&2; exit 1; fi
  [ -z "${EXISTING:-}" ] || echo "$EXISTING"; exit 0
fi
echo "sbx $*" >> "$WORK/log"'
export WORK="$work"

run_sbxc() { # run_sbxc <existing sandbox or ''> <sbxc args...>
  existing=$1
  shift
  : > "$work/log"
  EXISTING=$existing "$sbxc" "$@"
}

# shellcheck disable=SC2329  # called through check
log_is() { # log_is <exact log>
  [ "$(cat "$work/log")" = "$1" ] && return 0
  echo "    want: $1" >&2
  echo "    got:  $(cat "$work/log")" >&2
  return 1
}

K='git+https://github.com/hulet/dotfiles.git#ref=main&dir=sbx/kits'
S='-- --settings /home/agent/sbx-claude-settings.json'
mkdir -p "$work/My App"
cd "$work/My App" || exit 1

run_sbxc '' scanners
check "create with base + named kit" log_is "sbx run claude . --name claude-My-App --skills=off --kit $K/base --kit $K/scanners $S"

run_sbxc '' scanners base scanners
check "duplicates collapse" log_is "sbx run claude . --name claude-My-App --skills=off --kit $K/base --kit $K/scanners $S"

run_sbxc '' -- -p hi
check "claude args after --" log_is "sbx run claude . --name claude-My-App --skills=off --kit $K/base $S -p hi"

run_sbxc claude-My-App
check "re-attach by name, no creation-only flags" log_is "sbx run --name claude-My-App $S"

run_sbxc claude-My-App base
check "naming only base re-attaches" log_is "sbx run --name claude-My-App $S"

if error="$(run_sbxc claude-My-App scanners base scanners 2>&1 >/dev/null)"; then
  echo "  not ok: exits non-zero for kit names on an existing sandbox" >&2
  fail=1
fi
check "nothing runs for kit names on an existing sandbox" log_is ""
case $error in
  *"kits are fixed at creation"*"sbx rm claude-My-App && sbxc scanners") ;;
  *) echo "  not ok: explains how to change kits" >&2; fail=1 ;;
esac

if run_sbxc '' ../evil 2>/dev/null; then
  echo "  not ok: rejects a path as a kit name" >&2
  fail=1
fi
check "nothing runs for a bad name" log_is ""

error="$(run_sbxc '' 'foo\cbar' 2>&1 >/dev/null)"
case $error in
  *"'foo\cbar' is not a kit name (see "*) ;;
  *) echo "  not ok: shows a bad name verbatim (got: $error)" >&2; fail=1 ;;
esac

if error="$(LS_FAILS=1 run_sbxc '' 2>&1 >/dev/null)"; then
  echo "  not ok: exits non-zero when sbx ls fails" >&2
  fail=1
fi
check "nothing runs when sbx ls fails" log_is ""
case $error in
  *"daemon not running"*) ;;
  *) echo "  not ok: shows the sbx ls error" >&2; fail=1 ;;
esac

exit "$fail"
