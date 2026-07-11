#!/usr/bin/env bash
set -euo pipefail

BIN_URL="https://raw.githubusercontent.com/shagu/box/refs/heads/master/box"
BASE_CONFIG_URL="https://raw.githubusercontent.com/shagu/box/refs/heads/master/config/"
CONFIG_FILES=("default" "pi" "wine")

# root helper: use sudo if available, fall back to su
root_cmd() {
  if command -v sudo &>/dev/null; then
    sudo "$@"
  elif command -v su &>/dev/null; then
    su -c "$*" "${SUDO_USER:-root}"
  else
    echo "  error: neither sudo nor su found, cannot run as root."
    exit 1
  fi
}

echo "Installing box sandbox wrapper..."

# check for bwrap
if ! command -v bwrap &>/dev/null; then
  echo "  bwrap not found, installing..."
  if command -v pacman &>/dev/null; then
    root_cmd pacman -S --needed --noconfirm bubblewrap
  elif command -v apt &>/dev/null; then
    root_cmd apt install -y bubblewrap
  else
    echo "  error: bwrap required but not found, and no pacman/apt to install it."
    exit 1
  fi
fi

# install binary to /usr/bin
if [ -f /usr/bin/box ]; then
  echo "  /usr/bin/box already exists. Overwrite? [y/N]"
  read -r answer
  if [[ "$answer" != [yY] && "$answer" != [yY][eE][sS] ]]; then
    echo "  skipping install."
    exit 0
  fi
fi
echo "  downloading and installing /usr/bin/box..."
TMPBIN="$(mktemp)"
curl -s -o "$TMPBIN" "$BIN_URL"
root_cmd install -m 0755 "$TMPBIN" /usr/bin/box
rm -f "$TMPBIN"

# install config files to ~/.config/box
mkdir -p "$HOME/.config/box"
for cfg in "${CONFIG_FILES[@]}"; do
  echo "  installing config/$cfg..."
  curl -s -o "$HOME/.config/box/$cfg" "${BASE_CONFIG_URL}${cfg}"
done

echo ""
echo "Done! Usage: box [profile] [command]"
echo "Profiles: default, pi, wine"
