#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "[install][error] This script requires bash. Use: bash install/install-company-opencode.sh" >&2
  exit 1
fi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUNDLE_SRC="$PACKAGE_ROOT/bundle"

INSTALL_ROOT="${COMPANY_OPENCODE_HOME:-$HOME/.company-opencode}"
BUNDLES_DIR="$INSTALL_ROOT/bundles"
CURRENT_LINK="$INSTALL_ROOT/current"
INSTALL_BIN_DIR="$HOME/.local/bin"
INSTALL_SCRIPTS_DIR="$INSTALL_ROOT/install"
GLOBAL_CONFIG_DIR="${OPENCODE_GLOBAL_CONFIG_DIR:-$HOME/.config/opencode}"

log() { printf '[install] %s\n' "$*"; }
warn() { printf '[install][warn] %s\n' "$*"; }
err() { printf '[install][error] %s\n' "$*" >&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    err "Missing required command: $1"
    exit 1
  }
}

bundle_version() {
  local version
  version="$(grep -E '"version"\s*:' "$BUNDLE_SRC/bundle-manifest.json" | head -n1 | sed -E 's/.*"version"\s*:\s*"([^"]+)".*/\1/')"
  if [[ -z "${version:-}" ]]; then
    version="$(date +%Y.%m.%d-%H%M%S)"
    warn "Cannot parse bundle version; fallback: $version"
  fi
  printf '%s' "$version"
}

install_opencode_if_missing() {
  if command -v opencode >/dev/null 2>&1; then
    local v
    v="$(opencode --version 2>/dev/null || true)"
    log "Detected opencode: ${v:-unknown version}"
    return 0
  fi

  log "opencode not found. Installing..."
  local method="${OPENCODE_INSTALL_METHOD:-npm}"

  case "$method" in
    npm)
      require_cmd npm
      npm install -g opencode-ai
      ;;
    pnpm)
      require_cmd pnpm
      pnpm add -g opencode-ai
      ;;
    bun)
      require_cmd bun
      bun install -g opencode-ai
      ;;
    yarn)
      require_cmd yarn
      yarn global add opencode-ai
      ;;
    brew)
      require_cmd brew
      brew install anomalyco/tap/opencode
      ;;
    curl)
      require_cmd curl
      bash -c "$(curl -fsSL https://opencode.ai/install)"
      ;;
    *)
      err "Unsupported OPENCODE_INSTALL_METHOD=$method"
      exit 1
      ;;
  esac

  if ! command -v opencode >/dev/null 2>&1; then
    err "opencode install finished but command still not found in PATH"
    err "Try opening a new shell or install with OPENCODE_INSTALL_METHOD=brew"
    exit 1
  fi

  log "Installed opencode: $(opencode --version 2>/dev/null || echo unknown)"
}

sync_bundle_from_package() {
  local version dst
  version="$(bundle_version)"
  dst="$BUNDLES_DIR/$version"

  mkdir -p "$BUNDLES_DIR" "$INSTALL_ROOT/backups" "$INSTALL_ROOT/logs" "$INSTALL_ROOT/cache" "$INSTALL_SCRIPTS_DIR"

  if [[ -e "$dst" ]]; then
    log "Bundle version already exists: $version (refreshing files)"
    rm -rf "$dst"
  else
    log "Copying bundle from package: $BUNDLE_SRC -> $dst"
  fi
  mkdir -p "$dst"
  cp -R "$BUNDLE_SRC"/. "$dst"/

  if [[ -L "$CURRENT_LINK" || -e "$CURRENT_LINK" ]]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    local prev_target
    prev_target="$(readlink "$CURRENT_LINK" 2>/dev/null || true)"
    if [[ -n "$prev_target" ]]; then
      printf '%s\n' "$prev_target" > "$INSTALL_ROOT/backups/previous-current-$ts.txt"
    fi
  fi

  ln -sfn "$dst" "$CURRENT_LINK"
  log "Current bundle -> $dst"
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

install_wrappers_and_scripts() {
  mkdir -p "$INSTALL_BIN_DIR" "$INSTALL_SCRIPTS_DIR"

  cp "$SCRIPT_DIR/install-company-opencode.sh" "$INSTALL_SCRIPTS_DIR/"
  cp "$SCRIPT_DIR/upgrade-company-opencode.sh" "$INSTALL_SCRIPTS_DIR/"
  cp "$SCRIPT_DIR/rollback-company-opencode.sh" "$INSTALL_SCRIPTS_DIR/"
  cp "$SCRIPT_DIR/uninstall-company-opencode.sh" "$INSTALL_SCRIPTS_DIR/"

  chmod +x "$INSTALL_SCRIPTS_DIR"/*.sh

  cat > "$INSTALL_BIN_DIR/opencode-company" <<'WRAP'
#!/usr/bin/env bash
set -e
export OPENCODE_CONFIG_DIR="$HOME/.company-opencode/current"
exec opencode "$@"
WRAP

  cat > "$INSTALL_BIN_DIR/opencode-company-upgrade" <<'WRAP'
#!/usr/bin/env bash
set -e
exec "$HOME/.company-opencode/install/upgrade-company-opencode.sh" "$@"
WRAP

  cat > "$INSTALL_BIN_DIR/opencode-company-rollback" <<'WRAP'
#!/usr/bin/env bash
set -e
exec "$HOME/.company-opencode/install/rollback-company-opencode.sh" "$@"
WRAP

  cat > "$INSTALL_BIN_DIR/opencode-company-uninstall" <<'WRAP'
#!/usr/bin/env bash
set -e
exec "$HOME/.company-opencode/install/uninstall-company-opencode.sh" "$@"
WRAP

  chmod +x "$INSTALL_BIN_DIR/opencode-company" "$INSTALL_BIN_DIR/opencode-company-upgrade" "$INSTALL_BIN_DIR/opencode-company-rollback" "$INSTALL_BIN_DIR/opencode-company-uninstall"

  log "Installed wrappers into $INSTALL_BIN_DIR"
}

ensure_persistent_env() {
  local begin="# >>> company-opencode >>>"
  local end="# <<< company-opencode <<<"
  local block
  block="$begin
export OPENCODE_CONFIG_DIR=\"$HOME/.company-opencode/current\"
export PATH=\"$HOME/.local/bin:\$PATH\"
$end"

  local targets=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
  for rc in "${targets[@]}"; do
    [[ -f "$rc" ]] || touch "$rc"
    if grep -Fq "$begin" "$rc"; then
      awk -v b="$begin" -v e="$end" -v repl="$block" '
        BEGIN{inblk=0;done=0}
        $0==b{if(!done){print repl;done=1} inblk=1; next}
        $0==e{inblk=0; next}
        !inblk{print}
        END{if(!done) print repl}
      ' "$rc" > "$rc.tmp" && mv "$rc.tmp" "$rc"
    else
      printf '\n%s\n' "$block" >> "$rc"
    fi
  done

  log "Persistent env written to ~/.zshrc ~/.zprofile ~/.bashrc ~/.bash_profile ~/.profile"
}

main() {
  install_opencode_if_missing
  sync_bundle_from_package
  link_global_compat_dirs
  install_wrappers_and_scripts
  ensure_persistent_env

  log "Done."
  log "Use: opencode-company --version"
  log "Use: opencode-company"
}

main "$@"
