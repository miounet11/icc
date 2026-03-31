# vim:ft=zsh
#
# icc ZDOTDIR bootstrap for zsh.
#
# GhosttyKit already uses a ZDOTDIR injection mechanism for zsh (setting ZDOTDIR
# to Ghostty's integration dir). icc also needs to run its integration, but
# we must restore the user's real ZDOTDIR immediately so that:
# - /etc/zshrc sets HISTFILE relative to the real ZDOTDIR/HOME (shared history)
# - zsh loads the user's real .zprofile/.zshrc normally (no wrapper recursion)
#
# We restore ZDOTDIR from (in priority order):
# - GHOSTTY_ZSH_ZDOTDIR (set by GhosttyKit when it overwrote ZDOTDIR)
# - ICC_ZSH_ZDOTDIR (set by icc when it overwrote a user-provided ZDOTDIR)
# - unset (zsh treats unset ZDOTDIR as $HOME)

if [[ -n "${GHOSTTY_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$GHOSTTY_ZSH_ZDOTDIR"
    builtin unset GHOSTTY_ZSH_ZDOTDIR
elif [[ -n "${ICC_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$ICC_ZSH_ZDOTDIR"
    builtin unset ICC_ZSH_ZDOTDIR
else
    builtin unset ZDOTDIR
fi

{
    # zsh treats unset ZDOTDIR as if it were HOME. We do the same.
    builtin typeset _icc_file="${ZDOTDIR-$HOME}/.zshenv"
    [[ ! -r "$_icc_file" ]] || builtin source -- "$_icc_file"
} always {
    if [[ -o interactive ]]; then
        # We overwrote GhosttyKit's injected ZDOTDIR, so manually load Ghostty's
        # zsh integration if available.
        #
        # We can't rely on GHOSTTY_ZSH_ZDOTDIR here because Ghostty's own zsh
        # bootstrap unsets it before chaining into this icc wrapper.
        if [[ "${ICC_LOAD_GHOSTTY_ZSH_INTEGRATION:-0}" == "1" ]]; then
            if [[ -n "${ICC_SHELL_INTEGRATION_DIR:-}" ]]; then
                builtin typeset _icc_ghostty="$ICC_SHELL_INTEGRATION_DIR/ghostty-integration.zsh"
            fi
            if [[ ! -r "${_icc_ghostty:-}" && -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
                builtin typeset _icc_ghostty="$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
            fi
            [[ -r "$_icc_ghostty" ]] && builtin source -- "$_icc_ghostty"
        fi

        # Load icc integration (unless disabled)
        if [[ "${ICC_SHELL_INTEGRATION:-1}" != "0" && -n "${ICC_SHELL_INTEGRATION_DIR:-}" ]]; then
            builtin typeset _icc_integ="$ICC_SHELL_INTEGRATION_DIR/icc-zsh-integration.zsh"
            [[ -r "$_icc_integ" ]] && builtin source -- "$_icc_integ"
        fi
    fi

    builtin unset _icc_file _icc_ghostty _icc_integ
}
