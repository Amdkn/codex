#!/usr/bin/env bash
# Smoke test aspace-codex-adapter — 5 checks (contrat, version, help, aide exec, absence de réseau).
# Usage : bash aspace-codex-adapter/smoke_test.sh [chemin-du-binaire]
# Le binaire est produit par : cargo build --locked -p codex-cli (depuis codex-rs/).
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${1:-$ROOT/codex-rs/target/debug/codex}"
ADAPTER="$ROOT/aspace-codex-adapter"
FAIL=0

check() { # check <nom> <commande...>
  local name="$1"; shift
  if "$@" >/tmp/codex-smoke-out.txt 2>&1; then
    echo "ok - $name"
  else
    echo "FAIL - $name (rc=$?)" >&2
    FAIL=1
  fi
}

# 1. Le binaire existe et le gel est épinglé dans le contrat.
[ -x "$BIN" ] || { echo "FAIL - binaire introuvable : $BIN" >&2; exit 1; }
grep -q '"pinned_codex_commit": *"27fcd7cbedd7efd63fd704bd01a0cfe1d7b85a26"' "$ADAPTER/contract.json" \
  && echo "ok - gel épinglé 27fcd7c dans le contrat" \
  || { echo "FAIL - gel non épinglé dans le contrat" >&2; FAIL=1; }

# 2. --version parle seulement (maison scratch, overrides télémétrie forcés).
export CODEX_HOME="$(mktemp -d)"
export OTEL_SDK_DISABLED=1
unset OTEL_EXPORTER_OTLP_ENDPOINT CODEX_ANALYTICS_EVENTS_CAPTURE_FILE
check "version" "$BIN" -c analytics.enabled=false -c feedback.enabled=false --version
grep -qi "codex" /tmp/codex-smoke-out.txt \
  && echo "ok - --version mentionne codex" \
  || { echo "FAIL - --version ne mentionne pas codex" >&2; FAIL=1; }

# 3. --help parle seulement.
check "help" "$BIN" -c analytics.enabled=false -c feedback.enabled=false --help

# 4. exec --help parle seulement (jamais d'appel modèle).
check "exec --help" "$BIN" -c analytics.enabled=false -c feedback.enabled=false exec --help

# 5. Les mêmes commandes passent sans interface réseau (unshare -n) : preuve zéro-réseau.
if command -v unshare >/dev/null 2>&1; then
  if unshare -n "$BIN" -c analytics.enabled=false -c feedback.enabled=false --version >/tmp/codex-smoke-net.txt 2>&1; then
    echo "ok - --version sans interface réseau"
  else
    echo "FAIL - --version échoue sans interface réseau" >&2; FAIL=1
  fi
else
  echo "skip - unshare absent, preuve réseau non courue"
fi

rm -rf "$CODEX_HOME"
[ "$FAIL" -eq 0 ] && echo "smoke codex OK (version, --help, exec --help, sans réseau)" && exit 0
echo "smoke codex ÉCHEC" >&2 && exit 1
