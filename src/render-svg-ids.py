#!/usr/bin/env python3
"""render-svg-ids.py SVG OUTDIR [--scale N] [--suffix S] ID...

Renders each element ID to OUTDIR/ID{suffix}.png the way `inkscape --export-id=ID
--export-id-only` does, with librsvg: the export area is the element's visual bounding
box (cut down to its clip path), rounded to whole pixels, and other elements are hidden.
--scale 2 matches Inkscape's --export-dpi=192. Used by the render-assets.sh scripts
when neither rendersvg nor inkscape is installed; needs python-gobject, python-cairo
and librsvg.
"""
import re
import sys

import cairo
import gi

gi.require_version("Rsvg", "2.0")
from gi.repository import Rsvg

args = sys.argv[1:]
svg, outdir = args[0], args[1]
scale, suffix, ids = 1.0, "", []
it = iter(args[2:])
for a in it:
    if a == "--scale":
        scale = float(next(it))
    elif a == "--suffix":
        suffix = next(it)
    else:
        ids.append(a)

src = open(svg, encoding="utf-8").read()

# Assets lie outside the page, and librsvg clips to it (e.g. the offscreen layer of an
# element with opacity), unlike Inkscape, so render on an enlarged page with the same
# user units (e.g. a viewBox in mm on a page in px)
tag = re.search(r"<svg\b[^>]*>", src)
attr = dict(re.findall(r'\s(width|height|viewBox)="([^"]*)"', tag.group(0)))
if "viewBox" in attr:
    vx, vy, vw, vh = (float(v) for v in attr["viewBox"].replace(",", " ").split())
    px = float(re.match(r"[\d.]+", attr.get("width", str(vw))).group(0)) / vw
else:  # without a viewBox, user units are pixels
    vx = vy = 0.0
    px = 1.0
root = re.sub(r'\s(width|height|viewBox)="[^"]*"', "", tag.group(0))
root = root[:-1] + f' width="{8000 * px}" height="{8000 * px}" viewBox="{vx} {vy} 8000 8000">'
src = src[: tag.start()] + root + src[tag.end() :]

# librsvg's bounding boxes ignore clip-path; Inkscape's don't. For each clipped element,
# copy its clip rectangle into it as an invisible marker, in the same user space, to
# measure the clip area with (in a separate copy: librsvg counts unpainted shapes in a
# group's box).
clip_rects = {
    m.group(1): re.search(r"<rect\b[^>]*>", m.group(2)).group(0)
    for m in re.finditer(r'<clipPath\b[^>]*\bid="([^"]+)"[^>]*>(.*?)</clipPath>', src, re.S)
    if re.search(r"<rect\b", m.group(2))
}
clipped = set()


def unclip(m):
    tag = m.group(0)
    eid = re.search(r'\bid="([^"]+)"', tag)
    clip = re.search(r'\bclip-path="url\(#([^)]+)\)"', tag)
    if not (eid and clip and clip.group(1) in clip_rects) or tag.endswith("/>"):
        return tag
    rect = clip_rects[clip.group(1)]
    attrs = {k: v for k, v in re.findall(r'(?<![-\w])(x|y|width|height|transform)="([^"]*)"', rect)}
    marker = "<rect " + " ".join(f'{k}="{v}"' for k, v in attrs.items())
    marker += f' id="{eid.group(1)}__clip" fill="none" stroke="none"/>'
    clipped.add(eid.group(1))
    # librsvg also merges the clip area into the group's box, so drop the clip: the
    # export area is cut down to it anyway
    return tag.replace(clip.group(0), "") + (marker if with_marker else "")


with_marker = True
markers = Rsvg.Handle.new_from_data(re.sub(r"<g\b[^>]*>", unclip, src).encode())
with_marker = False
h = Rsvg.Handle.new_from_data(re.sub(r"<g\b[^>]*>", unclip, src).encode())
ok, w, ht = h.get_intrinsic_size_in_pixels()
vp = Rsvg.Rectangle()
vp.x = vp.y = 0
vp.width, vp.height = w, ht

for i in ids:
    ok, ink, logical = h.get_geometry_for_layer("#" + i, vp)
    if not ok:
        print("no element", i, file=sys.stderr)
        continue
    x0, y0, x1, y1 = ink.x, ink.y, ink.x + ink.width, ink.y + ink.height
    if i in clipped:
        ok, _, c = markers.get_geometry_for_layer(f"#{i}__clip", vp)
        x0, y0 = max(x0, c.x), max(y0, c.y)
        x1, y1 = min(x1, c.x + c.width), min(y1, c.y + c.height)
    # Inkscape rounds the export area to whole pixels
    x0, y0, x1, y1 = (round(v * scale) for v in (x0, y0, x1, y1))
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, x1 - x0, y1 - y0)
    cr = cairo.Context(surf)
    cr.translate(-x0, -y0)
    cr.scale(scale, scale)
    h.render_layer(cr, "#" + i, vp)
    surf.write_to_png(f"{outdir}/{i}{suffix}.png")
