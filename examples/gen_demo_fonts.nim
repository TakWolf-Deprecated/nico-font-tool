import os
import nico_font_tool

const fontsDir = "../fonts/"
const outputsDir = "examples/assets/fonts"

removeDir(outputsDir)

createFontSheet(
    fontSize = 8,
    outputsName = "quan",
    outputsDir = outputsDir,
    fontFilePath = joinPath(fontsDir, "quan/quan.ttf"),
    glyphAdjustWidth = -1,
    glyphAdjustHeight = -1,
    autoHeightAlign = true, # 默认false
    autoAlphaAlign = true, # 默认为true
)

createFontSheet(
    fontSize = 12,
    outputsName = "fusion-pixel-monospaced",
    outputsDir = outputsDir,
    fontFilePath = joinPath(fonts_dir, "fusion-pixel-monospaced/fusion-pixel-monospaced.otf"),
    glyphOffsetY = -1,
    glyphAdjustWidth = -1,
    glyphAdjustHeight = -1,
)
createFontSheet(
    fontSize = 12,
    outputsName = "fusion-pixel-proportional",
    outputsDir = outputsDir,
    fontFilePath = joinPath(fonts_dir, "fusion-pixel-proportional/fusion-pixel-proportional.otf"),
    glyphOffsetY = -1,
    glyphAdjustWidth = -1,
    glyphAdjustHeight = -1,
    autoHeightAlign = true
)
createFontSheet(
    fontSize = 16,
    outputsName = "unifont",
    outputsDir = outputsDir,
    fontFilePath = joinPath(fonts_dir, "unifont/unifont-15.0.01.ttf"),
    glyphAdjustWidth = -1,
    glyphAdjustHeight = -6,
    autoHeightAlign = true
    autoAlphaAlign = false
)
createFontSheet(
    fontSize = 24,
    outputsName = "roboto",
    outputsDir = outputsDir,
    fontFilePath = joinPath(fonts_dir, "roboto/Roboto-Regular.ttf"),
)
