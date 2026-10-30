#! /bin/bash

INKSCAPE="$(command -v inkscape)" || true
OPTIPNG="$(command -v optipng)" || true
# Without Inkscape, render with librsvg (render-svg-ids.py), all missing assets in one go
RENDER_IDS="$(dirname "$(readlink -f "$0")")/../render-svg-ids.py"

INDEX="assets.txt"

for window in '' '-square'; do
for color in '' '-Light' '-Dark'; do

ASSETS_DIR="assets${window}${color}"
SRC_FILE="assets${window}${color}.svg"

mkdir -p $ASSETS_DIR

if [[ -z "${INKSCAPE}" ]]; then
  missing=()
  for i in `cat $INDEX`; do
    [[ -f "$ASSETS_DIR/$i.png" ]] || missing+=("$i")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Rendering ${#missing[@]} assets into '$ASSETS_DIR' with librsvg"
    python3 "$RENDER_IDS" "$SRC_FILE" "$ASSETS_DIR" "${missing[@]}"
    if [[ -n "${OPTIPNG}" ]]; then
      for i in "${missing[@]}"; do "$OPTIPNG" -o7 --quiet "$ASSETS_DIR/$i.png"; done
    fi
  fi
  continue
fi

for i in `cat $INDEX`; do
if [ -f $ASSETS_DIR/$i.png ]; then
    echo $ASSETS_DIR/$i.png exists.
else
    echo
    echo Rendering $ASSETS_DIR/$i.png
    $INKSCAPE --export-id=$i \
              --export-id-only \
              --export-filename=$ASSETS_DIR/$i.png $SRC_FILE >/dev/null \
    && { [[ -z "$OPTIPNG" ]] || $OPTIPNG -o7 --quiet $ASSETS_DIR/$i.png; }
fi
done

done
done

exit 0
