# SVG to OTF converter

`convert_svg_to_otf.py` converts an SVG icon into a one-glyph font using the
private-use character `U+E000` by default.

## Requirements

Install `fontTools` if needed:

```bash
python3 -m pip install fonttools
```

## Usage

```bash
./convert_svg_to_otf.py input.svg output.otf
```

Example:

```bash
./convert_svg_to_otf.py \
  icons/fluent--person-sound-spatial-16-filled.svg \
  icons/fluent-person-sound-spatial.otf
```

Use a different private-use codepoint with:

```bash
./convert_svg_to_otf.py input.svg output.otf --codepoint 0xE001
```

Load the generated font in a Noctalia widget:

```lua
local iconFont = noctalia.loadFont("icons/fluent-person-sound-spatial.otf")
barWidget.setFont(iconFont, "pictographic")
barWidget.setText("\u{E000}")
```
