import os
import parseopt
import parseutils
import strutils

let cmdParams = commandLineParams()
if cmdParams.len <= 0:
  echo "nicofont {fontFilePath} {outputsDir} {outputsName}\n"
  echo "options:"
  echo "  -fs, --fontSize"
  echo "      Glyph rasterize size when using OpenType font."
  echo "  -gox, --glyphOffsetX"
  echo "      Glyph offset x."
  echo "  -goy, --glyphOffsetY"
  echo "      Glyph offset y."
  echo "  -gaw, --glyphAdjustWidth"
  echo "      Glyph adjust width."
  echo "  -gah, --glyphAdjustHeight"
  echo "      Glyph adjust width."
  echo "  -m, --mode"
  echo "      Png sheet color type, can be 'palette' or 'rgba', default is 'palette'."
  quit(0)
var params = initOptParser(cmdParams)

var fontFilePath: string = ""
var outputsDir: string = ""
var outputsName: string = ""
var fontSize: uint = 0
var glyphOffsetX, glyphOffsetY, glyphAdjustWidth, glyphAdjustHeight: int = 0
var mode: string = "palette"

var argumentPosition = 0
for kind, key, val in params.getopt():
  case kind:
    of cmdArgument:
      if argumentPosition == 0:
        fontFilePath = key
      elif argumentPosition == 1:
        outputsDir = key
      elif argumentPosition == 2:
        outputsName = key
      argumentPosition += 1
    of cmdLongOption:
      case key.toLowerAscii():
        of "fontSize".toLowerAscii():
          discard parseUInt(val, fontSize)
        of "glyphOffsetX".toLowerAscii():
          glyphOffsetX = parseInt(val)
        of "glyphOffsetY".toLowerAscii():
          glyphOffsetY = parseInt(val)
        of "glyphAdjustWidth".toLowerAscii():
          glyphAdjustWidth = parseInt(val)
        of "glyphAdjustHeight".toLowerAscii():
          glyphAdjustHeight = parseInt(val)
        of "mode":
          mode = val
    of cmdShortOption:
      case key.toLowerAscii():
        of "fs":
          discard parseUInt(val, fontSize)
        of "gox":
          glyphOffsetX = parseInt(val)
        of "goy":
          glyphOffsetY = parseInt(val)
        of "gaw":
          glyphAdjustWidth = parseInt(val)
        of "gah":
          glyphAdjustHeight = parseInt(val)
        of "m":
          mode = val
    of cmdEnd:
      break

echo "fontFilePath: ", fontFilePath
echo "outputsDir: ", outputsDir
echo "outputsName: ", outputsName
echo "fontSize: ", fontSize
echo "glyphOffsetX: ", glyphOffsetX 
echo "glyphOffsetY: ", glyphOffsetY
echo "glyphAdjustWidth: ", glyphAdjustWidth
echo "glyphAdjustHeight: ", glyphAdjustHeight
echo "mode: ", mode
