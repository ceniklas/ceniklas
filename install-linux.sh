#!/usr/bin/env bash
# install-linux.sh — set up the unified keyboard/WM/terminal stack on Debian (stable).
# Idempotent: safe to re-run. Backs up any real file it replaces with a symlink.
# NOTE: written before the Linux box existed; untested on real hardware.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT="$REPO/dotfiles"

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
link() { # link <src> <dst>
  local src=$1 dst=$2
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    say "backed up $dst"
  fi
  ln -sfn "$src" "$dst"
  say "linked $dst -> $src"
}
clone_or_pull() { # clone_or_pull <url> <dir>  (3 attempts, never fatal)
  local i
  for i in 1 2 3; do
    if [ -d "$2/.git" ]; then
      git -C "$2" pull -q --ff-only && { say "plugin updated: $2"; return 0; }
    else
      git clone -q --depth 1 "$1" "$2" && { say "plugin installed: $2"; return 0; }
    fi
    sleep 2
  done
  warn "could not fetch $1 (network?) - re-run later"
}

# --- 1. Packages -------------------------------------------------------------
say "apt packages"
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
  sway swaybg swayidle swaylock fuzzel \
  zsh starship git curl ca-certificates xz-utils fontconfig \
  wl-clipboard xdg-desktop-portal-wlr xdg-desktop-portal-gtk pipewire wireplumber

# Ghostty is not in the Debian archive. ghostty.org documents the community-maintained
# .deb repository (github.com/mkasberg/ghostty-ubuntu) for Debian/Ubuntu; snap is the fallback.
if ! command -v ghostty >/dev/null 2>&1; then
  say "Ghostty via the community .deb installer"
  tmp=$(mktemp)
  curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh -o "$tmp"
  bash "$tmp" || warn "Ghostty .deb install failed; fallback: sudo apt install snapd && sudo snap install ghostty --classic"
  rm -f "$tmp"
fi
command -v ghostty >/dev/null 2>&1 && say "ghostty $(ghostty +version 2>/dev/null | head -1)"

# zellij is not packaged in Debian: fetch the latest musl build from GitHub.
if ! command -v zellij >/dev/null 2>&1; then
  say "zellij from GitHub releases"
  arch=$(uname -m)   # x86_64 or aarch64
  url="https://github.com/zellij-org/zellij/releases/latest/download/zellij-${arch}-unknown-linux-musl.tar.gz"
  tmp=$(mktemp -d)
  curl -fsSL "$url" | tar -xz -C "$tmp"
  sudo install -m 0755 "$tmp/zellij" /usr/local/bin/zellij
  rm -rf "$tmp"
fi
say "zellij $(zellij --version)"

# JetBrainsMono Nerd Font (Debian's fonts-jetbrains-mono lacks the Nerd glyphs)
if ! fc-list | grep -qi 'JetBrainsMono Nerd Font'; then
  say "JetBrainsMono Nerd Font"
  fontdir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  mkdir -p "$fontdir"
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C "$fontdir"
  fc-cache -f
fi

# --- 2. zsh plugins ----------------------------------------------------------
say "zsh plugins"
mkdir -p "$HOME/.zsh/plugins"
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions     "$HOME/.zsh/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/plugins/zsh-syntax-highlighting"

# --- 3. Symlinks -------------------------------------------------------------
say "Symlinks"
link "$DOT/zsh/zshrc"               "$HOME/.zshrc"
link "$DOT/zsh/zprofile"            "$HOME/.zprofile"
link "$DOT/sway/config"             "$HOME/.config/sway/config"
link "$DOT/fuzzel/fuzzel.ini"       "$HOME/.config/fuzzel/fuzzel.ini"
link "$DOT/swaylock/config"         "$HOME/.config/swaylock/config"
link "$DOT/ghostty/config"          "$HOME/.config/ghostty/config"
link "$DOT/ghostty/linux"           "$HOME/.config/ghostty/local"
link "$DOT/zellij/config.kdl"       "$HOME/.config/zellij/config.kdl"
link "$DOT/starship/starship.toml"  "$HOME/.config/starship.toml"

# --- 4. Default shell ----------------------------------------------------------
if [ "$(basename "$SHELL")" != "zsh" ]; then
  say "Setting zsh as login shell"
  chsh -s "$(command -v zsh)"
fi

# --- 5. Validate the sway config ----------------------------------------------
say "sway config check"
sway -C -c "$HOME/.config/sway/config" && say "sway config OK"

cat <<'MSG'

Done. Manual steps that remain:
  1. Keychron: hardware switch in Win/PC mode (no remapping needed on Linux).
  2. Log out, pick the "Sway" session at the login screen, log in.
  3. Optional: Teams via teams-for-linux (https://teamsforlinux.de) and Outlook web;
     add assign rules to dotfiles/sway/config once you know the app_ids (swaymsg -t get_tree).
MSG
