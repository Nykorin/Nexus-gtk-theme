#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$REPO_DIR/src"

ROOT_UID=0
DEST_DIR=

# For tweaks
opacity=
panel=
window=
blur=
outline=
titlebutton=
icon='-default'

# Destination directory
if [[ "$UID" -eq "$ROOT_UID" ]]; then
  DEST_DIR="/usr/share/themes"
elif [[ -n "$XDG_DATA_HOME" ]]; then
  DEST_DIR="$XDG_DATA_HOME/themes"
elif [[ -d "$HOME/.themes" ]]; then
  DEST_DIR="$HOME/.themes"
elif [[ -d "$HOME/.local/share/themes" ]]; then
  DEST_DIR="$HOME/.local/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SASSC_OPT="-M -t expanded"

THEME_NAME=CachyOS-Nord
SIZE_VARIANTS=('' '-compact')

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "48" ]]; then
    GS_VERSION="48-0"
  elif [[ "${SHELL_VERSION:-}" -ge "47" ]]; then
    GS_VERSION="47-0"
  elif [[ "${SHELL_VERSION:-}" -ge "46" ]]; then
    GS_VERSION="46-0"
  elif [[ "${SHELL_VERSION:-}" -ge "44" ]]; then
    GS_VERSION="44-0"
  elif [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-28"
  fi
else
  echo "'gnome-shell' not found, using styles for last gnome-shell version available."
  GS_VERSION="48-0"
fi

usage() {
cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)

  -n, --name NAME         Specify theme name (Default: $THEME_NAME)

  -s, --size VARIANT      Specify size variant [standard|compact] (Default: All variants)

  -i, --icon VARIANT      Specify icon variant(s) for shell panel
                          [default|apple|simple|gnome|ubuntu|arch|manjaro|fedora|debian|void|opensuse|popos|mxlinux|zorin|endeavouros|tux|nixos]
                          (Default: Windows)

  -l, --libadwaita        Install link to gtk4 config for theming libadwaita

  -r, --remove
  -u, --uninstall         Uninstall/remove themes or link for libadwaita

  --tweaks                Specify versions for tweaks [solid|float|round|blur|noborder|square]
                          solid:    no transparency version
                          float:    floating panel
                          round:    rounded windows
                          blur:     blur version for 'Blur-Me'
                          noborder: windows and menu with no border
                          square:   square windows button

  -h, --help              Show help
EOF
}

