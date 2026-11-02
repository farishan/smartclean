#!/usr/bin/env bash
# install smartclean into ~/.local/bin
set -e
SC_HOME="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
mkdir -p "$HOME/.local/bin"
ln -sf "$SC_HOME/bin/smartclean" "$HOME/.local/bin/smartclean"
echo "installed: $HOME/.local/bin/smartclean -> $SC_HOME/bin/smartclean"
echo "ensure ~/.local/bin is on PATH (it usually is)."
echo "optional: install mole-for-ubuntu for richer system helpers: https://github.com/ccyisafool/mole-for-ubuntu-and-friends"