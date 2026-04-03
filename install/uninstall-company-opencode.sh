#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "[uninstall][error] This script requires bash. Use: bash install/uninstall-company-opencode.sh" >&2
  exit 1
fi

set -euo pipefail

INSTALL_ROOT="${COMPANY_OPENCODE_HOME:-$HOME/.company-opencode}"
INSTALL_BIN_DIR="$HOME/.local/bin"
GLOBAL_CONFIG_DIR="${OPENCODE_GLOBAL_CONFIG_DIR:-$HOME/.config/opencode}"

BEGIN_MARKER="# >>> company-opencode >>>"
END_MARKER="# <<< company-opencode <<<"

log() { printf '[uninstall] %s\n' "$*"; }

remove_injected_block() {
  local rc="$1"
  [[ -f "$rc" ]] || return 0
  if ! grep -Fq "$BEGIN_MARKER" "$rc"; then
    return 0
  fi

  awk -v b="$BEGIN_MARKER" -v e="$END_MARKER" '
    BEGIN{inblk=0}
    $0==b{inblk=1; next}
    $0==e{inblk=0; next}
    !inblk{print}
  ' "$rc" > "$rc.tmp" && mv "$rc.tmp" "$rc"
  log "Removed injected env block from $rc"
}

remove_wrapper() {
  local p="$1"
  if [[ -e "$p" || -L "$p" ]]; then
    rm -f "$p"
    log "Removed wrapper: $p"
  fi
}

remove_global_compat_links() {
  local dirs=(agents commands skills plugins tools themes modes)
  local d p t
  for d in "${dirs[@]}"; do
    p="$GLOBAL_CONFIG_DIR/$d"
    if [[ -L "$p" ]]; then
      t="$(readlink "$p" 2>/dev/null || true)"
      case "$t" in
        "$INSTALL_ROOT"/*)
          rm -f "$p"
          log "Removed global compat link: $p"
          ;;
      esac
    fi
  done
}

main() {
  local rc_files=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")

  for rc in "${rc_files[@]}"; do
    remove_injected_block "$rc"
  done

  remove_wrapper "$INSTALL_BIN_DIR/opencode-company"
  remove_wrapper "$INSTALL_BIN_DIR/opencode-company-upgrade"
  remove_wrapper "$INSTALL_BIN_DIR/opencode-company-rollback"
  remove_wrapper "$INSTALL_BIN_DIR/opencode-company-uninstall"
  remove_global_compat_links

  if [[ -e "$INSTALL_ROOT" || -L "$INSTALL_ROOT" ]]; then
    rm -rf "$INSTALL_ROOT"
    log "Removed install root: $INSTALL_ROOT"
  else
    log "Install root not found (already removed): $INSTALL_ROOT"
  fi

  log "Done."
  log "Project source files are untouched."
  log "Open a new shell (or source your rc file) to refresh environment."
}

main "$@"
