#!/bin/bash

RENDER_SVG="$(command -v rendersvg)" || true
INKSCAPE="$(command -v inkscape)" || true
OPTIPNG="$(command -v optipng)" || true
# Without either, render with librsvg (render-svg-ids.py), all missing assets in one go
RENDER_IDS="$(dirname "$(readlink -f "$0")")/../../render-svg-ids.py"

INDEX="assets.txt"

for color in '-Dark'; do

  ASSETS_DIR="assets${color}"
  SRC_FILE="assets${color}.svg"

  # [[ -d $ASSETS_DIR ]] && rm -rf $ASSETS_DIR
  mkdir -p $ASSETS_DIR

  if [[ -z "${RENDER_SVG}" && -z "${INKSCAPE}" ]]; then
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
    if [[ -f "$ASSETS_DIR/$i.png" ]]; then
      echo "'$ASSETS_DIR/$i.png' exist!"
    else
      echo "Rendering '$ASSETS_DIR/$i.png'"
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
  done
done

echo -e "DONE!"
