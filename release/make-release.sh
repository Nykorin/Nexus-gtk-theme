#! /bin/bash

THEME_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=CachyOS-Nord

_COLOR_VARIANTS=('-Dark')
_COMPA_VARIANTS=('' '-compact')
_ROUND_VARIANTS=('' '-round')

if [ ! -z "${COMPA_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COMPA_VARIANTS <<< "${COMPA_VARIANTS:-}"
fi

if [ ! -z "${ROUND_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _ROUND_VARIANTS <<< "${ROUND_VARIANTS:-}"
fi

if [ ! -z "${COLOR_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

Tar_themes() {
for round in "${_ROUND_VARIANTS[@]}"; do
  rm -rf ${THEME_NAME}${round}.tar.xz
done

for round in "${_ROUND_VARIANTS[@]}"; do
  tar -Jcvf ${THEME_NAME}${round}.tar.xz ${THEME_NAME}${round}-Dark{'','-compact'}
done
}

Clear_theme() {
for round in "${_ROUND_VARIANTS[@]}"; do
  for color in "${_COLOR_VARIANTS[@]}"; do
    for compact in "${_COMPA_VARIANTS[@]}"; do
      [[ -d "${THEME_NAME}${round}${color}${compact}" ]] && rm -rf "${THEME_NAME}${round}${color}${compact}"
    done
  done
done
}

cd .. && ./install.sh -d $THEME_DIR && ./install.sh -d $THEME_DIR --tweaks round

cd $THEME_DIR && Tar_themes && Clear_theme
