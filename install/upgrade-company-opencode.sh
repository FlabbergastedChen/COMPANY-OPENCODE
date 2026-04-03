#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "[upgrade][error] This script requires bash. Use: bash install/upgrade-company-opencode.sh" >&2
  exit 1
fi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUNDLE_SRC="$PACKAGE_ROOT/bundle"

INSTALL_ROOT="${COMPANY_OPENCODE_HOME:-$HOME/.company-opencode}"
BUNDLES_DIR="$INSTALL_ROOT/bundles"
CURRENT_LINK="$INSTALL_ROOT/current"
GLOBAL_CONFIG_DIR="${OPENCODE_GLOBAL_CONFIG_DIR:-$HOME/.config/opencode}"

log() { printf '[upgrade] %s\n' "$*"; }
warn() { printf '[upgrade][warn] %s\n' "$*"; }

bundle_version() {
  local version
  version="$(grep -E '"version"\s*:' "$BUNDLE_SRC/bundle-manifest.json" | head -n1 | sed -E 's/.*"version"\s*:\s*"([^"]+)".*/\1/')"
  [[ -n "${version:-}" ]] || version="$(date +%Y.%m.%d-%H%M%S)"
  printf '%s' "$version"
}

maybe_upgrade_opencode() {
  if ! command -v opencode >/dev/null 2>&1; then
    warn "opencode not found; running full install instead"
    exec "$SCRIPT_DIR/install-company-opencode.sh"
  fi

  local before after
  before="$(opencode --version 2>/dev/null || echo unknown)"
  log "Current opencode: $before"

  if [[ "${SKIP_OPENCODE_UPGRADE:-0}" == "1" ]]; then
    log "SKIP_OPENCODE_UPGRADE=1, skip opencode upgrade"
    return
  fi

  if opencode upgrade ${OPENCODE_UPGRADE_TARGET:-} >/dev/null 2>&1; then
    after="$(opencode --version 2>/dev/null || echo unknown)"
    log "Upgraded opencode: $after"
  else
    warn "opencode upgrade failed; keep existing version"
  fi
}

upgrade_bundle_only_from_package() {
  local version dst ts prev
  version="$(bundle_version)"
  dst="$BUNDLES_DIR/$version"
  mkdir -p "$BUNDLES_DIR" "$INSTALL_ROOT/backups"

  if [[ -e "$dst" ]]; then
    log "Bundle version already exists: $version (refreshing files)"
    rm -rf "$dst"
  else
    log "Copying bundle (same package) -> $dst"
  fi
  mkdir -p "$dst"
  cp -R "$BUNDLE_SRC"/. "$dst"/

  ts="$(date +%Y%m%d-%H%M%S)"
  prev="$(readlink "$CURRENT_LINK" 2>/dev/null || true)"
  [[ -n "$prev" ]] && printf '%s\n' "$prev" > "$INSTALL_ROOT/backups/previous-current-$ts.txt"

  ln -sfn "$dst" "$CURRENT_LINK"
  log "Switched current -> $dst"
}

link_global_compat_dirs() {
  mkdir -p "$GLOBAL_CONFIG_DIR"
  mkdir -p "$INSTALL_ROOT/backups"

  local dirs=(agents commands skills plugins tools themes modes)
  local d src dst ts backup
  ts="$(date +%Y%m%d-%H%M%S)"
  for d in "${dirs[@]}"; do
    src="$CURRENT_LINK/$d"
    dst="$GLOBAL_CONFIG_DIR/$d"
    [[ -e "$src" ]] || continue

    if [[ -L "$dst" ]]; then
      ln -sfn "$src" "$dst"
      continue
    fi

    if [[ -e "$dst" ]]; then
      backup="$INSTALL_ROOT/backups/compat-${d}-$ts"
      warn "Found existing non-symlink at $dst; moving to $backup"
      mv "$dst" "$backup"
    fi

    ln -s "$src" "$dst"
  done

  log "Global compatibility links ensured under $GLOBAL_CONFIG_DIR"
}

main() {
  maybe_upgrade_opencode
  upgrade_bundle_only_from_package
  link_global_compat_dirs
  log "Done."
}

main "$@"
