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
  glyphOffsetX, glyphOffsetY, glyphAdjustWidth, glyphAdjustHeight: int = 0,
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
    fontFileName = "quan/quan.ttf",
    outputsName = "quan",
    fontSize = 8,
)
convertFont(
    fontFileName = "fusion-pixel-monospaced/fusion-pixel-monospaced.otf",
    outputsName = "fusion-pixel-monospaced",
    fontSize = 12,
)
convertFont(
    fontFileName = "fusion-pixel-proportional/fusion-pixel-proportional.otf",
    outputsName = "fusion-pixel-proportional",
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
