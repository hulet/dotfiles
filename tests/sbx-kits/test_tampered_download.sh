#!/bin/sh
# Every install step that downloads with curl must stop before unpacking or
# running anything when the download does not match its pinned SHA256.
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/lib.sh"
root=$1

count="$($PY "$here/extract_curl_steps.py" "$root" "$work/steps")"
check "found at least one download step" [ "$count" -gt 0 ]

# curl writes a tampered file to its -o target; everything that would unpack,
# install or run the download leaves a marker instead.
stub curl 'while [ $# -gt 0 ]; do [ "$1" = -o ] && { echo tampered > "$2"; shift; }; shift; done'
stub uname 'echo "$FAKE_ARCH"'
for cmd in tar unzip install ln chmod chown apt-get mv; do
  stub "$cmd" "touch \"$work/ran-$cmd\""
done

for step in "$work"/steps/*.sh; do
  for arch in x86_64 aarch64; do
    rm -f "$work"/ran-*
    if FAKE_ARCH=$arch sh "$step" >/dev/null 2>&1; then
      check "$(basename "$step") ($arch) fails on a tampered download" false
    fi
    for marker in "$work"/ran-*; do
      [ -e "$marker" ] && check "$(basename "$step") ($arch) ran ${marker##*/ran-} before verifying" false
    done
  done
done
exit $fail
