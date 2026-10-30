## CachyOS-Nord app themes

Themes for terminals, Sublime Text and Prism Launcher in the colors of the CachyOS-Nord GTK
theme: a navy background (`#0F121C`) with cyan text (`#47ADD6`), cyan cursor and selection,
and the theme's green, olive and mauve in the 16-color palette. Red and blue come from
CachyOS's Nordic Konsole scheme.

Each terminal has two variants:

- `cachyos-nord`: opaque
- `cachyos-nord-transparent`: the terminal window at 0.25 opacity (as in the Nexus theme),
  and btop without a background of its own, so the translucent terminal shows through

### Alacritty

```sh
mkdir -p ~/.config/alacritty/themes
cp alacritty/cachyos-nord*.toml ~/.config/alacritty/themes/
```

In `~/.config/alacritty/alacritty.toml`:

```toml
[general]
import = ["~/.config/alacritty/themes/cachyos-nord.toml"]   # or cachyos-nord-transparent.toml
```

Remove any `[colors]` sections from `alacritty.toml`, and for the transparent variant any
`[window] opacity`: `alacritty.toml` loads after its imports and would override them.

### Ghostty

```sh
mkdir -p ~/.config/ghostty/themes
cp ghostty/cachyos-nord* ~/.config/ghostty/themes/
```

In `~/.config/ghostty/config.ghostty` (or `config`):

```
theme = cachyos-nord   # or cachyos-nord-transparent
```

Colors, and for the transparent variant `background-opacity`, set in the config file
override the theme.

### btop

```sh
mkdir -p ~/.config/btop/themes
cp btop/cachyos-nord*.theme ~/.config/btop/themes/
```

In `~/.config/btop/btop.conf` (or from btop's options menu):

```
color_theme = "cachyos-nord"   # or "cachyos-nord-transparent"
theme_background = true
```

Use the transparent btop theme in a transparent terminal; the opaque one draws its own navy
background.

### Konsole

```sh
mkdir -p ~/.local/share/konsole
cp konsole/CachyOS-Nord*.colorscheme ~/.local/share/konsole/
```

Then pick *CachyOS-Nord* or *CachyOS-Nord (transparent)* in Settings → Edit Current Profile →
Appearance. The transparent one sets the background opacity to 0.25 (blur is left off, as in
CachyOS's own scheme).

### Sublime Text 4

A color scheme for the editor and a UI theme for the sidebar, tabs and panels. The UI theme
extends Sublime's Adaptive theme, which takes its colors from the color scheme, and adds the
GTK theme's touches: cyan sidebar and status bar text, and the selected sidebar row filled cyan
at 0.6 with navy text.

```sh
cp sublime-text/CachyOS-Nord.sublime-* ~/.config/sublime-text/Packages/User/
```

In Preferences → Settings:

```json
"theme": "CachyOS-Nord.sublime-theme",
"color_scheme": "Packages/User/CachyOS-Nord.sublime-color-scheme",
```

Give the color scheme's full path as above if you use the
[Color Highlight](https://github.com/SublimeText/ColorHighlight) plugin: it looks for color
schemes given by name only in Sublime's *Color Scheme - Default* package, and otherwise can't add
its rules, so color values aren't highlighted in their own colors. With the full path it adds
them to `CachyOS-Nord.sublime-color-scheme` itself (keeping a `.chback` backup next to it).

### Prism Launcher

A theme for [Prism Launcher](https://prismlauncher.org/) (MultiMC itself doesn't load custom
themes): the navy and cyan palette on Qt's Fusion style, plus a stylesheet for the GTK theme's
details (cyan-bordered checkboxes and radio buttons with the check, dash and dot glyphs, tabs
with a cyan top line, list selections filled cyan at 0.6 with navy text, and thin scrollbars),
and log colors (warnings olive, errors red, fatal errors mauve).

There are two variants:

- `CachyOS-Nord`: the GTK theme's colors
- `CachyOS-Nord-Bright`: near-white text (`#E6F7FD`) and light cyan accents (`#9FDCF2`) on the
  same navy, for use with a translucent window (see [Transparency](#transparency) below), where
  the regular cyan text gets hard to read

Copy the folders into Prism's `themes` folder. Keep their names: each stylesheet finds its
images under `themes/<folder name>/`.

```sh
# AppImage or native package
mkdir -p ~/.local/share/PrismLauncher/themes
cp -r prismlauncher/CachyOS-Nord* ~/.local/share/PrismLauncher/themes/

# Flatpak
mkdir -p ~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/themes
cp -r prismlauncher/CachyOS-Nord* ~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/themes/
```

Then restart Prism and pick *CachyOS-Nord* or *CachyOS-Nord (bright)* under Settings →
Appearance → Theme.

#### Transparency

The themes themselves are opaque: Prism doesn't ask Qt for translucent windows, so a theme with
translucent colors leaves the compositor treating the window as opaque, and it doesn't repaint
what's behind it (old frames show through as trails). Have the compositor make the window
translucent instead; text and icons fade with it. On Wayfire (and Budgie on Wayfire), with the
`alpha` and `window-rules` plugins enabled, add a rule to the `[window-rules]` section of
`wayfire.ini` (`~/.config/budgie-desktop/wayfire/wayfire.ini` on Budgie):

```ini
[window-rules]
prism_alpha = on created if app_id is "org.prismlauncher.PrismLauncher" then set alpha 0.5
```

Use the bright variant with it. At 0.5 its text stays readable over a dark wallpaper; raise the
value (0.6–0.7) over a busy or light one. Lower values such as the terminals' 0.25 leave even
near-white text faint, since the text fades along with the window.
