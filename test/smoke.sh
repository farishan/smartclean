#!/usr/bin/env bash
# Smoke tests for smartclean (non-destructive)
set -euo pipefail
SC="${1:-smartclean}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "== help =="
"$SC" --help >/dev/null

echo "== scan (human) =="
"$SC" scan >/dev/null

echo "== scan json =="
"$SC" scan --json > "$tmp/out.json"
python3 - "$tmp/out.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
assert "candidates" in d and "skipped" in d
assert isinstance(d["candidates"], list)
print("json ok:", len(d["candidates"]), "candidates,", len(d["skipped"]), "skips")
PY

echo "== scan deep json =="
"$SC" scan --deep --keep-days 14 --json > "$tmp/deep.json"
python3 - "$tmp/deep.json" <<'PY'
import json,sys
json.load(open(sys.argv[1]))
print("deep json ok")
PY

echo "== apply dry-run =="
"$SC" apply --dry-run --category trash >/dev/null

echo "ALL SMOKE TESTS PASSED"
