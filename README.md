# smartclean

![CI](https://github.com/farishan/smart-cleaner/actions/workflows/ci.yml/badge.svg)

A smart, safety-first disk cleaner that runs on **macOS** (with [Mole](https://github.com/tw93/mole), `mo`) and **Linux** (with [mole-for-ubuntu](https://github.com/ccyisafool/mole-for-ubuntu-and-friends), `mo`), with [OpenCode](https://opencode.ai) integration.

Unlike brute-force cleaners, `smartclean` ranks candidates by size, skips hot caches and active projects, refuses to touch sensitive data (passwords, cookies, browser profiles, keyrings, ssh/gpg), and never deletes without confirmation. Default mode is **scan** (no changes).

## Install

```bash
git clone https://github.com/farishan/smartclean.git ~/dev/smartclean
cd ~/dev/smartclean && bash install.sh
```

Requires: bash, coreutils, find, du, stat. Optional: `mo` (Mole / mole-for-ubuntu) for system-level helpers; `brew` (macOS) or `apt`/`snap`/`flatpak` (Linux); `docker`/`podman` if you use those.

## Platforms

| OS | System helper | System paths cleaned |
|---|---|---|
| macOS | Mole (`mo`) | Homebrew cache, `~/Library/Logs`, `/var/log` |
| Linux | mole-for-ubuntu (`mo`) | apt cache, systemd journal, `/var/log`, snap, flatpak |

Shared categories on both: trash, browsers, dev caches, docker, build artifacts, installers, large files.

## Usage

```bash
smartclean                      # full scan, no changes
smartclean scan --json          # JSON report
smartclean scan --deep          # include deep sweeps
smartclean scan --keep-days 14  # protect 14-day-old caches
smartclean scan --target ~/dev  # artifacts/large files under ~/dev
smartclean apply --category artifacts --target ~/dev
smartclean apply --yes          # apply all (confirms per category unless --yes)
```

## Categories

`trash`, `browsers`, `dev`, `cache`, `system`, `snap`, `flatpak`, `docker`, `artifacts`, `installers`, `large`, or `all`.

## Safety

- Never deletes `~/.config`, `~/.local`, `~/.ssh`, `~/.gnupg`, `~/Documents`, `~/Pictures`, `~/Library` (macOS), etc.
- Blocklists sensitive names/contents (password, secret, keyring, cookie, login, profile, session, wallet, ssh, gpg, key4, cert9, ...).
- Skips browser caches while the browser is running.
- Skips caches/projects used within `--keep-days`.
- Skips build artifacts in projects with recent git activity.
- System paths cleaned via proper tools (`apt-get clean`, `journalctl --vacuum-time`, `brew cleanup`), never raw deletion.
- Scans are bounded by `--timeout`; huge trees skipped unless `--deep`.

## OpenCode integration

- Skill: `~/.agents/skills/smartclean/SKILL.md`
- Command: `/smartclean` in OpenCode.

## Agensi skill package

A cross-agent skill package (SKILL.md standard) lives in `skill/smart-cleaner/`.
Zip that folder and submit at https://agensi.io/dashboard/submit.

- `skill/smart-cleaner/SKILL.md` — skill instructions
- `skill/smart-cleaner/scripts/smartclean` — bundled CLI (chmod +x)
- `skill/smart-cleaner/lib/safety.sh` — safety helpers
- `skill/smart-cleaner/references/` — safety + install docs

## License

MIT.