import nico

proc gameInit() =
  loadFont(0, "fonts/palette/quan.png")
  loadFont(1, "fonts/rgba/quan.png")

proc gameUpdate(dt: float32) =
  discard

proc gameDraw() =
  cls()

  cursor(0, 0)

  setFont(0)
  setColor(7)
  print("Hello World!")

  setFont(1)
  setColor(9)
  print("你好，世界！")

nico.init("nico", "nico-font-tool")
nico.createWindow("Hello World", 128, 128, 3)
nico.run(gameInit, gameUpdate, gameDraw)
