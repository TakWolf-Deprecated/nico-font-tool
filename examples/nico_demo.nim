import nico

proc gameInit() =
  loadFont(0, "fonts/palette/quan.png")
  loadFont(1, "fonts/rgba/quan.png")

proc gameUpdate(dt: float32) =
  discard

proc gameDraw() =
  cls()

  setColor(7)
  setFont(0)
  print("Hello World!", 0, 0)
  
  setColor(9)
  setFont(1)
  print("你好，世界！", 0, 16)

nico.init("nico", "nico-font-tool")
nico.createWindow("Hello World", 128, 128, 3)
nico.run(gameInit, gameUpdate, gameDraw)
