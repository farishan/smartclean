# smart-cleaner

A smart, safety-first disk cleaner built on top of [Mole](https://github.com/tw93/mole) (`mo`, macOS) and OpenCode.

Unlike brute-force cleaners, `smartclean` ranks candidates by size, skips hot caches and active projects, refuses to touch sensitive data (passwords, cookies, browser profiles, keyrings, ssh/gpg), and never deletes without confirmation. Default mode is **scan** (no changes).

## Install

```bash
git clone https://github.com/farishan/smart-cleaner.git ~/dev/smart-cleaner
cd ~/dev/smart-cleaner && bash install.sh
```

Requires: bash, coreutils, find, du, stat. Optional: `mo` (Mole, macOS) for system-level helpers; `brew`, `docker`/`podman` if you use those. Linux-only categories (snap/flatpak/apt) are skipped on macOS.

## Usage

```bash
smartclean                      # full scan, no changes
smartclean scan --json          # JSON report
smartclean scan --deep          # include deep sweeps
smartclean scan --keep-days 14  # protect 14-day-old caches
smartclean scan --target ~/dev # artifacts/large files under ~/dev
smartclean apply --category artifacts --target ~/dev
smartclean apply --yes          # apply all (careful, confirms per category unless --yes)
```

## Categories

`trash`, `browsers`, `dev`, `cache`, `system`, `snap`, `flatpak`, `docker`, `artifacts`, `installers`, `large`, or `all`.

## Safety

- Never deletes `~/.config`, `~/.local`, `~/.ssh`, `~/.gnupg`, `~/Documents`, `~/Pictures`, etc.
- Blocklists sensitive names/contents (password, secret, keyring, cookie, login, profile, session, wallet, ssh, gpg, key4, cert9, ...).
- Skips browser caches while the browser is running.
- Skips caches/projects used within `--keep-days`.
- Skips build artifacts in projects with recent git activity.
- System paths cleaned via proper tools (`apt-get clean`, `journalctl --vacuum-time`, ...), never raw deletion.
- Scans are bounded by `--timeout`; huge trees skipped unless `--deep`.

## OpenCode integration

- Skill: `~/.agents/skills/smart-cleaner/SKILL.md`
- Command: `/smartclean` in OpenCode.

## License

MIT.