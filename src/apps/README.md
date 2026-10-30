## CachyOS-Nord app themes

Themes for terminal apps in the colors of the CachyOS-Nord GTK theme: a navy background
(`#0F121C`) with cyan text (`#47ADD6`), cyan cursor and selection, and the theme's green,
olive and mauve in the 16-color palette. Red and blue come from CachyOS's Nordic Konsole
scheme.

Each app has two variants:

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
