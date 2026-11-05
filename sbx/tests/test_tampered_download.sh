#!/bin/sh
# Stub bodies are single-quoted on purpose: they expand when the stub runs.
# shellcheck disable=SC2016
# Every install step that downloads with curl must stop before unpacking or
# running anything when the download does not match its pinned SHA256.
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/lib.sh"
: "${PY:=python3}"
root="${1:-$here/..}"

count="$($PY "$here/extract_curl_steps.py" "$root" "$work/steps")"
check "found at least one download step" [ "$count" -gt 0 ]

# curl writes a tampered file to its -o/--output target; everything that would
# unpack, install or run the download leaves a marker instead.
stub curl "touch \"$work/curl-called\"; "'while [ $# -gt 0 ]; do
  case "$1" in -o|--output) echo tampered > "$2"; shift ;; esac
  shift
done'
stub uname "[ \"\${1:-}\" = -m ] && { echo \"\$FAKE_ARCH\"; exit 0; }; exec \"$real_uname\" \"\$@\""
for cmd in tar unzip install ln chmod chown apt-get mv sudo dpkg gpg mkdir cp; do
  stub "$cmd" "touch \"$work/ran-$cmd\""
done

for step in "$work"/steps/*.sh; do
  [ -e "$step" ] || continue
  for arch in x86_64 aarch64; do
    label="$(basename "$step") ($arch)"
    rm -f "$work"/ran-* "$work/curl-called"
    if FAKE_ARCH=$arch sh "$step" >/dev/null 2>"$work/stderr"; then
      check "$label fails on a tampered download" false
    fi
    check "$label reached curl" [ -e "$work/curl-called" ]
    check "$label failed from the checksum (stderr lacks 'did NOT match')" \
      grep -q "did NOT match" "$work/stderr"
    for marker in "$work"/ran-*; do
      [ -e "$marker" ] && check "$label ran ${marker##*/ran-} before verifying" false
    done
  done
done
exit "$fail"
