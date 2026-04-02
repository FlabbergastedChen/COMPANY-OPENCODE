#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "[rollback][error] This script requires bash. Use: bash install/rollback-company-opencode.sh" >&2
  exit 1
fi

set -euo pipefail

INSTALL_ROOT="${COMPANY_OPENCODE_HOME:-$HOME/.company-opencode}"
BUNDLES_DIR="$INSTALL_ROOT/bundles"
CURRENT_LINK="$INSTALL_ROOT/current"
BACKUPS_DIR="$INSTALL_ROOT/backups"

log() { printf '[rollback] %s\n' "$*"; }
err() { printf '[rollback][error] %s\n' "$*" >&2; }

pick_previous_bundle() {
  # 1) Prefer latest backup pointer
  local latest_backup prev_target
  latest_backup="$(ls -1t "$BACKUPS_DIR"/previous-current-*.txt 2>/dev/null | head -n1 || true)"
  if [[ -n "$latest_backup" ]]; then
    prev_target="$(cat "$latest_backup" 2>/dev/null || true)"
    if [[ -n "$prev_target" && -e "$prev_target" ]]; then
      printf '%s' "$prev_target"
      return 0
    fi
  fi

  # 2) fallback: second newest bundle dir
  local candidates=()
  while IFS= read -r line; do candidates+=("$line"); done < <(find "$BUNDLES_DIR" -mindepth 1 -maxdepth 1 -type d | sort -r)
  if (( ${#candidates[@]} < 2 )); then
    return 1
  fi
  printf '%s' "${candidates[1]}"
}

main() {
  if [[ ! -d "$BUNDLES_DIR" ]]; then
    err "No bundles directory found: $BUNDLES_DIR"
    exit 1
  fi

  local target
  if ! target="$(pick_previous_bundle)"; then
    err "No previous bundle available for rollback"
    exit 1
  fi

  ln -sfn "$target" "$CURRENT_LINK"
  log "Rolled back current -> $target"
  log "Done."
}

main "$@"
