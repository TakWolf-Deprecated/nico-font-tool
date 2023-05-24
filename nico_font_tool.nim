import os
import algorithm
import strutils
import sugar
import unicode
import pixie
import pixie/fontformats/opentype
import nimPNG

const 
  glyphDataTransparent: uint8 = 0
  glyphDataSolid: uint8 = 1
  glyphDataBorder: uint8 = 2

proc createSheet*(
  fontFilePath: string,
  fontSize: uint = 0,
  glyphOffsetX: int = 0, 
  glyphOffsetY: int = 0, 
  glyphAdjustWidth: int = 0, 
  glyphAdjustHeight: int = 0,
): tuple[sheetData: seq[seq[uint8]], alphabet: string] =
  # 加载字体文件
  let fontFileExt = splitFile(fontFilePath).ext.toLowerAscii()
  if fontFileExt != ".otf" and fontFileExt != ".ttf":
    raise newException(CatchableError, "Unsupported font format")
  if fontSize == 0:
    raise newException(CatchableError, "OpenType need a font size")
  let openType = parseOpenType(readFile(fontFilePath))
  let font = readFont(fontFilePath)
  font.size = fontSize.float32
  echo "loaded font file: ", fontFilePath

  # 计算字体参数
  let pxUnits = openType.head.unitsPerEm.float32 / fontSize.float32
  var lineHeight = math.ceil((openType.hhea.ascender - openType.hhea.descender).float32 / pxUnits).int
  lineHeight += glyphAdjustHeight

  # 图集对象，初始化左边界
  var sheetData: seq[seq[uint8]]
  for _ in 0 ..< lineHeight:
    sheetData.add(@[glyphDataBorder])

  # 字母表
  var alphabet = ""

  # 遍历字体全部字符
  var glyphOrder: seq[(Rune, int)]
  for rune, glyphId in openType.cmap.runeToGlyphId:
    glyphOrder.add((rune, glyphId.int))
  glyphOrder.sort((x, y) => cmp(x[0].int32, y[0].int32))
  for (rune, glyphId) in glyphOrder:
    # 获取字符宽度
    var advanceWidth = 0
    if glyphId < openType.hmtx.hMetrics.len:
      advanceWidth = math.ceil(openType.hmtx.hMetrics[glyphId].advanceWidth.float32 / pxUnits).int
    if advanceWidth <= 0:
      continue
    advanceWidth += glyphAdjustWidth
    if advanceWidth <= 0:
      continue

    # 栅格化
    let glyphImage = newImage(advanceWidth, lineHeight)
    glyphImage.fillText(font.typeset($rune), translate(vec2(glyphOffsetX.float32, glyphOffsetY.float32)))
    echo "rasterize rune: ", rune.int32, " - ", rune, " - ", glyphImage.width, " - ", glyphImage.height

    # 二值化字形，合并到图集
    for y in 0 ..< glyphImage.height:
      for x in 0 ..< glyphImage.width:
        let alpha = glyphImage.data[glyphImage.dataIndex(x, y)].a
        if alpha > 127:
          sheetData[y].add(glyphDataSolid)
        else:
          sheetData[y].add(glyphDataTransparent)
      sheetData[y].add(glyphDataBorder)

    # 添加到字母表
    alphabet &= $rune

  return (sheetData, alphabet)

proc savePalettePng*(
  sheetData: seq[seq[uint8]],
  outputsDir: string,
  outputsName: string,
) =
  let pngFilePath = joinPath(outputsDir, outputsName & ".png")
  var bitmap: seq[uint8]
  for y in 0 ..< sheetData.len:
    for x in 0 ..< sheetData[0].len:
      let color = sheetData[y][x]
      if color == glyphDataTransparent:
        bitmap.add(0)
        bitmap.add(0)                
        bitmap.add(0)
        bitmap.add(0)
      elif color == glyphDataSolid:
        bitmap.add(0)
        bitmap.add(0)                
        bitmap.add(0)
        bitmap.add(255)
      else:
        bitmap.add(255)
        bitmap.add(0)                
        bitmap.add(255)
        bitmap.add(255)
  let enc = makePNGEncoder()
  enc.modeOut.colorType = LCT_PALETTE
  enc.modeOut.bitDepth = 8
  enc.modeOut.addPalette(0, 0, 0, 0)
  enc.modeOut.addPalette(0, 0, 0, 255)
  enc.modeOut.addPalette(255, 0, 255, 255)
  enc.autoConvert = false
  discard savePNG32(pngFilePath, bitmap, sheetData[0].len, sheetData.len, enc)
  echo "make: ", pngFilePath

proc saveRgbaPng*(
  sheetData: seq[seq[uint8]],
  outputsDir: string,
  outputsName: string,
) =
  let pngFilePath = joinPath(outputsDir, outputsName & ".png")
  var bitmap: seq[uint8]
  for y in 0 ..< sheetData.len:
    for x in 0 ..< sheetData[0].len:
      let color = sheetData[y][x]
      if color == glyphDataTransparent:
        bitmap.add(0)
        bitmap.add(0)                
        bitmap.add(0)
        bitmap.add(0)
      elif color == glyphDataSolid:
        bitmap.add(0)
        bitmap.add(0)                
        bitmap.add(0)
        bitmap.add(255)
      else:
        bitmap.add(255)
        bitmap.add(0)                
        bitmap.add(255)
        bitmap.add(255)
  var enc = makePNGEncoder()
  enc.modeOut.colorType = LCT_RGBA
  enc.modeOut.bitDepth = 8
  enc.autoConvert = false
  discard savePNG32(pngFilePath, bitmap, sheetData[0].len, sheetData.len, enc)
  echo "make: ", pngFilePath

proc saveDatFile*(
  alphabet: string,
  outputsDir: string,
  outputsName: string,
) =
  let datFilePath = joinPath(outputsDir, outputsName & ".png.dat")
  writeFile(datFilePath, alphabet)
  echo "make: ", datFilePath
