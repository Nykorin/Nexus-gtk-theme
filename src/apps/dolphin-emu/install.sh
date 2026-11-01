#!/bin/bash
# install.sh [STYLES_DIR]
#
# Installs the CachyOS-Nord style into a Styles folder of Dolphin Emulator or PrimeHack (a
# Dolphin fork): CachyOS-Nord.qss, with its image paths filled in. The images go next to that
# folder, in StyleImages/CachyOS-Nord: Dolphin lists everything in Styles as a style, folders
# too. Without STYLES_DIR it installs into each of the Dolphin and PrimeHack Flatpaks that's
# installed, or into the native ~/.local/share/dolphin-emu if neither is. Then choose
# CachyOS-Nord under Config → Interface → Style.

set -euo pipefail

src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  -h | --help)
    sed -n '2,9s/^# \{0,1\}//p' "$0"
    exit 0
    ;;
  -*)
    echo "Unknown option: $1 (see --help)" >&2
    exit 1
    ;;
esac

install_style() {
  local styles_dir="$1"
  local images_dir
  images_dir="$(dirname -- "$styles_dir")/StyleImages/CachyOS-Nord"

  mkdir -p -- "$styles_dir" "$images_dir"
  cp "$src_dir"/resources/*.svg "$images_dir/"

  # Earlier versions put the images in Styles/CachyOS-Nord, which Dolphin lists as a second
  # (empty) style
  if [[ -d "$styles_dir/CachyOS-Nord" ]]; then
    rm -f "$styles_dir"/CachyOS-Nord/*.svg
    rmdir "$styles_dir/CachyOS-Nord" 2>/dev/null || true
  fi

  # Dolphin applies the stylesheet's text without a base folder, so image paths are absolute.
  # Each app gets its own images: a Flatpak can't read another one's data folder.
  sed "s|@RES@|$images_dir|g" "$src_dir/CachyOS-Nord.qss" > "$styles_dir/CachyOS-Nord.qss"

  echo "Installed to $styles_dir"
}

if [[ $# -gt 1 ]]; then
  echo "Too many arguments (see --help)" >&2
  exit 1
elif [[ $# -eq 1 ]]; then
  install_style "$1"
  exit 0
fi

installed=false
for app in org.DolphinEmu.dolphin-emu io.github.shiiion.primehack; do
  if [[ -d "$HOME/.var/app/$app" ]]; then
    install_style "$HOME/.var/app/$app/data/dolphin-emu/Styles"
    installed=true
  fi
done

if ! $installed; then
  install_style "${XDG_DATA_HOME:-$HOME/.local/share}/dolphin-emu/Styles"
fi
