# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Non-interactive check (Exit early if not running interactively)
case $- in
    *i*) ;;
    *) return;;
esac

# History Settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000

# Shell Options
shopt -s checkwinsize
shopt -s globstar 2>/dev/null  # Enables recursive globbing (e.g., ls **/*.txt)

# Environment & PATH
export PATH="$HOME/.local/bin:$PATH"

# Friendly lesspipe (portable command check)
if command -v lesspipe >/dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe)"
elif command -v lesspipe.sh >/dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe.sh)"
fi



# Terminal Prompt (Your custom RGB Two-Line Prompt)
case "$TERM" in
    xterm-color|*-256color|xterm-kitty|alacritty) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='\[\e[1;38;2;189;63;190m\]┌──(\[\e[38;2;167;130;236m\]\u\[\e[1;38;2;189;63;190m\]@\[\e[38;2;167;130;236m\]\h\[\e[1;38;2;189;63;190m\])\n└─[\[\e[38;2;255;255;255m\]\w\[\e[1;38;2;189;63;190m\]]-\[\e[38;2;167;130;236m\]$\[\e[0m\] '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt

# Set xterm title dynamically
case "$TERM" in
xterm*|rxvt*|alacritty|kitty)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac


# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'


# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Tab-completion menu navigation
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'
bind '"\t":menu-complete'

nfetch