install() {
  local dest="$1"
  local name="$2"
  local size="$3"
  local icon="$4"
  # The source files of the theme's one color variant
  local color='-Dark'

  if [[ "$window" == 'round' ]]; then
    round='-round'
  else
    round=$window
  fi

  local THEME_DIR="$dest/$name$round$size"

  [[ -d "$THEME_DIR" ]] && rm -rf "${THEME_DIR:?}"

  theme_tweaks

  echo "Installing '$THEME_DIR'..."

  mkdir -p                                                                      "$THEME_DIR"
  cp -r "$REPO_DIR/COPYING"                                                     "$THEME_DIR"

  echo "[Desktop Entry]" >>                                                     "$THEME_DIR/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                              "$THEME_DIR/index.theme"
  echo "Name=$name$round$size" >>                                               "$THEME_DIR/index.theme"
  echo "Comment=CachyOS Nord GTK theme: navy and cyan" >>                       "$THEME_DIR/index.theme"
  echo "Encoding=UTF-8" >>                                                      "$THEME_DIR/index.theme"
  echo "" >>                                                                    "$THEME_DIR/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                 "$THEME_DIR/index.theme"
  echo "GtkTheme=$name$round$size" >>                                           "$THEME_DIR/index.theme"
  echo "MetacityTheme=$name$round$size" >>                                      "$THEME_DIR/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                           "$THEME_DIR/index.theme"

  mkdir -p                                                                      "$THEME_DIR/gnome-shell"
  cp -r "$SRC_DIR/gnome-shell/pad-osd.css"                                      "$THEME_DIR/gnome-shell"

  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT "$SRC_DIR/gnome-shell/shell-$GS_VERSION/gnome-shell$color$size.scss" "$THEME_DIR/gnome-shell/gnome-shell.css"
  else
    cp -r "$SRC_DIR/gnome-shell/shell-$GS_VERSION/gnome-shell$color$size.css"   "$THEME_DIR/gnome-shell/gnome-shell.css"
  fi

  cp -r "${SRC_DIR}/gnome-shell/common-assets"                                  "$THEME_DIR/gnome-shell/assets"
  cp -r "${SRC_DIR}/gnome-shell/assets-Dark/"*.svg                              "$THEME_DIR/gnome-shell/assets"
  cp -r "${SRC_DIR}/gnome-shell/theme/"*.svg                                    "$THEME_DIR/gnome-shell/assets"
  cp -r "${SRC_DIR}/gnome-shell/assets-Dark/activities/activities${icon}.svg"   "$THEME_DIR/gnome-shell/assets/activities.svg"

  if [[ "$window" = "round" ]] ; then
    cp -r "${SRC_DIR}/gnome-shell/assets-Dark/buttons-round/"*.svg              "$THEME_DIR/gnome-shell/assets"
  else
    cp -r "${SRC_DIR}/gnome-shell/assets-Dark/buttons/"*.svg                    "$THEME_DIR/gnome-shell/assets"
  fi

  if [[ "$opacity" = "solid" ]] ; then
    if [[ "$window" = "round" ]] ; then
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/solid-round/"*.svg            "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/solid-round-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
      fi
    else
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/solid/"*.svg                  "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/solid-borderless/"*.svg       "$THEME_DIR/gnome-shell/assets"
      fi
    fi
  else
    if [[ "$window" = "round" ]] ; then
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/default-round/"*.svg          "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/default-round-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
      fi
    else
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/default/"*.svg                "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets-Dark/default-borderless/"*.svg     "$THEME_DIR/gnome-shell/assets"
      fi
    fi
  fi

  cd "$THEME_DIR/gnome-shell"
  ln -s assets/no-events.svg no-events.svg
  ln -s assets/process-working.svg process-working.svg
  ln -s assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                      "$THEME_DIR/gtk-2.0"
  cp -r "$SRC_DIR/gtk-2.0/common/"{apps.rc,hacks.rc,main.rc}                    "$THEME_DIR/gtk-2.0"
  cp -r "$SRC_DIR/gtk-2.0/assets-folder/assets-Dark"                            "$THEME_DIR/gtk-2.0/assets"
  cp -r "$SRC_DIR/gtk-2.0/gtkrc-Dark"                                           "$THEME_DIR/gtk-2.0/gtkrc"

  mkdir -p                                                                      "$THEME_DIR/gtk-3.0"
  cp -r "$SRC_DIR/gtk/assets"                                                   "$THEME_DIR/gtk-3.0/assets"
  cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-3.0/assets"
  cp -r "$SRC_DIR/gtk/thumbnail-Dark.png"                                       "$THEME_DIR/gtk-3.0/thumbnail.png"

  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT "$SRC_DIR/gtk/3.0/gtk$color$size.scss"                     "$THEME_DIR/gtk-3.0/gtk.css"
  else
    cp -r "$SRC_DIR/gtk/3.0/gtk$color$size.css"                                 "$THEME_DIR/gtk-3.0/gtk.css"
  fi

  mkdir -p                                                                      "$THEME_DIR/gtk-4.0"
  cp -r "$SRC_DIR/gtk/assets"                                                   "$THEME_DIR/gtk-4.0/assets"
  cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-4.0/assets"

  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT "$SRC_DIR/gtk/4.0/gtk$color$size.scss"                     "$THEME_DIR/gtk-4.0/gtk.css"
  else
    cp -r "$SRC_DIR/gtk/4.0/gtk$color$size.css"                                 "$THEME_DIR/gtk-4.0/gtk.css"
  fi

  # GTK 4 falls back to Adwaita, not gtk.css, when a dark theme has no gtk-dark.css
  ln -s gtk.css                                                                 "$THEME_DIR/gtk-4.0/gtk-dark.css"

  mkdir -p                                                                      "$THEME_DIR/cinnamon"
  cp -r "$SRC_DIR/cinnamon/common-assets"                                       "$THEME_DIR/cinnamon/assets"
  cp -r "$SRC_DIR/cinnamon/assets-Dark/"*.svg                                   "$THEME_DIR/cinnamon/assets"

  if [[ "$opacity" == 'solid' ]]; then
    sassc $SASSC_OPT "$SRC_DIR/cinnamon/cinnamon$color$size.scss"               "$THEME_DIR/cinnamon/cinnamon.css"
  else
    cp -r "$SRC_DIR/cinnamon/cinnamon$color$size.css"                           "$THEME_DIR/cinnamon/cinnamon.css"
  fi

  cp -r "$SRC_DIR/cinnamon/thumbnail$color.png"                                 "$THEME_DIR/cinnamon/thumbnail.png"
  
  mkdir -p                                                                      "$THEME_DIR/xfwm4"

  if [[ "$titlebutton" = "square" ]] ; then
    cp -r "$SRC_DIR/xfwm4/assets-square$color/"*.png                            "$THEME_DIR/xfwm4"
    cp -r "$SRC_DIR/xfwm4/themerc-square"                                       "$THEME_DIR/xfwm4/themerc"
  else
    cp -r "$SRC_DIR/xfwm4/assets$color/"*.png                                   "$THEME_DIR/xfwm4"
    cp -r "$SRC_DIR/xfwm4/themerc"                                              "$THEME_DIR/xfwm4/themerc"
  fi

  mkdir -p                                                                      "$THEME_DIR/labwc"
  cp -r "$SRC_DIR/labwc/assets/"*.svg                                           "$THEME_DIR/labwc"
  cp -r "$SRC_DIR/labwc/themerc-Dark"                                           "$THEME_DIR/labwc/themerc"

  mkdir -p                                                                      "$THEME_DIR/metacity-1"
  cp -r "$SRC_DIR/metacity-1/metacity-theme-2$color.xml"                        "$THEME_DIR/metacity-1/metacity-theme-2.xml"

  if [[ "$window" = "round" ]] ; then
    cp -r "$SRC_DIR/metacity-1/metacity-theme-3-round.xml"                      "$THEME_DIR/metacity-1/metacity-theme-3.xml"
    cp -r "$SRC_DIR/metacity-1/assets-round"                                    "$THEME_DIR/metacity-1/assets"
  else
    cp -r "$SRC_DIR/metacity-1/metacity-theme-3.xml"                            "$THEME_DIR/metacity-1"
    cp -r "$SRC_DIR/metacity-1/assets"                                          "$THEME_DIR/metacity-1"
  fi

  cp -r "$SRC_DIR/metacity-1/thumbnail-Dark.png"                                "$THEME_DIR/metacity-1/thumbnail.png"
  cd "$THEME_DIR/metacity-1" && ln -s metacity-theme-2.xml metacity-theme-1.xml

  mkdir -p                                                                      "$THEME_DIR/plank"
  cp -r "$SRC_DIR/plank/theme/dock.theme"                                       "$THEME_DIR/plank"
}

