# ceniklas

Personal dotfiles for one keyboard-driven, terminal-heavy workflow that feels the
same on macOS (AeroSpace) and Linux (sway). Plus a couple of git helpers.

## The modifier model

One physical layout, two OSes. External keyboards run in Win/PC mode.

| Physical key (left of space) | Linux            | macOS emits (Karabiner)                   |
|------------------------------|------------------|-------------------------------------------|
| Ctrl                         | app shortcuts    | Cmd in GUI apps, raw Ctrl in Ghostty      |
| Win                          | Super = WM mod   | hyper = ctrl+alt+cmd = WM mod             |
| Alt                          | Alt              | Option (Ghostty: left Alt is Alt, right Alt is AltGr) |
| Caps Lock                    | Super            | hyper                                     |
| Right Ctrl                   | Ctrl             | raw Ctrl (escape hatch)                   |

The MacBook's built-in keyboard mirrors this by position: Ctrl -> app shortcuts,
Option -> hyper, Cmd -> Alt, right Cmd -> Alt, right Option -> raw Ctrl.

Karabiner also adds PC-style text navigation in GUI apps (Ctrl+Arrow word jump,
Ctrl+Backspace, Home/End, Ctrl+Home/End) and keeps Ctrl+Tab, Ctrl+PgUp/PgDn,
Ctrl+Space, Ctrl+` and Ctrl+M as real Ctrl so browser tabs and VS Code behave
like on Linux.

## WM bindings (hyper on macOS = $mod on sway)

| Action                                   | Key                         |
|------------------------------------------|-----------------------------|
| focus / move window                      | h j k l / Shift+h j k l     |
| workspaces 1-9, T B C M                  | key / Shift+key moves window|
| previous workspace                       | Tab                         |
| terminal in zellij "main" / plain shell  | Return / Shift+Return       |
| launcher (Raycast / fuzzel)              | space                       |
| keyboard language eng/swe                | Shift+space                 |
| close / fullscreen / float toggle        | Shift+q / f / Shift+f       |
| split toggle / tabbed / stacked          | e / w / s                   |
| resize mode (h j k l - = Esc)            | r                           |
| service mode (Esc reload, f float)       | Shift+semicolon             |
| lock                                     | Shift+x                     |

T = terminal (Ghostty), B = browser (Firefox, Brave), C = chat (Teams, Slack),
M = mail (Outlook). App pinning is configured on macOS; Linux has none yet.

New Ghostty windows auto-attach to the zellij session `main` (zshrc, guarded: not inside
zellij, not over ssh, not in other terminals). `ZELLIJ_AUTO=0` gives a plain shell.

## Layout

```
dotfiles/
  aerospace/aerospace.toml   macOS tiling WM      <-> sway/config (same section order)
  sway/config                Linux tiling WM
  karabiner/karabiner.json   macOS key remapping (profile "Linux semantics")
  fuzzel/fuzzel.ini          Linux launcher
  swaylock/config            Linux lock screen
  ghostty/config             terminal, shared; includes `local` -> macos / linux overrides
  zellij/config.kdl          multiplexer, upstream unlock-first keybinds
  starship/starship.toml     prompt
  zsh/zshrc, zsh/zprofile    shell (no oh-my-zsh)
install-mac.sh               brew packages, symlinks, AeroSpace restart
install-linux.sh             apt packages, Ghostty .deb, zellij + Nerd Font downloads, symlinks
```

The two WM configs are hand-maintained side by side. When you change a binding,
change it in both files; the sections are in the same order with matching comments.

## Install

macOS:

```sh
git clone git@github.com:ceniklas/ceniklas.git ~/ceniklas
~/ceniklas/install-mac.sh
```

Then: Keychron switch to Win mode; approve Karabiner's driver extension when asked (no
Input Monitoring entry needed with Karabiner 16); Raycast hotkey -> ctrl+alt+cmd+space;
System Settings > Keyboard > "Keyboard Shortcuts..." > Input Sources, "Select the previous
input source" -> ctrl+alt+cmd+shift+space; log out/in once.

Karabiner health check: `hidutil list | grep Karabiner` must show the DriverKit virtual keyboard.
If /var/log/karabiner/core_service.log fills with "drop unmatched momentary switch key_up",
a device is spamming HID reports; add it to the profile's `devices` array with `ignore: true`
(the Logitech receiver and the Keychron dongle's mouse interface already are).

Gotcha: AeroSpace is ad-hoc signed, so after every `brew upgrade` of it macOS silently
drops its Accessibility permission and it stops managing windows (`aerospace list-windows --all`
prints nothing). Fix: System Settings > Privacy & Security > Accessibility, toggle AeroSpace
off and on, then `aerospace reload-config`.

Debian (sway):

```sh
git clone git@github.com:ceniklas/ceniklas.git ~/ceniklas
~/ceniklas/install-linux.sh
```

Then log out and pick the Sway session.

Both scripts are idempotent and back up any real file they replace with a symlink.

## Git helpers

`cush.sh` and `executeorder66.sh` install shell functions for WIP-commit-and-push
and for pruning branches whose upstream is gone. See `zsh.md` and `gitconfig.md`.
