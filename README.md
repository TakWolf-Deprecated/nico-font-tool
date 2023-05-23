# NICO Font tool

A tool for converting fonts to [NICO Game Framework](https://github.com/ftsf/nico) format fonts.

There is also a Python version see: [nico-font-tool.python](https://github.com/TakWolf/nico-font-tool.python).

## Installation

```commandline
nimble install nico_font_tool
```

## Usage

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
