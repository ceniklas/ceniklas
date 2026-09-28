#!/usr/bin/env bash
# install-mac.sh — set up the unified keyboard/WM/terminal stack on macOS.
# Idempotent: safe to re-run. Backs up any real file it replaces with a symlink.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT="$REPO/dotfiles"
BREW=/opt/homebrew/bin/brew

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
say "Homebrew packages"
[ -x "$BREW" ] || { echo "Homebrew not found at $BREW"; exit 1; }
for f in zellij starship; do
  $BREW list --formula "$f" >/dev/null 2>&1 || $BREW install "$f" || warn "could not install $f (network?) - re-run later"
done
$BREW list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1 || $BREW install --cask font-jetbrains-mono-nerd-font || warn "could not install the Nerd Font (network?) - re-run later"
$BREW list --cask ghostty >/dev/null 2>&1 || $BREW install --cask ghostty || warn "could not install Ghostty (network?) - re-run later"
# Karabiner ships as a .pkg and asks for your password; install it interactively.
if ! $BREW list --cask karabiner-elements >/dev/null 2>&1; then
  say "Installing Karabiner-Elements (sudo prompt expected)"
  $BREW install --cask karabiner-elements || warn "Karabiner install failed; run: brew install --cask karabiner-elements"
fi

# --- 2. zsh plugins ----------------------------------------------------------
say "zsh plugins"
mkdir -p "$HOME/.zsh/plugins"
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions     "$HOME/.zsh/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/plugins/zsh-syntax-highlighting"

# --- 3. Symlinks -------------------------------------------------------------
say "Symlinks"
link "$DOT/zsh/zshrc"                 "$HOME/.zshrc"
link "$DOT/zsh/zprofile"              "$HOME/.zprofile"
link "$DOT/aerospace/aerospace.toml"  "$HOME/.aerospace.toml"
link "$DOT/karabiner"                 "$HOME/.config/karabiner"      # whole dir: Karabiner rewrites files atomically
link "$DOT/ghostty/config"            "$HOME/.config/ghostty/config"
link "$DOT/ghostty/macos"             "$HOME/.config/ghostty/local"
link "$DOT/zellij/config.kdl"         "$HOME/.config/zellij/config.kdl"
link "$DOT/starship/starship.toml"    "$HOME/.config/starship.toml"

# --- 4. Retire Hyperkey, but only once Karabiner exists to take over Caps Lock --
if [ -d "/Applications/Karabiner-Elements.app" ]; then
  say "Retiring Hyperkey"
  osascript -e 'tell application "System Events" to delete login item "Hyperkey"' >/dev/null 2>&1 || true
  pkill -x Hyperkey 2>/dev/null || true
else
  warn "Karabiner-Elements not installed yet: keeping Hyperkey so Caps Lock stays your WM key"
fi

# --- 5. macOS settings recommended by AeroSpace ------------------------------
say "macOS Spaces settings (takes effect after logout)"
defaults write com.apple.spaces spans-displays -bool true      # "Displays have separate Spaces" OFF
defaults write com.apple.dock expose-group-apps -bool true     # "Group windows by application" ON

# --- 6. Restart AeroSpace (fixes CLI/server mismatch, loads new config) --------
say "Restarting AeroSpace"
osascript -e 'quit app "AeroSpace"' >/dev/null 2>&1 || true
sleep 2
open -a AeroSpace

# --- 7. Launch Karabiner once so it installs its driver and asks for permissions
if [ -d "/Applications/Karabiner-Elements.app" ]; then
  say "Launching Karabiner-Elements"
  open -a "Karabiner-Elements"
fi

cat <<'MSG'

Done. Manual steps that remain:
  1. Keychron: set the hardware switch to Win/PC mode.
  2. Karabiner-Elements: approve its driver extension when macOS asks (System Settings >
     General > Login Items & Extensions). No Input Monitoring entry is needed with v16.
     Profile "Linux semantics" is preselected. Test: physical Ctrl+C / Ctrl+V in a GUI app.
  3. Raycast > Settings > General: set hotkey to ctrl+alt+cmd+space (physical Win+Space).
  4. System Settings > Keyboard > "Keyboard Shortcuts..." > Input Sources (left list):
     "Select the previous input source" = ctrl+alt+cmd+shift+space (physical Win+Shift+Space).
  5. AeroSpace is ad-hoc signed: after EVERY brew upgrade/reinstall macOS drops its
     Accessibility grant and it manages zero windows. Re-grant it:
     System Settings > Privacy & Security > Accessibility > toggle AeroSpace off and on.
  6. Log out and back in for the Spaces setting to apply.
  7. Open a new terminal: oh-my-zsh is no longer sourced (~/.oh-my-zsh can be deleted).
MSG
