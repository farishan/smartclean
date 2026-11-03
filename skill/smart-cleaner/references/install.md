# Install / setup

The skill bundles the `smartclean` CLI at `scripts/smartclean`. No separate install is required.

## Optional: install on PATH (for direct terminal use)

```bash
git clone https://github.com/farishan/smart-cleaner.git ~/dev/smart-cleaner
cd ~/dev/smart-cleaner && bash install.sh
```

This symlinks `~/.local/bin/smartclean` to the repo's `bin/smartclean`.

## Optional: mole-for-ubuntu (richer system helpers)

```bash
# see https://github.com/ccyisafool/mole-for-ubuntu-and-friends
```

smartclean works standalone; `mo` only enriches system-level helpers.

## Verify

```bash
smartclean --help
smartclean scan --json | head
```
