---
name: smart-cleaner
description: >-
  Smart, safety-first disk cleaner for Linux. Scans and ranks reclaimable space
  (trash, browser/dev caches, build artifacts, installers, large files, docker/snap)
  while skipping hot caches, active projects, running browsers, and sensitive data
  (passwords, cookies, profiles, keyrings, ssh/gpg). Dry-run by default; never deletes
  without confirmation. Use when the user wants to free disk space, clean caches,
  purge build artifacts, find large files, or tidy the machine.
when_to_use: |
  - User asks to free disk space, clean caches, purge artifacts, find large files, tidy machine
  - User mentions "smart clean", "disk cleaner", "reclaim space"
  - Do NOT use for uninstalling apps (use package manager/mole instead)
  - Do NOT use on macOS/Windows (Linux only)
---

# Smart Cleaner

A safety-first disk cleaner wrapping `mole-for-ubuntu` concepts. Default mode is **scan** (no changes). Deletion only in `apply` mode with per-category confirmation.

## Requirements

- Linux (Ubuntu/Debian-friendly; uses apt, journalctl, snap, flatpak, docker when present)
- Bash, coreutils, find, du, stat
- Optional: `mo` (mole-for-ubuntu), snap, flatpak, docker/podman

## How to run

The cleaner ships as an executable script bundled with this skill.

1. Resolve the script path:
   - Claude Code: `${CLAUDE_SKILL_DIR}/scripts/smartclean`
   - Other agents: `scripts/smartclean` relative to this skill folder, or `smartclean` if installed on PATH
2. Ensure it is executable: `chmod +x <path>` (already set in the package).
3. Run a scan first (never delete on first pass).

```bash
# Full scan, human-readable
<path>/scripts/smartclean

# Machine-readable (for agent parsing)
<path>/scripts/smartclean scan --json

# Deep scan, protect 14-day-old caches
<path>/scripts/smartclean scan --deep --keep-days 14

# Scan a specific tree for artifacts/large files
<path>/scripts/smartclean scan --target ~/dev
```

If `smartclean` is already installed on PATH (e.g. via the repo's install.sh), you can call `smartclean` directly.

## Recommended agent workflow

1. Run `smartclean scan --json` and parse `candidates` + `skipped`.
2. Summarize top candidates by category and size; explain smart skips and why.
3. Ask the user which categories to apply (offer "all safe user-level", "artifacts only", "none").
4. Only after explicit approval, run `smartclean apply --category <chosen> --yes`.
   - For system/snap/docker categories, warn they touch the real machine and may need sudo; confirm separately.
5. Re-run `smartclean scan` to confirm remaining; report freed space.

## Categories

`trash`, `browsers`, `dev`, `cache`, `system`, `snap`, `flatpak`, `docker`, `artifacts`, `installers`, `large`, `all`.

## Safety guarantees

- Never deletes protected paths (`~/.config`, `~/.local`, `~/.ssh`, `~/.gnupg`, `~/Documents`, `~/Pictures`, `/usr`, `/etc`, `/var`, ...).
- Blocklists sensitive names/contents (password, secret, keyring, cookie, login, profile, session, wallet, ssh, gpg, key4, cert9, ...).
- Skips browser caches while the browser is running.
- Skips caches/projects used within `--keep-days` (default 7) unless `--deep`.
- Skips build artifacts in projects with git activity within 30 days unless `--deep`.
- System paths cleaned via proper tools (`apt-get clean`, `journalctl --vacuum-time`, ...), never raw deletion.
- Scans bounded by `--timeout`; huge trees skipped unless `--deep`.
- Default mode scan (dry-run); apply requires confirmation.

## Options

```
smartclean [scan|apply] [options]
  --deep                include deep sweeps
  --keep-days N         protect recently used (default 7)
  --target DIR          tree for artifacts/large files (default ~/dev)
  --category LIST       comma list of categories (default all)
  --min-large MB        large-file threshold (default 100)
  --timeout SEC         per-scan timeout (default 180)
  --json                machine-readable (scan)
  --yes                 skip confirmations (apply)
  --dry-run             force preview
```

## Examples

### Scan only
User: "what can I delete to free space?"
Agent runs: `smartclean scan` and summarizes candidates.

### Apply artifacts only
User: "clean build artifacts in ~/dev"
Agent runs: `smartclean apply --category artifacts --target ~/dev` (after confirmation).

### Deep clean
User: "deep clean, keep 14 days"
Agent runs: `smartclean scan --deep --keep-days 14` then applies chosen categories.

## When NOT to use

- User explicitly wants mole's interactive menu → suggest `mo`.
- User wants to uninstall an app → use package manager (`apt remove`, etc.); smartclean does not uninstall.
- macOS/Windows → not supported.

## Free vs Pro

This listing is the free version. A paid Pro tier (scheduled cleaning, recurring reports, advanced filters) is planned; the free version remains fully functional for manual cleaning.

## Provenance

- Source: https://github.com/farishan/smart-cleaner (MIT)
- Author: Faris Han
