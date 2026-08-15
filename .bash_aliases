#!/bin/bash

#Utility functions

# Check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

CURRENT_SHELL="$(ps -p $$ -o comm=)"

#custom aliases

#fastfetch
if command_exists fastfetch; then
	nfetch() {

		if [[ -n "$TMUX" ]]; then
            # Inside tmux: fall back to built-in ASCII art to prevent broken graphics
            fastfetch --config akame --logo-type builtin
        else
			dir="$HOME/.local/share/fastfetch/images"
			images=("$dir/akame.png" "$dir/momo.png" "$dir/lucy.png" "$dir/motoko.png" "$dir/lain.png")

			# Determine shell and pick image safely
			if [[ -n "$ZSH_VERSION" ]]; then
				# Zsh is 1-indexed by default, so fix that
				local idx=$(( (RANDOM % ${#images[@]}) + 1 ))
				img="${images[$idx]}"
			else
				# Bash (0-indexed)
				local idx=$(( RANDOM % ${#images[@]} ))
				img="${images[$idx]}"
			fi

			fastfetch --config akame --logo "$img"
		fi
	}
	alias cls='clear && nfetch'
	alias cl='clear && nfetch'
else
	alias nfetch='echo "fastfetch is not installed. Please install it to use this command."'
	alias cls='clear'
	alias cl='clear'
fi

alias claer='clear'

#cmatrix
if command_exists cmatrix; then
	alias cmatrix='cmatrix -C magenta -b'
fi

#pipes.sh
if command_exists pipes.sh; then
	alias ppipes='pipes.sh -c 5'
fi

#ani-cli
if command_exists ani-cli; then
	alias anicli='ani-cli --dub'
	alias aacli='ani-cli --dub --rofi'
fi


#pacman
if command_exists pacman; then
	alias pacman='sudo pacman'
	alias pakpurge='pacman -Rcns'
	alias paksearch='pacman -Ss'
	alias pakupdate='pacman -Syu'
	alias pakinstall='pacman -S'
fi

#kitty view image
if command_exists kitty; then
	alias img='kitty +kitten icat'
fi


#edit bash and reload
if command_exists code; then
	alias editshell='code ~/.bashrc ~/.zshrc ~/.bash_aliases && echo Press enter key to continiue && read && reload'
elif command_exists nvim; then #:n and :prev to swap between files
	alias editshell='nvim ~/.bashrc ~/.zshrc ~/.bash_aliases && echo Press enter key to continiue && read && reload'
elif command_exists vim; then #:n and :prev to swap between files
	alias editshell='vim ~/.bashrc ~/.zshrc ~/.bash_aliases && echo Press enter key to continiue && read && reload'
elif command_exists nano; then
	alias editshell='nano ~/.bashrc ~/.zshrc ~/.bash_aliases && echo Press enter key to continiue && read && reload'
fi

#reload bash

# Shell-specific aliases
if [[ "$CURRENT_SHELL" == *bash ]]; then
	alias reload='source ~/.bashrc'
elif [[ "$CURRENT_SHELL" == *zsh ]]; then
	alias reload='source ~/.zshrc'
fi



#arp scan
if command_exists arp-scan; then
	alias arpscan='cd /tmp && sudo arp-scan -l && cd --'
fi



#curl
if command_exists curl; then
	alias myip='curl ifconfig.me && echo'
fi

#tree
if command_exists tree; then
	for i in {1..9}; do
		alias t$i="tree -L $i"
	done
fi

# Docker & Docker Compose
if command_exists docker; then

    # lifesavers
    alias dcup='docker compose up -d'
    alias dcdn='docker compose down'
    alias dcl='docker compose logs'
    alias dclf='docker compose logs -f'
    #I just changed a config ffs
    alias dcr='docker compose down && docker compose up -d && docker compose logs -f'
    # Cleanup 
    alias dcclean='docker system prune -a --volumes'
    alias dcps='docker compose ps'
fi


#tmux
if command_exists tmux; then
    # Auto-attach to last session or start fresh
    alias tm='tmux attach || tmux new-session'
    alias tmls='tmux ls'
    
    # Attach to specific named session
    tma() {
        if [[ -n "$1" ]]; then
            tmux attach -t "$1"
        else
            tmux attach
        fi
    }

    # Create new named session
    tmn() {
        if [[ -n "$1" ]]; then
            tmux new -s "$1"
        else
            tmux new-session
        fi
    }

    # Quick session kill helper
    tmk() {
        if [[ -n "$1" ]]; then
            tmux kill-session -t "$1"
        else
            tmux kill-server
        fi
    }
fi



alias pingg='ping -c 3 google.com'

alias localip="ip -brief addr show | grep UP"

#safety mesures
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

#Shell nav
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias home='cd ~'
alias c='clear'
alias md='mkdir -p'
alias rd='rmdir'


#espressify dev
alias get_idf='. $HOME/esp/esp-idf/export.sh'