sizes=()

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      name="$2"
      shift 2
      ;;
    -l|--libadwaita)
      libadwaita="true"
      shift
      ;;
    -u|--uninstall|-r|--remove)
      uninstall="true"
      shift
      ;;
    --tweaks)
      shift
      for tweaks in "$@"; do
        case "$tweaks" in
          solid)
            opacity="solid"
            shift
            ;;
          float)
            panel="float"
            echo -e "Install floating panel version ..."
            shift
            ;;
          round)
            window="round"
            echo -e "Install rounded windows version ..."
            shift
            ;;
          blur)
            blur="true"
            panel="compact"
            echo -e "Install blur version ..."
            shift
            ;;
          noborder)
            outline="false"
            echo -e "Install windows without outline version ..."
            shift
            ;;
          square)
            titlebutton="square"
            echo -e "Install square windows button version ..."
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized tweaks variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -i|--icon)
      activities='icon'
      shift
      for icons in "$@"; do
        case "$icons" in
          default)
            icon='-default'
            shift
            ;;
          apple)
            icon='-apple'
            shift
            ;;
          simple)
            icon='-simple'
            shift
            ;;
          gnome)
            icon='-gnome'
            shift
            ;;
          ubuntu)
            icon='-ubuntu'
            shift
            ;;
          arch)
            icon='-arch'
            shift
            ;;
          manjaro)
            icon='-manjaro'
            shift
            ;;
          fedora)
            icon='-fedora'
            shift
            ;;
          debian)
            icon='-debian'
            shift
            ;;
          void)
            icon='-void'
            shift
            ;;
          opensuse)
            icon='-opensuse'
            shift
            ;;
          popos)
            icon='-popos'
            shift
            ;;
          mxlinux)
            icon='-mxlinux'
            shift
            ;;
          zorin)
            icon='-zorin'
            shift
            ;;
          endeavouros)
            icon='-endeavouros'
            shift
            ;;
          tux)
            icon='-tux'
            shift
            ;;
          nixos)
            icon='-nixos'
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized icon variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
        echo "Install $icons icon for gnome-shell panel..."
      done
      ;;
    -s|--size)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            sizes+=("${SIZE_VARIANTS[0]}")
            shift
            ;;
          compact)
            sizes+=("${SIZE_VARIANTS[1]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized size variant '${1:-}'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '${1:-}'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#sizes[@]}" -eq 0 ]] ; then
  sizes=("${SIZE_VARIANTS[@]}")
fi

#  Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

