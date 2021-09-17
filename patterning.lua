-- patterning
-- norns study 2

engine.name = "PolySub"
drumzzz = {1,0,0,0,1,0,1,0}

function init()
  color = 3
  number = 84
end

function redraw()
  screen.clear()
  for i=1,#drumzzz do
    screen.move(i*8, 40)
    screen.line_rel(0,10)
    if drumzzz[i] == 1 then
      screen.level(15)
    else
      screen.level(1)
    end
    screen.stroke()
  end
  screen.update()
end

function key(n,z)
  color = 3 + z * 12
  redraw()
end

function enc(n,d)
  number = number + d
  redraw()
end