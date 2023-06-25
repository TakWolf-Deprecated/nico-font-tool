import os
import nico_font_tool

const fontsDir = "assets/fonts/"
const outputsDir = "examples/assets/fonts"
const outputsPaletteDir = joinPath(outputsDir, "palette")
const outputsRgbaDir = joinPath(outputsDir, "rgba")

removeDir(outputsDir)
createDir(outputsPaletteDir)
createDir(outputsRgbaDir)

proc convertFont(
  fontFileName: string,
  outputsName: string,
  fontSize: uint = 0,
  glyphOffsetX: int = 0, 
  glyphOffsetY: int = 0, 
  glyphAdjustWidth: int = 0,
  glyphAdjustHeight: int = 0,
) =
  let fontFilePath = joinPath(fontsDir, fontFileName)
  let (sheetData, alphabet) = createSheet(
    fontFilePath,
    fontSize,
    glyphOffsetX,
    glyphOffsetY,
    glyphAdjustWidth,
    glyphAdjustHeight,
  )

  savePalettePng(sheetData, outputsPaletteDir, outputsName)
  saveDatFile(alphabet, outputsPaletteDir, outputsName)
  
  saveRgbaPng(sheetData, outputsRgbaDir, outputsName)
  saveDatFile(alphabet, outputsRgbaDir, outputsName)

convertFont(
  fontFileName = "fusion-pixel/fusion-pixel-8px-monospaced.otf",
  outputsName = "fusion-pixel-8px-monospaced",
  fontSize = 8,
)
convertFont(
  fontFileName = "fusion-pixel/fusion-pixel-8px-proportional.otf",
  outputsName = "fusion-pixel-8px-proportional",
  fontSize = 8,
)
convertFont(
  fontFileName = "fusion-pixel/fusion-pixel-10px-monospaced.otf",
  outputsName = "fusion-pixel-10px-monospaced",
  fontSize = 10,
)
convertFont(
  fontFileName = "fusion-pixel/fusion-pixel-10px-proportional.otf",
  outputsName = "fusion-pixel-10px-proportional",
  fontSize = 10,
)
convertFont(
  fontFileName = "fusion-pixel/fusion-pixel-12px-monospaced.otf",
  outputsName = "fusion-pixel-12px-monospaced",
  fontSize = 12,
)
convertFont(
  fontFileName = "fusion-pixel/fusion-pixel-12px-proportional.otf",
  outputsName = "fusion-pixel-12px-proportional",
  fontSize = 12,
)
convertFont(
  fontFileName = "unifont/unifont-15.0.01.ttf",
  outputsName = "unifont",
  fontSize = 16,
)
convertFont(
  fontFileName = "roboto/Roboto-Regular.ttf",
  outputsName = "roboto",
  fontSize = 24,
)
