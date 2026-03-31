# vim:ft=zsh
#
# Compatibility shim: with the current integration model, icc restores
# ZDOTDIR in .zshenv so this file should never be reached. If it is, restore
# ZDOTDIR and behave like vanilla zsh by sourcing the user's .zprofile.

if [[ -n "${GHOSTTY_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$GHOSTTY_ZSH_ZDOTDIR"
    builtin unset GHOSTTY_ZSH_ZDOTDIR
elif [[ -n "${ICC_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$ICC_ZSH_ZDOTDIR"
    builtin unset ICC_ZSH_ZDOTDIR
else
    builtin unset ZDOTDIR
fi

builtin typeset _icc_file="${ZDOTDIR-$HOME}/.zprofile"
[[ ! -r "$_icc_file" ]] || builtin source -- "$_icc_file"
builtin unset _icc_file
