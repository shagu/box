#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILES="default pi wine"

# Detect install mode: local source or GitHub
if [ -f "$SCRIPT_DIR/box" ] && [ -d "$SCRIPT_DIR/config" ]; then
  MODE="local"
else
  MODE="github"
  BIN_URL="https://raw.githubusercontent.com/shagu/box/refs/heads/master/box"
  BASE_CONFIG_URL="https://raw.githubusercontent.com/shagu/box/refs/heads/master/config/"
fi

# root helper: use sudo if available, fall back to su
root_cmd() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  elif command -v su >/dev/null 2>&1; then
    su -c "$*" "${SUDO_USER:-root}"
  else
    echo "  error: neither sudo nor su found, cannot run as root."
    exit 1
  fi
}

echo "Installing box sandbox wrapper..."

# check for bwrap
if ! command -v bwrap >/dev/null 2>&1; then
  echo "  bwrap not found, installing..."
  if command -v pacman >/dev/null 2>&1; then
    root_cmd pacman -S --needed --noconfirm bubblewrap
  elif command -v apt >/dev/null 2>&1; then
    root_cmd apt install -y bubblewrap
  else
    echo "  error: bwrap required but not found, and no pacman/apt to install it."
    exit 1
  fi
fi

# install binary to /usr/bin
if [ -f /usr/bin/box ]; then
  echo "  /usr/bin/box already exists. Overwrite? [y/N]"
  read -r answer < /dev/tty
  case "$answer" in
    [yY]|[yY][eE][sS]) ;;
    *)
      echo "  skipping install."
      exit 0
      ;;
  esac
fi

TMPBIN=""
trap 'rm -f "$TMPBIN"' EXIT

case "$MODE" in
  local)
    echo "  mode: local (from source directory)"
    echo "  copying box to /usr/bin/box..."
    root_cmd install -m 0755 "$SCRIPT_DIR/box" /usr/bin/box
    ;;
  github)
    echo "  mode: github (downloading from repository)"
    echo "  downloading and installing /usr/bin/box..."
    TMPBIN="$(mktemp)"
    curl -s -o "$TMPBIN" "$BIN_URL"
    root_cmd install -m 0755 "$TMPBIN" /usr/bin/box
    ;;
esac

# install config files to ~/.config/box
mkdir -p "$HOME/.config/box"
for cfg in $CONFIG_FILES; do
  echo "  installing config/$cfg..."
  case "$MODE" in
    local)
      cp "$SCRIPT_DIR/config/$cfg" "$HOME/.config/box/$cfg"
      ;;
    github)
      curl -s -o "$HOME/.config/box/$cfg" "${BASE_CONFIG_URL}${cfg}"
      ;;
  esac
done

echo ""
echo "Done! Usage: box [profile] [command]"
echo "Profiles: default, pi, wine"