#  Install needed packages
install_package() {
  if [ ! "$(which sassc 2> /dev/null)" ]; then
    echo sassc needs to be installed to generate the css.
    if has_command zypper; then
      sudo zypper in sassc
    elif has_command apt-get; then
      sudo apt-get install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command pacman; then
      sudo pacman -S --noconfirm sassc
    fi
  fi
}

tweaks_temp() {
  cp -rf ${SRC_DIR}/_sass/_tweaks.scss ${SRC_DIR}/_sass/_tweaks-temp.scss
  cp -rf ${SRC_DIR}/gnome-shell/sass/_tweaks.scss ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
}

install_float_panel() {
  sed -i "/\$panel_style:/s/compact/float/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$panel_style:/s/compact/float/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_solid() {
  sed -i "/\$opacity:/s/default/solid/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$opacity:/s/default/solid/" ${SRC_DIR}/_sass/_tweaks-temp.scss
  echo -e "Install solid version ..."
}

install_round() {
  sed -i "/\$window:/s/default/round/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$window:/s/default/round/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_blur() {
  sed -i "/\$blur:/s/false/true/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$blur:/s/false/true/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_noborder() {
  sed -i "/\$outline:/s/true/false/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$outline:/s/true/false/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_square() {
  sed -i "/\$titlebutton:/s/circular/square/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

activities_style() {
  sed -i "/\$activities:/s/default/icon/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
}

theme_tweaks() {
  if [[ "$panel" = "float" || "$opacity" == 'solid' || "$window" == 'round' || "$blur" == 'true' || "$outline" == 'false' || "$titlebutton" == 'square' || "$activities" = "icon" ]]; then
    tweaks='true'
    install_package; tweaks_temp
  fi

  if [[ "$panel" = "float" ]] ; then
    install_float_panel
  fi

  if [[ "$opacity" = "solid" ]] ; then
    install_solid
  fi

  if [[ "$window" = "round" ]] ; then
    install_round
  fi

  if [[ "$blur" = "true" ]] ; then
    install_blur
  fi

  if [[ "$outline" = "false" ]] ; then
    install_noborder
  fi

  if [[ "$titlebutton" = "square" ]] ; then
    install_square
  fi

  if [[ "$activities" = "icon" ]] ; then
    activities_style
  fi
}

uninstall() {
  local dest="${1}"
  local name="${2}"
  local size="${3}"

  if [[ "$window" == 'round' ]]; then
    round='-round'
  else
    round=$window
  fi

  local THEME_DIR="$dest/$name$round$size"

  if [[ -d "${THEME_DIR}" ]]; then
    echo -e "Uninstall ${THEME_DIR}... "
    rm -rf "${THEME_DIR}"
  fi
}

uninstall_link() {
  rm -rf "${HOME}/.config/gtk-4.0"/{assets,gtk.css,gtk-dark.css}
}

link_libadwaita() {
  local dest="$1"
  local name="$2"
  local size="$3"

  if [[ "$window" == 'round' ]]; then
    round='-round'
  else
    round=$window
  fi

  local THEME_DIR="$dest/$name$round$size"

  echo -e "\nLink '$THEME_DIR/gtk-4.0' to '${HOME}/.config/gtk-4.0' for libadwaita..."

  mkdir -p                                                                      "${HOME}/.config/gtk-4.0"
  ln -sf "${THEME_DIR}/gtk-4.0/assets"                                          "${HOME}/.config/gtk-4.0/assets"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk.css"                                         "${HOME}/.config/gtk-4.0/gtk.css"
}

clean_theme() {
  if [[ "$DEST_DIR" == "$HOME/.themes" ]]; then
    local dest="$HOME/.local/share/themes"
  fi

  for size in "${SIZE_VARIANTS[@]}"; do
    uninstall "${dest}" "${name:-$THEME_NAME}" "$size"
  done
}

uninstall_theme() {
  for size in "${sizes[@]}"; do
    uninstall "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$size"
  done
}

install_theme() {
  for size in "${sizes[@]}"; do
    install "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$size" "$icon"
  done
}

link_theme() {
  link_libadwaita "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "${sizes[0]}"
}

if [[ "$uninstall" == 'true' ]]; then
  if [[ "$libadwaita" == 'true' ]]; then
    echo -e "\nUninstall ${HOME}/.config/gtk-4.0 links ..."
    uninstall_link
  else
    echo && uninstall_theme && uninstall_link
  fi
else
   clean_theme && install_theme

   if [[ "$libadwaita" == 'true' ]]; then
     uninstall_link && link_theme
   fi
fi

echo
echo "Done."
