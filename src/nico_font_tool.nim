import os
import algorithm
import strutils
import sugar
import unicode
import streams
import pixie
import pixie/fontformats/opentype
#import pixie/fileformats/png
import nimPNG

const glyphDataTransparent: uint8 = 0
const glyphDataSolid: uint8 = 1
const glyphDataBorder: uint8 = 2

proc createFontSheet*(
    fontSize: uint,
    outputsName, outputsDir: string,
    fontFilePath: string,
    glyphOffsetX, glyphOffsetY, glyphAdjustWidth, glyphAdjustHeight: int = 0,
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
  lineHeight += glyphAdjustHeight

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
    #var height = 0
    if glyphId < openType.hmtx.hMetrics.len():
      advanceWidth = int(math.ceil(float32(openType.hmtx.hMetrics[glyphId].advanceWidth) / pxUnits))
    #height = int(math.ceil(float32(openType.hhea.ascender - openType.hhea.descender) / pxUnits))
    if advanceWidth <= 0:
      continue
    advanceWidth += glyphAdjustWidth
    if advanceWidth <= 0:
      continue

    # 栅格化
    let glyphImage = newImage(advanceWidth, lineHeight)
    glyphImage.fillText(font.typeset($rune), translate(vec2(float32(glyphOffsetX), float32(glyphOffsetY))))
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
  # TODO
  let palImage = newImage(sheetWidth, sheetData.len())
  var paldata: seq[uint8]
  for y in 0 ..< palImage.height:
    for x in 0 ..< palImage.width:
      var pixel: ColorRGBX
      case sheetData[y][x]:
        of glyphDataSolid:
          paldata.add(0)
          paldata.add(0)
          paldata.add(0)
          paldata.add(255)
        of glyphDataBorder:
          paldata.add(255)
          paldata.add(0)
          paldata.add(255)
          paldata.add(255)
        else:
          paldata.add(0)
          paldata.add(0)
          paldata.add(0)
          paldata.add(0)
          discard

  var enc = makePNGEncoder()
  enc.modeOut.colorType = LCT_PALETTE
  enc.modeOut.bitDepth = 8
  enc.forcePalette = true
  enc.autoConvert = false

  # up to 256 entries
  enc.modeOut.addPalette(0, 0, 0, 255)
  enc.modeOut.addPalette(255, 0, 255, 255)
  enc.modeOut.addPalette(0, 0, 0, 0)

  var palpng = encodePNG(paldata, sheetWidth, sheetData.len(),enc)
  var s = newFileStream(palettePngFilePath, fmWrite)
  palpng.writeChunks s
  s.close()
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
  let rgbaImage = newImage(sheetWidth, sheetData.len())
  for y in 0 ..< rgbaImage.height:
    for x in 0 ..< rgbaImage.width:
      var pixel: ColorRGBX
      case sheetData[y][x]:
        of glyphDataSolid:
          pixel.a = 255
        of glyphDataBorder:
          pixel.r = 255
          pixel.b = 255
          pixel.a = 255
        else:
          discard
      rgbaImage.data[rgbaImage.dataIndex(x, y)] = pixel
  rgbaImage.writeFile(rgbaPngFilePath)
  echo "make: ", rgbaPngFilePath

  # 写入 rgba .dat 字母表
  let rgbaDatFilePath = joinPath(outputsRgbaDir, outputsName & ".png.dat")
  writeFile(rgbaDatFilePath, alphabet)
  echo "make: ", rgbaDatFilePath
