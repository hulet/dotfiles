#!/usr/bin/env zsh
# sbxc against a stub sbx: create and re-attach paths, kit-name validation.
emulate -L zsh
root=$1
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0
source "$root/sbxc.zsh"

existing=()
sbx() { # stub: `sbx ls -q` prints $existing; anything else is logged
  if [[ $1 == ls ]]; then print -l -- $existing; return 0; fi
  print -r -- "sbx $*" >> "$work/log"
}
expect() { # expect <description> <exact log line>
  if [[ "$(<$work/log)" != "$2" ]]; then
    print -u2 "  not ok: $1"
    print -u2 "    want: $2"
    print -u2 "    got:  $(<$work/log)"
    fail=1
  fi
}
reset() { : > "$work/log"; }

K='git+https://github.com/hulet/dotfiles.git#ref=main&dir=kits'
S='-- --dangerously-skip-permissions --settings /home/agent/sbx-claude-settings.json'
mkdir -p "$work/My App"
cd "$work/My App"

reset; existing=(); sbxc scanners
expect "create with base + named kit" "sbx run claude . --no-share-skills --kit $K/base --kit $K/scanners $S"

reset; existing=(); sbxc scanners base scanners
expect "duplicates collapse" "sbx run claude . --no-share-skills --kit $K/base --kit $K/scanners $S"

reset; existing=(); sbxc -- -p hi
expect "claude args after --" "sbx run claude . --no-share-skills --kit $K/base $S -p hi"

reset; existing=(claude-My-App); sbxc
expect "re-attach by name, no creation-only flags" "sbx run --name claude-My-App $S"

reset; existing=(claude-My-App); warning="$(sbxc scanners 2>&1 >/dev/null)"
expect "re-attach ignores kit names" "sbx run --name claude-My-App $S"
[[ $warning == *"kits are fixed at creation"* ]] || { print -u2 "  not ok: warns about fixed kits"; fail=1; }

reset; existing=(); sbxc ../evil 2>/dev/null
rc=$?
(( rc != 0 )) || { print -u2 "  not ok: rejects a path as a kit name"; fail=1; }
expect "nothing runs for a bad name" ""

exit $fail
