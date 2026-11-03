#!/usr/bin/env bash
# lib/safety.sh — protected paths, sensitive-data blocklist, safe removal
# Adapted from mole (macOS) / mole-for-ubuntu. Standalone so smartclean works without mo.

SMARTCLEAN_VERSION="0.2.3"

DRY_RUN=${DRY_RUN:-0}
ASSUME_YES=${ASSUME_YES:-0}
TOTAL_FREED=0

if [[ -t 1 ]] && [[ -z ${NO_COLOR:-} ]]; then
  C_RESET=$'\e[0m' C_BOLD=$'\e[1m' C_DIM=$'\e[2m'
  C_RED=$'\e[31m' C_GREEN=$'\e[32m' C_YELLOW=$'\e[33m'
  C_BLUE=$'\e[34m' C_MAGENTA=$'\e[35m' C_CYAN=$'\e[36m'
else
  C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN=''
fi

# OS detection for cross-platform support (macOS + Linux)
SC_OS="$(uname -s)"

# Portable stat helpers
stat_mtime() { # path -> epoch seconds
  local p=$1
  if [[ $SC_OS == Darwin ]]; then
    stat -f %m -- "$p" 2>/dev/null
  else
    stat -c %Y -- "$p" 2>/dev/null
  fi
}
stat_size() { # path -> bytes
  local p=$1
  if [[ $SC_OS == Darwin ]]; then
    stat -f %z -- "$p" 2>/dev/null
  else
    stat -c %s -- "$p" 2>/dev/null
  fi
}

# Locate Mole (macOS) or mole-for-ubuntu (Linux) installation.
MOLE_HOME=${MOLE_HOME:-}
if [[ -z "$MOLE_HOME" ]] && command -v mole >/dev/null 2>&1; then
  MOLE_HOME=$(sed -n "s/^SCRIPT_DIR='\(.*\)'/\1/p" "$(command -v mole)" 2>/dev/null | head -1)
fi

# Prefer mo's core if installed (richer helpers); otherwise use ours.
MOLE_CORE=""
for c in "${MOLE_HOME:-}/lib/core/common.sh" \
         /usr/local/Cellar/mole/*/libexec/lib/core/common.sh \
         /opt/homebrew/Cellar/mole/*/libexec/lib/core/common.sh \
         "${MOLE_HOME:-}/lib/core.sh" \
         "$HOME/.local/share/mole-ubuntu/lib/core.sh"; do
  [[ -r $c ]] && { MOLE_CORE="$c"; break; }
done

human_size() {
  awk -v b="${1:-0}" 'BEGIN{ split("B KB MB GB TB", u); s=1
    while (b>=1024 && s<5){b/=1024; s++}
    printf (s==1?"%d%s":"%.1f%s"), b, u[s] }'
}
path_size() { local s; [[ -e $1 || -L $1 ]] || { echo 0; return; }
  s=$(timeout 10 du -sk -- "$1" 2>/dev/null | cut -f1); echo $(( ${s:-0} * 1024 )); }
# Normalize a path to absolute canonical form without requiring it to exist
# (macOS realpath lacks -m; fall back to readlink/python).
normalize_path() {
  local p=$1
  if [[ -e $p || -L $p ]]; then
    readlink -f -- "$p" 2>/dev/null && return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os,sys; print(os.path.normpath(os.path.abspath(sys.argv[1])))' "$p" 2>/dev/null && return 0
  fi
  printf '%s\n' "$p"
}
have() { command -v "$1" >/dev/null 2>&1; }
confirm() { (( ASSUME_YES )) && return 0; local r
  printf '  %s [y/N] ' "${C_BOLD}$1${C_RESET}"; read -r r 2>/dev/null </dev/tty || { printf '\n'; return 1; }
  [[ $r == [yY]* ]]; }
confirm_or_dry() { (( DRY_RUN )) && return 0; confirm "$1"; }
log_op() { :; }

