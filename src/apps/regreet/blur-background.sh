#!/bin/bash
# blur-background.sh WALLPAPER WIDTHxHEIGHT [OUTDIR]
#
# Makes a frosted-glass look for ReGreet's login box and clock over a wallpaper. ReGreet draws
# the wallpaper in its own window, so a compositor can't blur it behind the boxes; instead this
# blurs a copy of the wallpaper with ImageMagick, cut to the screen size the way ReGreet's
# fit = "Cover" does, and writes a regreet.css that uses it as the boxes' background. Since the
# boxes are centered (the clock at the top), the screen-sized copy, centered on them, lines up
# with the wallpaper around them.
#
# WIDTHxHEIGHT is the screen size in logical pixels (the mode divided by the output's scale).
# Writes OUTDIR/regreet.css and OUTDIR/regreet-blur.png (OUTDIR defaults to the current folder);
# copy both to /etc/greetd, and set the same wallpaper with fit = "Cover" in regreet.toml.

set -euo pipefail

case "${1:-}" in
  -h | --help)
    sed -n '2,14s/^# \{0,1\}//p' "$0"
    exit 0
    ;;
  -*)
    echo "Unknown option: $1 (see --help)" >&2
    exit 1
    ;;
esac

if [[ $# -lt 2 || $# -gt 3 || ! "$2" =~ ^[0-9]+x[0-9]+$ ]]; then
  sed -n '2,14s/^# \{0,1\}//p' "$0" >&2
  exit 1
fi

wallpaper="$1"
width="${2%x*}"
height="${2#*x}"
outdir="${3:-.}"
src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$outdir"

# Cover: scale to fill the screen, then crop the overflow evenly from both sides
magick "$wallpaper" -resize "${width}x${height}^" -gravity center -extent "${width}x${height}" \
  -blur 0x18 "$outdir/regreet-blur.png"

{
  cat "$src_dir/regreet.css"
  cat <<EOF

/* Frosted glass: a blurred copy of the wallpaper (regreet-blur.png, made by
   blur-background.sh for a ${width}x${height} screen) behind the login box and clock, under the
   same translucent navy. It's screen-sized and centered on the boxes, which are centered on
   the screen, so it lines up with the wallpaper around them. */
overlay > frame.background {
  background-image: linear-gradient(rgba(19, 22, 33, 0.5), rgba(19, 22, 33, 0.5)),
                    url("regreet-blur.png");
  background-size: auto, ${width}px ${height}px;
  background-position: center, center;
  background-repeat: no-repeat;
}

/* The clock sits at the top of the screen, so its copy is aligned to the top */
overlay > frame.background:nth-child(3) {
  background-position: center, center top;
}
EOF
} > "$outdir/regreet.css"

echo "Wrote $outdir/regreet.css and $outdir/regreet-blur.png"
