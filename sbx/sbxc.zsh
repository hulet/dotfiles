# sbxc [kit ...] [-- claude-args]: create or re-attach to this directory's
# Claude Code sandbox. Every sandbox gets the base kit from dotfiles/sbx/kits;
# each name argument adds sbx/kits/<name> (sbx/README.md lists them), so a new
# kit needs no change here. Kits, like --no-share-skills (opting out of the
# shared skills store), apply only at creation, so a re-attach passes neither.
# --settings is a claude argument sbx does not remember; it is passed every
# time.

# The sandbox sbx creates for this directory when no --name is given.
_sbxc_sandbox_name() {
    local name="claude-$(basename "$PWD" | tr -cs 'A-Za-z0-9.+-' '-')"
    print -r -- "${name%-}"
}

sbxc() {
    emulate -L zsh
    local kit_url='git+https://github.com/hulet/dotfiles.git#ref=main&dir=sbx/kits'
    local -a kits=(base) kit_flags=()
    local -a claude_args=(--dangerously-skip-permissions --settings /home/agent/sbx-claude-settings.json)
    local kit name

    while (( $# )) && [[ $1 != -* ]]; do
        # Names only, never paths or URLs: kits come from dotfiles alone.
        if [[ ! $1 =~ '^[a-z0-9-]+$' ]]; then
            print -u2 "sbxc: '$1' is not a kit name (see ~/git/dotfiles/sbx/README.md)"
            return 1
        fi
        kits+=("$1")
        shift
    done
    [[ ${1-} == -- ]] && shift

    name="$(_sbxc_sandbox_name)"
    if sbx ls -q 2>/dev/null | grep -qxF -- "$name"; then
        if (( ${#kits} > 1 )); then
            print -u2 "sbxc: $name already exists and kits are fixed at creation."
            print -u2 "sbxc: to change them, push your work, then: sbx rm $name && sbxc ${kits[2,-1]}"
        fi
        sbx run --name "$name" -- "${claude_args[@]}" "$@"
    else
        for kit in ${(u)kits}; do
            kit_flags+=(--kit "$kit_url/$kit")
        done
        sbx run claude . --no-share-skills "${kit_flags[@]}" -- "${claude_args[@]}" "$@"
    fi
}
