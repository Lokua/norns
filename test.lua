-- many tomorrows
-- norns study 1

engine.name = "TestSine"

function init()
  engine.hz(100)
end

function redraw()
  screen.clear()
  screen.text("Hello")
  screen.update()
end