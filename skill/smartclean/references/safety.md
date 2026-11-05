# Safety reference

## Protected paths (never deleted)

- System: `/`, `/usr`, `/etc`, `/var`, `/boot`, `/bin`, `/sbin`, `/lib`, `/lib64`, `/proc`, `/sys`, `/dev`, `/run`, `/root`, `/srv`, `/opt`, `/snap`, `/lost+found`
- Home roots: `~/Documents`, `~/Desktop`, `~/Pictures`, `~/Music`, `~/Videos`, `~/Downloads`, `~/.config`, `~/.local`, `~/.local/share`, `~/.local/state`, `~/.cache`, `~/snap`, `~/.var`, `~/.ssh`, `~/.gnupg`

## Sensitive blocklist (never deleted, even in --deep)

Names/paths matching: password, passwd, secret, keyring, credential, token, cookie, login, profile, session, history, extension, bookmark, autofill, credit card, login data, web data, keyN, cert9, places.sqlite, keychain, keystore, wallet, private.key, .key, ssh, gpg, gnupg.

Browser profile/config roots (`~/.config/google-chrome`, `~/.mozilla`, etc.) and keyring stores are sacred.

## Smart skips

- Browser caches while browser is running.
- Caches/projects used within `--keep-days` (default 7) unless `--deep`.
- Build artifacts in projects with git activity within 30 days unless `--deep`.
- Trees >50GB unless `--deep`.
- Huge trees on timeout (reported, not hung).

## System cleanup uses proper tools

- apt cache: `apt-get clean`
- journal: `journalctl --vacuum-time=7d`
- rotated logs: delete `*.gz`, `*.old`, `*.[0-9]` only
- snap: remove disabled revisions / forget snapshots
- docker/podman: `image prune`, `builder prune`, `container prune` (with confirmation)
