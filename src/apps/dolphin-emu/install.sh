#!/bin/bash
# install.sh [STYLES_DIR]
#
# Installs the CachyOS-Nord style into Dolphin Emulator's Styles folder: CachyOS-Nord.qss, with
# its image paths filled in. The images go next to that folder, in StyleImages/CachyOS-Nord:
# Dolphin lists everything in Styles as a style, folders too. Without STYLES_DIR it uses the
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

images_dir="$(dirname "$styles_dir")/StyleImages/CachyOS-Nord"

mkdir -p "$styles_dir" "$images_dir"
cp "$src_dir"/resources/*.svg "$images_dir/"

# Earlier versions put the images in Styles/CachyOS-Nord, which Dolphin lists as a second
# (empty) style
if [[ -d "$styles_dir/CachyOS-Nord" ]]; then
  rm -f "$styles_dir"/CachyOS-Nord/*.svg
  rmdir "$styles_dir/CachyOS-Nord" 2>/dev/null || true
fi

# Dolphin applies the stylesheet's text without a base folder, so image paths are absolute
sed "s|@RES@|$images_dir|g" "$src_dir/CachyOS-Nord.qss" > "$styles_dir/CachyOS-Nord.qss"

echo "Installed to $styles_dir"
