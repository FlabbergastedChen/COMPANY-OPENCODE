#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "[check][error] This script requires bash. Use: bash install/check-proxy-skill.sh" >&2
  exit 1
fi

set -euo pipefail

CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.company-opencode/current}"
GLOBAL_CONFIG_DIR="${OPENCODE_GLOBAL_CONFIG_DIR:-$HOME/.config/opencode}"
SKILL_NAME="${1:-superpowers-writing-plans}"

line() { printf '%s\n' "------------------------------------------------------------"; }
say() { printf '[check] %s\n' "$*"; }

show_proxy_env() {
  say "Proxy environment variables:"
  env | grep -Ei '(^|_)(http_proxy|https_proxy|all_proxy|no_proxy)=' || true
}

check_no_proxy_localhost() {
  local np="${NO_PROXY:-${no_proxy:-}}"
  if printf '%s' "$np" | grep -Eq '(^|,)(localhost|127\.0\.0\.1|::1)(,|$)'; then
    say "NO_PROXY includes localhost/loopback: OK"
  else
    say "NO_PROXY may be missing localhost/loopback (recommended: localhost,127.0.0.1,::1)"
  fi
}

check_skill_files() {
  local p1="$CONFIG_DIR/skills/$SKILL_NAME/SKILL.md"
  local p2="$GLOBAL_CONFIG_DIR/skills/$SKILL_NAME/SKILL.md"
  say "Skill file check:"
  ls -l "$p1" 2>/dev/null || echo "[check] missing: $p1"
  ls -l "$p2" 2>/dev/null || echo "[check] missing: $p2"
}

probe_with_proxy() {
  say "Network probe (current env): curl -I https://opencode.ai -m 8"
  if curl -I https://opencode.ai -m 8 >/dev/null 2>&1; then
    say "Current env probe: OK"
  else
    say "Current env probe: FAILED/TIMEOUT"
  fi
}

probe_without_proxy() {
  say "Network probe (proxy unset): curl -I https://opencode.ai -m 8"
  if env -u http_proxy -u https_proxy -u all_proxy -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    curl -I https://opencode.ai -m 8 >/dev/null 2>&1; then
    say "Proxy-unset probe: OK"
  else
    say "Proxy-unset probe: FAILED/TIMEOUT"
  fi
}

hint() {
  line
  say "If skill calls timeout while files exist, likely cause is proxy/local-channel routing."
  say "Recommended env:"
  echo "export NO_PROXY=localhost,127.0.0.1,::1"
  echo "export no_proxy=localhost,127.0.0.1,::1"
}

main() {
  say "OPENCODE_CONFIG_DIR=$CONFIG_DIR"
  say "GLOBAL_CONFIG_DIR=$GLOBAL_CONFIG_DIR"
  say "SKILL_NAME=$SKILL_NAME"
  line
  show_proxy_env
  line
  check_no_proxy_localhost
  line
  check_skill_files
  line
  probe_with_proxy
  probe_without_proxy
  hint
}

main "$@"
