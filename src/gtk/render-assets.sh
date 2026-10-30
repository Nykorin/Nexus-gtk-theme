#!/bin/bash
set -ueo pipefail

RENDER_SVG="$(command -v rendersvg)" || true
INKSCAPE="$(command -v inkscape)" || true
OPTIPNG="$(command -v optipng)" || true
# Without either, render with librsvg (render-svg-ids.py), all missing assets in one go
RENDER_IDS="$(dirname "$(readlink -f "$0")")/../render-svg-ids.py"

INDEX="assets.txt"

ASSETS_DIR="assets"
SRC_FILE="assets.svg"

#[[ -d $ASSETS_DIR ]] && rm -rf $ASSETS_DIR
mkdir -p $ASSETS_DIR

if [[ -z "${RENDER_SVG}" && -z "${INKSCAPE}" ]]; then
  for scale in 1 2; do
    suffix=''
    [[ "$scale" == 2 ]] && suffix='@2'
    missing=()
    for i in `cat $INDEX`; do
      [[ -f "$ASSETS_DIR/$i$suffix.png" ]] || missing+=("$i")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
      echo "Rendering ${#missing[@]} assets into '$ASSETS_DIR' (scale $scale) with librsvg"
      python3 "$RENDER_IDS" "$SRC_FILE" "$ASSETS_DIR" --scale "$scale" --suffix "$suffix" "${missing[@]}"
      if [[ -n "${OPTIPNG}" ]]; then
        for i in "${missing[@]}"; do "$OPTIPNG" -o7 --quiet "$ASSETS_DIR/$i$suffix.png"; done
      fi
    fi
  done
  exit 0
fi

for i in `cat $INDEX`; do
echo "Rendering '$ASSETS_DIR/$i.png'"

if [[ -f "$ASSETS_DIR/$i.png" ]]; then
  echo "$ASSETS_DIR/$i.png" exists.
else
if [[ -n "${RENDER_SVG}" ]]; then
  "$RENDER_SVG" --export-id "$i" \
                "$SRC_FILE" "$ASSETS_DIR/$i.png"
else
  "$INKSCAPE" --export-id="$i" \
              --export-id-only \
              --export-filename="$ASSETS_DIR/$i.png" "$SRC_FILE" >/dev/null
fi
if [[ -n "${OPTIPNG}" ]]; then
  "$OPTIPNG" -o7 --quiet "$ASSETS_DIR/$i.png"
fi
fi

echo "Rendering '$ASSETS_DIR/$i@2.png'"

if [[ -f "$ASSETS_DIR/$i@2.png" ]]; then
  echo "$ASSETS_DIR/$i@2.png" exists.
else
if [[ -n "${RENDER_SVG}" ]]; then
  "$RENDER_SVG" --export-id "$i" \
                --dpi 192 \
                --zoom 2 \
                "$SRC_FILE" "$ASSETS_DIR/$i@2.png"
else
  "$INKSCAPE" --export-id="$i" \
              --export-id-only \
              --export-dpi=192 \
              --export-filename="$ASSETS_DIR/$i@2.png" "$SRC_FILE" >/dev/null
fi
if [[ -n "${OPTIPNG}" ]]; then
  "$OPTIPNG" -o7 --quiet "$ASSETS_DIR/$i@2.png"
fi
fi

done
