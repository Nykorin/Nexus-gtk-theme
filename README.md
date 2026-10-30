# CachyOS-Nord GTK theme

CachyOS-Nord is the GTK theme of the CachyOS Nord desktop: navy backgrounds with a cyan
accent, for GNOME/GTK based desktop environments. It comes in one color variant
(installed as CachyOS-Nord and CachyOS-Nord-compact): navy backgrounds (`#0F121C`, `#131621`,
`#181B28`) with cyan (`#47ADD6`) text and accent, cyan-tinted borders and shadows, and a
cyan glow around windows.

On the navy title bars, the minimize, maximize and close buttons glow when hovered
(cyan, close in red).

## Requirements

- GTK `>=3.20`
- `gnome-themes-extra` (or `gnome-themes-standard`)
- Murrine engine — The package name depends on the distro.
  - `gtk-engine-murrine` on Arch Linux
  - `gtk-murrine-engine` on Fedora
  - `gtk2-engine-murrine` on openSUSE
  - `gtk2-engines-murrine` on Debian, Ubuntu, etc.
- `sassc` — build dependency

## Installation

Run the following commands in the terminal:

```sh
./install.sh
```

> Tip: `./install.sh` allows the following options:

```
-d, --dest DIR          Specify destination directory (Default: $HOME/.themes)

-n, --name NAME         Specify theme name (Default: CachyOS-Nord)

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
```

The blur tweak needs [Blur My Shell](https://github.com/aunetx/blur-my-shell) on GNOME Shell.

### Flatpak

Automatically install your host GTK+ theme as a Flatpak:
[pakitheme](https://github.com/refi64/pakitheme)

### Firefox theme

[Install Firefox theme](src/firefox)

### Terminal app themes

Themes for Alacritty, Ghostty and btop in the same colors, each opaque or transparent:
[Install app themes](src/apps)

## Development

- `./parse-sass.sh` regenerates the precompiled CSS in `src/` (used when installing
  without `--tweaks`) from the SCSS in `src/_sass`, `src/gnome-shell/sass` and
  `src/cinnamon`. The colors are in `src/_sass/_colors.scss`.
- `src/gtk/render-assets.sh` and `src/gtk-2.0/assets-folder/render-assets.sh` render the
  PNG assets from `assets*.svg`, for those missing from the assets folders (delete one
  to re-render it). They use `rendersvg` or Inkscape when installed, and otherwise
  `src/render-svg-ids.py` (librsvg, with python-gobject and python-cairo).

## License

GPL-3.0, see [COPYING](COPYING) and [NOTICE](NOTICE).

CachyOS-Nord is a modified version of the
[Fluent GTK theme](https://github.com/vinceliuice/Fluent-gtk-theme) by vinceliuice: recolored
to the CachyOS Nord palette, with only a dark color variant.

The color scheme and the widget styling of the original theme come from the cachyOS-nord GTK
theme in [CachyOS-Nord-KDE](https://github.com/CachyOS/CachyOS-Nord-KDE) by CachyOS, which
CachyOS distributes under GPL-3.0 as the
[cachyos-nord-gtk-theme-git](https://dashboard.cachyos.org/package/cachyos/any/cachyos-nord-gtk-theme-git)
package. See [NOTICE](NOTICE) for details.
