# NICO Font tool

A tool for converting fonts to [NICO Game Framework](https://github.com/ftsf/nico) format fonts.

There is also a Python version see: [nico-font-tool.python](https://github.com/TakWolf/nico-font-tool.python).

## Installation

```commandline
nimble install nico_font_tool
```

## Usage

### Command

For example:

```commandline
nicofont ./assets/fonts/quan/quan.ttf ./examples/assets/fonts/demo quan --fontSize=8
```

All params:

```text
nicofont {fontFilePath} {outputsDir} {outputsName}

options:
  -fs, --fontSize
      Glyph rasterize size when using OpenType font.
  -gox, --glyphOffsetX
      Glyph offset x.
  -goy, --glyphOffsetY
      Glyph offset y.
  -gaw, --glyphAdjustWidth
      Glyph adjust width.
  -gah, --glyphAdjustHeight
      Glyph adjust height.
  -m, --mode
      Png sheet color mode, can be 'palette' or 'rgba', default is 'palette'.
```

### Scripts

See: [gen_fonts](examples/gen_fonts.nim)

```nim
import nico_font_tool

let (sheetData, alphabet) = createSheet("your/font/file/path.ttf", 8)

savePalettePng(sheetData, "outputs/palette/dir", "outputsName")
saveDatFile(alphabet, "outputs/palette/dir", "outputsName")
  
saveRgbaPng(sheetData, "outputs/rgba/dir", "outputsName")
saveDatFile(alphabet, "outputs/rgba/dir", "outputsName")
```

## Dependencies

- [Pixie](https://github.com/treeform/pixie)
- [nimPNG](https://github.com/jangko/nimPNG)

## License

Under the [MIT license](LICENSE).
