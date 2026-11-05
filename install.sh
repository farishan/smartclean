#!/usr/bin/env bash
# install smartclean into ~/.local/bin
set -e
SC_HOME="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
mkdir -p "$HOME/.local/bin"
ln -sf "$SC_HOME/bin/smartclean" "$HOME/.local/bin/smartclean"
echo "installed: $HOME/.local/bin/smartclean -> $SC_HOME/bin/smartclean"
echo "ensure ~/.local/bin is on PATH (it usually is)."
# OpenCode integration (skill + command) if OpenCode is present
if [[ -d "$HOME/.config/opencode" ]]; then
  mkdir -p "$HOME/.config/opencode/commands"
  if [[ ! -f "$HOME/.config/opencode/commands/smartclean.md" ]]; then
    cat > "$HOME/.config/opencode/commands/smartclean.md" <<'CMDEOF'
---
description: Run smartclean disk scan (no changes). Use --apply to delete.
---
Run `smartclean` with any arguments passed.
CMDEOF
  fi
  echo "opencode: /smartclean command installed"
fi
if command -v mole >/dev/null 2>&1; then echo "mole: detected ($(command -v mole))"; else echo "mole: not found (optional)"; fi