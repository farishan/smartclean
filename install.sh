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
description: Run smartclean disk scan (no changes). Shows a detailed table.
---
Run `SMARTCLEAN_INVOCATION=slash smartclean` with any arguments passed. Display the command output verbatim as a detailed table; do not summarize or narrate. Keep the trailing next-step hint as printed.
CMDEOF
  fi
  if [[ ! -f "$HOME/.config/opencode/commands/smartclean-apply.md" ]]; then
    cat > "$HOME/.config/opencode/commands/smartclean-apply.md" <<'CMDEOF'
---
description: Apply smartclean deletion for a category (confirms per category). Use "all" for all.
---
Run `smartclean apply` with any arguments passed (e.g. `--category <category>`). Display the command output verbatim; do not summarize or narrate.
CMDEOF
  fi
  echo "opencode: /smartclean and /smartclean-apply commands installed"
fi
if command -v mole >/dev/null 2>&1; then echo "mole: detected ($(command -v mole))"; else echo "mole: not found (optional)"; fi