# ---------- protected paths (never delete) ----------
_system_path() {
  case "$1" in
    /|/usr|/usr/*|/etc|/etc/*|/var|/var/*|/boot|/boot/*|/bin|/bin/*|/sbin|/sbin/*|\
/lib|/lib/*|/lib64|/lib64/*|/proc|/proc/*|/sys|/sys/*|/dev|/dev/*|/run|/run/*|\
/root|/root/*|/srv|/srv/*|/opt|/opt/*|/snap|/snap/*|/lost+found|/lost+found/*)
      return 0 ;;
  esac
  return 1
}
is_protected() {
  local rp p
  rp=$(normalize_path "$1") || return 0
  _system_path "$rp" && return 0
  if [[ $rp != "$HOME"/* ]]; then
    if [[ -n ${SAFE_RM_ROOT:-} && $rp == "$SAFE_RM_ROOT"/* ]]; then return 1; fi
    return 0
  fi
  for p in "$HOME/Documents" "$HOME/Desktop" "$HOME/Pictures" "$HOME/Music" \
           "$HOME/Videos" "$HOME/Downloads" "$HOME/.config" "$HOME/.local" \
           "$HOME/.local/share" "$HOME/.local/state" "$HOME/.cache" \
           "$HOME/snap" "$HOME/.var" "$HOME/Library"; do
    [[ $rp == "$p" ]] && return 0
  done
  for p in "$HOME/.ssh" "$HOME/.gnupg" "$HOME/.Trash"; do
    [[ $rp == "$p" || $rp == "$p"/* ]] && return 0
  done
  return 1
}

# ---------- sensitive-data blocklist (NEVER delete, even in deep sweep) ----------
SENSITIVE_KEYWORDS='password|passwd|secret|keyring|credential|token|cookie|login|profile|session|history|extension|bookmark|autofill|credit card|login data|web data|key[0-9]|cert9|places\.sqlite|keychain|keystore|wallet|private\.key|\.key$|\.pem$|\.p12$|\.pfx$|\.env|id_rsa|id_dsa|id_ecdsa|id_ed25519|ssh|gpg|gnupg'

is_sensitive_name() {
  local n
  n=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  [[ $n =~ ($SENSITIVE_KEYWORDS) ]]
}

# Returns 0 if path is sensitive (must not be deleted)
is_sensitive() {
  local rp=$1 base
  rp=$(normalize_path "$rp") || return 0
  is_protected "$rp" && return 0
  base=$(basename "$rp")
  is_sensitive_name "$base" && return 0
  # browser profile/config roots are sacred
  case "$rp" in
    "$HOME/.config/google-chrome"*|"$HOME/.config/chromium"*|"$HOME/.config/BraveSoftware"*|\
    "$HOME/.config/microsoft-edge"*|"$HOME/.config/vivaldi"*|"$HOME/.config/opera"*|\
    "$HOME/.mozilla"*|"$HOME/.config/mozilla"*|\
    "$HOME/Library/Application Support/Google/Chrome"*|"$HOME/Library/Application Support/Chromium"*|\
    "$HOME/Library/Application Support/BraveSoftware"*|"$HOME/Library/Application Support/Microsoft Edge"*|\
    "$HOME/Library/Application Support/Vivaldi"*|"$HOME/Library/Application Support/Opera"*|\
    "$HOME/Library/Application Support/Firefox"*|"$HOME/Library/Application Support/Mozilla"*) return 0 ;;
  esac
  # keyring / secret stores
  case "$rp" in
    "$HOME/.local/share/keyrings"*|"$HOME/.password-store"*|"$HOME/.config/keepassxc"*|\
    "$HOME/.local/share/keepassxc"*|"$HOME/.config/Bitwarden"*|"$HOME/.config/bitwarden"*|\
    "$HOME/Library/Keychains"*) return 0 ;;
  esac
  # shallow content sniff
  if [[ -d $rp ]]; then
    local f
    for f in "$rp"/*; do
      [[ -e $f ]] || continue
      is_sensitive_name "$(basename "$f")" && return 0
    done
  fi
  return 1
}

cache_candidate_ok() {
  local p=$1
  is_protected "$p" && return 1
  is_sensitive "$p" && return 1
  return 0
}

safe_rm() {
  local target=$1 sz
  [[ -e $target || -L $target ]] || return 0
  if is_protected "$target"; then
    printf '  %s skip (protected): %s\n' "${C_YELLOW}!${C_RESET}" "$target" >&2
    return 1
  fi
  if is_sensitive "$target"; then
    printf '  %s skip (sensitive): %s\n' "${C_YELLOW}!${C_RESET}" "$target" >&2
    return 1
  fi
  if [[ -f ${MOLE_WHITELIST:-$HOME/.config/mole/whitelist} ]]; then
    local wl=${MOLE_WHITELIST:-$HOME/.config/mole/whitelist}
    local rp line
    rp=$(normalize_path "$target")
    while IFS= read -r line; do
      [[ -z $line || $line == \#* ]] && continue
      line="${line/#\~/$HOME}"
      [[ $rp == "$line" || $rp == "$line"/* ]] && { printf '  %s skip (whitelisted): %s\n' "${C_YELLOW}!${C_RESET}" "$target" >&2; return 1; }
    done <"$wl" 2>/dev/null
  fi
  sz=$(path_size "$target")
  if (( DRY_RUN )); then
    printf '  %s[dry-run]%s would remove %s %s(%s)%s\n' "${C_DIM}" "${C_RESET}" "$target" "${C_DIM}" "$(human_size "$sz")" "${C_RESET}"
  else
    rm -rf -- "$target" 2>/dev/null || { printf '  %s could not remove: %s\n' "${C_RED}✗${C_RESET}" "$target" >&2; return 1; }
    printf '  %s removed %s %s(%s)%s\n' "${C_GREEN}✓${C_RESET}" "$target" "${C_DIM}" "$(human_size "$sz")" "${C_RESET}"
  fi
  TOTAL_FREED=$((TOTAL_FREED + sz))
  return 0
}

browser_running() {
  local name=$1
  case "$name" in
    google-chrome|chromium) pgrep -f "chrome|chromium" >/dev/null 2>&1 ;;
    firefox) pgrep -f "firefox" >/dev/null 2>&1 ;;
    brave|BraveSoftware) pgrep -f "brave|Brave" >/dev/null 2>&1 ;;
    microsoft-edge) pgrep -f "Microsoft Edge|msedge" >/dev/null 2>&1 ;;
    vivaldi) pgrep -f "vivaldi|Vivaldi" >/dev/null 2>&1 ;;
    opera) pgrep -f "opera|Opera" >/dev/null 2>&1 ;;
    *) pgrep -f "$name" >/dev/null 2>&1 ;;
  esac
}

path_age_days() {
  local p=$1 mtime now
  [[ -e $p ]] || { echo 9999; return; }
  mtime=$(stat_mtime "$p") || { echo 9999; return; }
  now=$(date +%s)
  echo $(( (now - mtime) / 86400 ))
}


# JSON string escaping helper (used by smartclean JSON output)
json_escape() {
  local t=$1
  t=${t//\\/\\\\}
  t=${t//\"/\\\"}
  printf '%s' "$t"
}
