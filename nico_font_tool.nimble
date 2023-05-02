# Package

version       = "0.0.0"
author        = "TakWolf"
description   = "A tool for converting opentype fonts to NICO Game Framework format fonts."
license       = "MIT"

srcDir        = "src"
installExt    = @["nim"]
bin           = @["nico_font_tool/nicofont"]

# Dependencies

requires "nim >= 1.6.12"
requires "pixie >= 5.0.6"
requires "nimPNG >= 0.3.2"
