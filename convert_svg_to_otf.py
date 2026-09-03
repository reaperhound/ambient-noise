#!/usr/bin/env python3
"""Convert an SVG icon into a one-glyph private-use font."""

import argparse
import os
import tempfile
import xml.etree.ElementTree as ET

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.svgLib.path import SVGPath


def convert(source, destination, codepoint=0xE000):
    root = ET.parse(source).getroot()
    view_box = [float(value) for value in root.get("viewBox", "0 0 16 16").split()]
    view_width, view_height = view_box[2], view_box[3]
    for element in list(root):
        if element.tag.rsplit("}", 1)[-1] == "path" and element.get("fill") == "none":
            root.remove(element)

    filtered = tempfile.NamedTemporaryFile("wb", suffix=".svg", delete=False)
    try:
        filtered.write(ET.tostring(root, encoding="utf-8"))
        filtered.close()

        units = 1000
        family_name = f"Custom {os.path.splitext(os.path.basename(destination))[0].replace('-', ' ').title()} Icon"
        glyph_pen = TTGlyphPen(None)
        pen = TransformPen(
            Cu2QuPen(glyph_pen, 1 / 16),
            (units / view_width, 0, 0, -units / view_height, 0, units),
        )
        SVGPath(filtered.name).draw(pen)

        builder = FontBuilder(units, isTTF=True)
        builder.setupGlyphOrder([".notdef", "icon"])
        builder.setupCharacterMap({codepoint: "icon"})
        builder.setupGlyf({".notdef": TTGlyphPen(None).glyph(), "icon": glyph_pen.glyph()})
        builder.setupHorizontalMetrics({".notdef": (units, 0), "icon": (units, 0)})
        builder.setupHorizontalHeader(ascent=800, descent=-200)
        builder.setupNameTable({
            "familyName": family_name,
            "styleName": "Regular",
            "uniqueFontIdentifier": f"{family_name} Regular",
            "fullName": f"{family_name} Regular",
            "psName": f"{family_name.replace(' ', '')}-Regular",
        })
        builder.setupOS2(sTypoAscender=800, sTypoDescender=-200, usWinAscent=1000, usWinDescent=200)
        builder.setupPost()
        builder.setupMaxp()
        builder.save(destination)
    finally:
        os.unlink(filtered.name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input_svg")
    parser.add_argument("output_otf")
    parser.add_argument("--codepoint", type=lambda value: int(value, 0), default=0xE000)
    args = parser.parse_args()
    convert(args.input_svg, args.output_otf, args.codepoint)
