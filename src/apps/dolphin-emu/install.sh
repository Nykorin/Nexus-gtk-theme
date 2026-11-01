#!/bin/bash
# install.sh [STYLES_DIR]
#
# Installs the CachyOS-Nord style into Dolphin Emulator's Styles folder: CachyOS-Nord.qss, with
# its image paths filled in, and its images in CachyOS-Nord/. Without STYLES_DIR it uses the
# Flatpak's folder if the Flatpak is installed, and otherwise the native one. Then choose
# CachyOS-Nord under Config → Interface → Style.

set -euo pipefail

src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -ge 1 ]]; then
  styles_dir="$1"
elif [[ -d "$HOME/.var/app/org.DolphinEmu.dolphin-emu" ]]; then
  styles_dir="$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Styles"
else
  styles_dir="${XDG_DATA_HOME:-$HOME/.local/share}/dolphin-emu/Styles"
fi

mkdir -p "$styles_dir/CachyOS-Nord"
cp "$src_dir"/resources/*.svg "$styles_dir/CachyOS-Nord/"

# Dolphin applies the stylesheet's text without a base folder, so image paths are absolute
sed "s|@RES@|$styles_dir/CachyOS-Nord|g" "$src_dir/CachyOS-Nord.qss" > "$styles_dir/CachyOS-Nord.qss"

echo "Installed to $styles_dir"
