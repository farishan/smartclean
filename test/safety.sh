#!/usr/bin/env bash
# Safety-focused tests for smartclean (non-destructive)
set -euo pipefail

SC_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/safety.sh
source "$SC_HOME/lib/safety.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

# Protected paths must be protected
for p in "/" "/etc" "/usr/bin" "$HOME/.ssh" "$HOME/.gnupg" "$HOME/.config" "$HOME/.local" "$HOME/.cache" "$HOME/Documents"; do
  if is_protected "$p"; then pass "protected: $p"; else fail "expected protected: $p"; fi
done

# Ordinary project paths must not be protected
for p in "$HOME/dev" "$HOME/dev/foo"; do
  if is_protected "$p"; then fail "expected not protected: $p"; else pass "not protected: $p"; fi
done

# Sensitive names must be blocked
for name in "passwords.txt" "secret.json" "id_rsa" "cookies.sqlite" "keyring" "wallet.dat"; do
  p="$HOME/dev/$name"
  if is_sensitive "$p"; then pass "sensitive: $name"; else fail "expected sensitive: $name"; fi
done

# Non-sensitive cache path allowed
if cache_candidate_ok "$HOME/.cache/pip"; then pass "cache candidate ok: pip"; else fail "expected cache candidate ok"; fi

# Protected cache root not a candidate
if cache_candidate_ok "$HOME/.cache"; then fail "cache root should not be candidate"; else pass "cache root blocked"; fi

# json_escape
out=$(json_escape 'a"b\c')
[[ "$out" == 'a\"b\\c' ]] || { echo "FAIL: json_escape got $out"; exit 1; }
out=$(json_escape $'x\ny\tz')
[[ "$out" == 'x\ny\tz' ]] || { echo "FAIL: json_escape newline/tab got $out"; exit 1; }
echo "PASS: json_escape"

# env / key files sensitive
for name in ".env" ".env.local" "server.pem" "cert.p12"; do
  p="$HOME/dev/$name"
  if is_sensitive "$p"; then echo "PASS: sensitive: $name"; else echo "FAIL: expected sensitive: $name"; exit 1; fi
done

echo "ALL SAFETY TESTS PASSED"
