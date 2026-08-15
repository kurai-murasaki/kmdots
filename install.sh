#!/usr/bin/env bash
#
# kmdots installer
#
# Symlinks dotfiles from ~/.kmdots into $HOME, and symlinks the
# oh-my-zsh theme into the omz custom themes dir (if/when omz exists).
#
# Safe to re-run at any time (e.g. after installing oh-my-zsh later) —
# it will just fix up whatever's missing. If it's already at ~/.kmdots,
# it's a no-op relocation-wise.

set -euo pipefail

REPO_DIR="$HOME/.kmdots"
BACKUP_DIR="$HOME/.kmdots-backup-$(date +%Y%m%d-%H%M%S)"

# Where THIS script actually lives right now (resolves symlinks too).
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# file_in_repo -> target_in_home
declare -A DOTFILES=(
    [".bashrc"]="$HOME/.bashrc"
    [".zshrc"]="$HOME/.zshrc"
    [".bash_aliases"]="$HOME/.bash_aliases"
    [".tmux.conf"]="$HOME/.tmux.conf"
)

THEME_FILE="themes/kali-like.zsh-theme"

# ---------------------------------------------------------------------------

info()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
err()   { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; }

confirm() {
    local prompt="$1"
    local reply
    read -r -p "$prompt [y/N] " reply
    case "$reply" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Symlink $src -> $dst.
# If $dst already exists:
#   - if it's already the correct symlink, do nothing
#   - if it's a symlink pointing elsewhere, just replace it (no backup needed,
#     it's not real data)
#   - if it's a real file/dir, back it up first, then replace it
link_file() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        warn "Skipping $dst — source $src does not exist in repo"
        return
    fi

    if [ -L "$dst" ]; then
        if [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
            ok "$dst already linked correctly"
            return
        fi
        info "Replacing stale symlink $dst"
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        info "Backing up existing $dst -> $BACKUP_DIR/"
        mv "$dst" "$BACKUP_DIR/"
    fi

    ln -s "$src" "$dst"
    ok "Linked $dst -> $src"
}

install_dotfiles() {
    for repo_rel in "${!DOTFILES[@]}"; do
        link_file "$REPO_DIR/$repo_rel" "${DOTFILES[$repo_rel]}"
    done
}

# Figures out where oh-my-zsh's custom themes dir lives, if omz is installed.
resolve_omz_custom_themes_dir() {
    local custom="${ZSH_CUSTOM:-}"

    if [ -z "$custom" ]; then
        if [ -d "$HOME/.oh-my-zsh" ]; then
            custom="$HOME/.oh-my-zsh/custom"
        fi
    fi

    if [ -n "$custom" ]; then
        echo "$custom/themes"
    fi
}

install_theme() {
    local theme_src="$REPO_DIR/$THEME_FILE"

    if [ ! -f "$theme_src" ]; then
        warn "Theme file $theme_src not found, skipping theme install"
        return
    fi

    local themes_dir
    themes_dir="$(resolve_omz_custom_themes_dir)"

    if [ -z "$themes_dir" ]; then
        warn "oh-my-zsh not detected — skipping theme symlink for now."
        warn "Re-run this script (./install.sh) after installing oh-my-zsh"
        warn "and it'll pick the theme up then."
        return
    fi

    mkdir -p "$themes_dir"
    link_file "$theme_src" "$themes_dir/$(basename "$THEME_FILE")"
}

# If this script is being run from somewhere other than ~/.kmdots
# (e.g. a plain `git clone <url>` left it in ./kmdots), relocate the
# whole repo to ~/.kmdots and re-exec install.sh from its new home.
relocate_repo_if_needed() {
    if [ "$SCRIPT_DIR" = "$REPO_DIR" ]; then
        return
    fi

    if [ -e "$REPO_DIR" ]; then
        err "$REPO_DIR already exists, but this script is running from"
        err "$SCRIPT_DIR — refusing to guess which one you want."
        err "Resolve/remove one of them and re-run."
        exit 1
    fi

    if [ ! -d "$SCRIPT_DIR/.git" ]; then
        err "$SCRIPT_DIR doesn't look like a git repo root (no .git dir),"
        err "and $REPO_DIR doesn't exist. Not safe to auto-relocate."
        err "Move it yourself: mv \"$SCRIPT_DIR\" \"$REPO_DIR\""
        exit 1
    fi

    info "Moving repo: $SCRIPT_DIR -> $REPO_DIR"
    mv "$SCRIPT_DIR" "$REPO_DIR"
    ok "Repo now lives at $REPO_DIR"

    info "Re-launching install.sh from its new location..."
    exec "$REPO_DIR/install.sh" "$@"
}

# ---------------------------------------------------------------------------

main() {
    relocate_repo_if_needed "$@"

    if [ ! -d "$REPO_DIR" ]; then
        err "$REPO_DIR does not exist. Clone your dotfiles first, e.g.:"
        err "  git clone <your-repo-url> \"$REPO_DIR\""
        exit 1
    fi

    echo "This will symlink dotfiles from $REPO_DIR into \$HOME:"
    for repo_rel in "${!DOTFILES[@]}"; do
        printf '  %s -> %s\n' "${DOTFILES[$repo_rel]}" "$repo_rel"
    done
    echo "  (and the oh-my-zsh theme, if oh-my-zsh is installed)"
    echo
    warn "Any existing REAL files (not symlinks) at those locations will be"
    warn "moved to a backup dir: $BACKUP_DIR"
    echo

    if ! confirm "Proceed?"; then
        info "Aborted, nothing was changed."
        exit 0
    fi

    install_dotfiles
    install_theme

    echo
    ok "Done. To update in the future:"
    echo "    cd $REPO_DIR && git pull"
    echo "  (re-run ./install.sh only if you add new files to manage,"
    echo "   or want the theme picked up after installing oh-my-zsh)"
}

main "$@"