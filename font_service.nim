
const glyphDataTransparent = 0
const glyphDataSolid = 1
const glyphDataBorder = 2

proc createFontSheet*(
    fontSize: uint,
    outputsName: string,
    outputsDir: string,
    fontFilePath: string,
    glyphOffsetX: int = 0,
    glyphOffsetY: int = 0,
    glyphAdjustWidth: int = 0,
    glyphAdjustHeight: int = 0,
) =
  # 加载字体
  echo fontSize, outputsName, outputsDir, fontFilePath, glyphOffsetX, glyphOffsetY, glyphAdjustWidth, glyphAdjustHeight
