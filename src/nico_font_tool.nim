import os
import algorithm
import strutils
import sugar
import unicode
import pixie
import pixie/fontformats/opentype
import nimPNG

const glyphDataTransparent: uint8 = 0
const glyphDataSolid: uint8 = 1
const glyphDataBorder: uint8 = 2

proc createFontSheet*(
    fontSize: uint,
    outputsName, outputsDir: string,
    fontFilePath: string,
    glyphOffsetX, glyphOffsetY, glyphAdjustWidth, glyphAdjustHeight: int = 0,
    autoHeightAlign = true # 当校准为负数时, 会自动对齐超过lineHeight并且首部为空白的字体
) =
  # 加载字体文件
  let fontFileExt = splitFile(fontFilePath).ext.toLowerAscii
  if fontFileExt != ".otf" and fontFileExt != ".ttf":
    raise newException(CatchableError, "Unsupported font format")
  let openType = parseOpenType(readFile(fontFilePath))
  let font = readFont(fontFilePath)
  font.size = float32(fontSize)
  echo "loaded font file: ", fontFilePath

  # 计算字体参数
  let pxUnits = float32(openType.head.unitsPerEm) / float32(fontSize)
  var lineHeight = int(math.ceil(float32(openType.hhea.ascender - openType.hhea.descender) / pxUnits))
  var autoHeight = autoHeightAlign
  let lineHeightDefault = lineHeight
  lineHeight += glyphAdjustHeight
  if glyphAdjustHeight >= 0:
    autoHeight = false

  # 图集对象，初始化左边界
  var sheetData: seq[seq[uint8]]
  for _ in 0 ..< lineHeight:
    sheetData.add(@[glyphDataBorder])
  var sheetWidth = 1

  # 字母表
  var alphabet = ""

  # 遍历字体全部字符
  var glyphOrder: seq[(Rune, int)]
  for rune, glyphId in openType.cmap.runeToGlyphId:
    glyphOrder.add((rune, int(glyphId)))
  glyphOrder.sort((x, y) => cmp(x[0].int32, y[0].int32))
  for (rune, glyphId) in glyphOrder:
    # 获取字符宽度
    var advanceWidth = 0
    if glyphId < openType.hmtx.hMetrics.len():
      advanceWidth = int(math.ceil(float32(openType.hmtx.hMetrics[glyphId].advanceWidth) / pxUnits))
    if advanceWidth <= 0:
      continue
    advanceWidth += glyphAdjustWidth
    if advanceWidth <= 0:
      continue

    # 栅格化
    let glyphImage = newImage(advanceWidth, if autoHeight: lineHeightDefault else: lineHeight)
    glyphImage.fillText(font.typeset($rune), translate(vec2(float32(glyphOffsetX), float32(glyphOffsetY))))
    echo "rasterize rune: ", rune.int32, " - ", rune, " - ", glyphImage.width, " - ", glyphImage.height

    # 二值化字形，添加到临时组
    var chs: seq[seq[uint8]]
    for y in 0 ..< glyphImage.height:
      chs.add(@[])
      for x in 0 ..< glyphImage.width:
        let alpha = glyphImage.data[glyphImage.dataIndex(x, y)].a
        if alpha > 127:
          chs[y].add(glyphDataSolid)
        else:
          chs[y].add(glyphDataTransparent)
      chs[y].add(glyphDataBorder)

    # 探测该字符是否越位得到yOffset
    var yOffset = 0
    block autoHeightChk:
      if autoHeight:
        let yn = lineHeightDefault - lineHeight
        if yn < 1: break
        for i in 0..<yn:
          block autoHeight2:
            for x in 0..<chs[0].len():
              if chs[^1][x] == glyphDataSolid:
                for xx in 0..<chs[0].len():
                  if chs[0][xx] == glyphDataSolid:
                    break autoHeightChk
                  else:
                    yOffset.inc
                    break autoHeight2

    for y in 0..<lineHeight:
      sheetData[y].add(chs[y + yOffset])

    sheetWidth += advanceWidth + 1

    # 添加到字母表
    alphabet &= $rune

  # 图集底部添加 1 像素边界
  var sheetDataBottomRow: seq[uint8]
  for _ in 0 ..< sheetWidth:
    sheetDataBottomRow.add(glyphDataBorder)
  sheetData.add(sheetDataBottomRow)

  # 创建 palette 输出文件夹
  let outputsPaletteDir = joinPath(outputsDir, "palette")
  createDir(outputsPaletteDir)

  # 写入 palette .png 图集
  let palettePngFilePath = joinPath(outputsPaletteDir, outputsName & ".png")
  var paletteBitmap: seq[uint8]
  for y in 0 ..< sheetData.len():
    for x in 0 ..< sheetWidth:
      let color = sheetData[y][x]
      if color == glyphDataTransparent:
        paletteBitmap.add(0)
        paletteBitmap.add(0)
        paletteBitmap.add(0)
        paletteBitmap.add(0)
      elif color == glyphDataSolid:
        paletteBitmap.add(0)
        paletteBitmap.add(0)
        paletteBitmap.add(0)
        paletteBitmap.add(255)
      else:
        paletteBitmap.add(255)
        paletteBitmap.add(0)
        paletteBitmap.add(255)
        paletteBitmap.add(255)
  let paletteEnc = makePNGEncoder()
  paletteEnc.modeOut.colorType = LCT_PALETTE
  paletteEnc.modeOut.bitDepth = 8
  paletteEnc.modeOut.addPalette(0, 0, 0, 0)
  paletteEnc.modeOut.addPalette(0, 0, 0, 255)
  paletteEnc.modeOut.addPalette(255, 0, 255, 255)
  paletteEnc.autoConvert = false
  discard savePNG32(palettePngFilePath, paletteBitmap, sheetWidth, sheetData.len(), paletteEnc)
  echo "make: ", palettePngFilePath

  # 写入 palette .dat 字母表
  let paletteDatFilePath = joinPath(outputsPaletteDir, outputsName & ".png.dat")
  writeFile(paletteDatFilePath, alphabet)
  echo "make: ", paletteDatFilePath

  # 创建 rgba 输出文件夹
  let outputsRgbaDir = joinPath(outputsDir, "rgba")
  createDir(outputsRgbaDir)

  # 写入 rgba .png 图集
  let rgbaPngFilePath = joinPath(outputsRgbaDir, outputsName & ".png")
  var rgbaBitmap: seq[uint8]
  for y in 0 ..< sheetData.len():
    for x in 0 ..< sheetWidth:
      let color = sheetData[y][x]
      if color == glyphDataTransparent:
        rgbaBitmap.add(0)
        rgbaBitmap.add(0)
        rgbaBitmap.add(0)
        rgbaBitmap.add(0)
      elif color == glyphDataSolid:
        rgbaBitmap.add(0)
        rgbaBitmap.add(0)
        rgbaBitmap.add(0)
        rgbaBitmap.add(255)
      else:
        rgbaBitmap.add(255)
        rgbaBitmap.add(0)
        rgbaBitmap.add(255)
        rgbaBitmap.add(255)
  var rgbaEnc = makePNGEncoder()
  rgbaEnc.modeOut.colorType = LCT_RGBA
  rgbaEnc.modeOut.bitDepth = 8
  rgbaEnc.autoConvert = false
  discard savePNG32(rgbaPngFilePath, rgbaBitmap, sheetWidth, sheetData.len(), rgbaEnc)
  echo "make: ", rgbaPngFilePath

  # 写入 rgba .dat 字母表
  let rgbaDatFilePath = joinPath(outputsRgbaDir, outputsName & ".png.dat")
  writeFile(rgbaDatFilePath, alphabet)
  echo "make: ", rgbaDatFilePath
