#!/usr/bin/env bas
#installer for itds.sh
# Usage: ./install-itds.sh [--no-git] [--dest DIR]
set -o errexit
set -o nounset
set -o pipefail

# Config
DEFAULT_PKGS=(nmap curl traceroute)
INSTALL_GIT=1
DEST_DIR_DEFAULT="$HOME/bin"
FORCE_NO_SUDO=0

# Parse args (very small)
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-git) INSTALL_GIT=0; shift ;;
    --dest) shift; DEST_DIR_DEFAULT="${1:-$DEST_DIR_DEFAULT}"; shift ;;
    --no-sudo) FORCE_NO_SUDO=1; shift ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--no-git] [--dest DIR] [--no-sudo]
  --no-git    Skip installing git
  --dest DIR  Install itds.sh into DIR (default: $HOME/bin)
  --no-sudo   Do not use sudo even if available (useful in Termux)
EOF
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

PKGS=("${DEFAULT_PKGS[@]}")
[ "$INSTALL_GIT" -eq 1 ] && PKGS+=("git")

info() { printf '[*] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }
err() { printf 'Error: %s\n' "$*" >&2; exit 1; }

# detect package manager
detect_pkg_mgr() {
  if command -v pkg >/dev/null 2>&1; then
    echo "pkg"
  elif command -v apt >/dev/null 2>&1; then
    echo "apt"
  elif command -v apk >/dev/null 2>&1; then
    echo "apk"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  else
    echo "none"
  fi
}

PKG_MGR="$(detect_pkg_mgr)"
info "Detected package manager: $PKG_MGR"

# helper to run with sudo when needed
maybe_sudo() {
  if [ "$FORCE_NO_SUDO" -eq 1 ]; then
    "$@"
    return
  fi
  if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

if [ "$PKG_MGR" = "none" ]; then
  err "No supported package manager found (pkg/apt/apk/dnf/yum/pacman). Install dependencies manually: ${PKGS[*]}"
fi

# Update repositories
info "Updating package repositories..."
case "$PKG_MGR" in
  pkg)
    # Termux's pkg is a wrapper; does not need sudo
    pkg update -y || warn "pkg update failed"
    ;;
  apt)
    maybe_sudo apt update -y || maybe_sudo apt update || warn "apt update failed"
    ;;
  apk)
    maybe_sudo apk update || warn "apk update failed"
    ;;
  dnf)
    maybe_sudo dnf makecache || warn "dnf makecache failed"
    ;;
  yum)
    maybe_sudo yum makecache || warn "yum makecache failed"
    ;;
  pacman)
    maybe_sudo pacman -Sy || warn "pacman -Sy failed"
    ;;
esac

# Install packages
install_with_mgr() {
  local mgr="$1"; shift
  local pkgs=("$@")
  case "$mgr" in
    pkg) pkg install -y "${pkgs[@]}" ;;
    apt) maybe_sudo apt install -y "${pkgs[@]}" ;;
    apk) maybe_sudo apk add "${pkgs[@]}" ;;
    dnf) maybe_sudo dnf install -y "${pkgs[@]}" ;;
    yum) maybe_sudo yum install -y "${pkgs[@]}" ;;
    pacman) maybe_sudo pacman -S --noconfirm "${pkgs[@]}" ;;
    *) return 1 ;;
  esac
}

info "Installing dependencies: ${PKGS[*]}"
if ! install_with_mgr "$PKG_MGR" "${PKGS[@]}"; then
  warn "Automatic install failed for some packages. You may need to install them manually: ${PKGS[*]}"
fi

# Ensure destination directory exists and is in PATH
DEST_DIR="$DEST_DIR_DEFAULT"
mkdir -p "$DEST_DIR"
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$DEST_DIR"; then
  SHELL_RC=""
  # try to detect shell rc file
  case "${SHELL##*/}" in
    bash) SHELL_RC="$HOME/.bashrc" ;;
    zsh) SHELL_RC="$HOME/.zshrc" ;;
    *) SHELL_RC="$HOME/.profile" ;;
  esac
  cat >>"$SHELL_RC" <<EOF

# added by install-itds.sh: include user bin in PATH
if [ -d "$DEST_DIR" ] && [[ ":\$PATH:" != *":$DEST_DIR:"* ]]; then
  export PATH="\$PATH:$DEST_DIR"
fi
EOF
  info "Added $DEST_DIR to PATH in $SHELL_RC (you may need to restart your shell)"
fi

# Install itds.sh: look for it in current dir first
SRC="./itds.sh"
if [ ! -f "$SRC" ]; then
  warn "itds.sh not found in current directory. If you want to install from elsewhere, place itds.sh next to this installer or provide a path."
  err "Missing itds.sh — aborting."
fi

DEST_PATH="$DEST_DIR/itds.sh"
cp -f "$SRC" "$DEST_PATH"
chmod +x "$DEST_PATH"
info "Installed itds.sh -> $DEST_PATH"

# Final checks: ensure required commands are available
for cmd in nmap curl traceroute; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    warn "Command '$cmd' not found after installation. You may need to install it manually."
  fi
done

info "Installation complete. You can run the tool with: $DEST_PATH"
info "If you added $DEST_DIR to your shell rc, restart your shell or run: export PATH=\"\$PATH:$DEST_DIR\""

exit 0
