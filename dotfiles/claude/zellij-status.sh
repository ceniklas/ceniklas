#!/usr/bin/env bash
# Claude Code hook helper: show session state as an emoji prefix on the Zellij
# tab that hosts this Claude pane (not the focused tab).
# Usage: zellij-status.sh working|waiting|done|clear
[ -n "$ZELLIJ" ] && [ -n "$ZELLIJ_PANE_ID" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0
[ -t 0 ] || cat >/dev/null   # drain hook JSON on stdin

case "$1" in
  working) icon="🤖" ;;
  waiting) icon="❓" ;;
  done)    icon="✅" ;;
  *)       icon="" ;;
esac

zellij action list-panes --tab --json 2>/dev/null | python3 -I -c '
import json, re, subprocess, sys
pane, icon = int(sys.argv[1]), sys.argv[2]
for p in json.load(sys.stdin):
    if p["id"] == pane and not p["is_plugin"]:
        base = re.sub(r"^(🤖|❓|✅) ", "", p["tab_name"])
        name = f"{icon} {base}" if icon else base
        if name != p["tab_name"]:
            subprocess.run(["zellij", "action", "rename-tab-by-id", str(p["tab_id"]), name])
        break
' "$ZELLIJ_PANE_ID" "$icon"
exit 0
