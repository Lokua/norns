-- many tomorrows
-- norns study 1

local util = require("util")

local grid = util.file_exists(_path.code.."midigrid") and include "midigrid/lib/mg_128" or grid
g = grid.connect()
m = midi.connect()

engine.name = "PolyPerc"
cutoff = 63
res = 63 
release = 63

function init()
  params:add_separator("many tomorrows")

  params:add_control("release", "release", controlspec.new(0.1, 10, "lin", 0, 0.4, "s"))
  params:set_action("release", function(x)
    engine.release(x)
    redraw()
  end)
  
  params:add_control("cutoff", "cutoff", controlspec.new(100, 12500, "exp", 0, 1000, "hz"))
  params:set_action("cutoff", function(x)
    engine.cutoff(x)
    redraw()
  end)
  
  params:add_control("res", "res", controlspec.new(0, 5, "lin", 0, 2.5, "db"))
  params:set_action("res", function(x)
    engine.gain(x)
    redraw()
  end)
  
  engine.amp(1)
  enc(1, 0)
  enc(2, 0)
  enc(3, 0)
end

-- for manual dev when without midi controller
function key(n, z)
  if z == 0 then 
    return 
  end
    
  offset = 40
  
  if n == 2 then
    engine.release(params:get("release"))
    engine.hz(mtof(0 + offset))
    engine.hz(mtof(3 + offset))
    engine.hz(mtof(7 + offset))
  elseif n == 3 then
    local x = 7
    engine.release(params:get("release") / 2)
    engine.hz(mtof(0 + offset + x))
    engine.hz(mtof(3 + offset + x))
    engine.hz(mtof(7 + offset + x))
  end
end

function enc(n, d)
  if n == 1 then
    params:delta("release", d)
  elseif n == 2 then
    params:delta("cutoff", d)
  elseif n == 3 then
    params:delta("res", d)
  end
end

function g.key(x, y, z)
  g:led(x, y, z * 4)
  g:refresh()
end

function m.event(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    clock.run(function()
      -- this is to ensure CC parameter locks happen before a note
      clock.sleep(0.003)
      engine.amp(d.vel / 127)
      engine.hz(mtof(d.note))
    end)
  end
end

function redraw()
  screen.clear()
  screen.move(0, 6)
  screen.text("release: " .. params:string("release"))
  screen.move(0, 12)
  screen.text("cutoff: " .. params:string("cutoff"))
  screen.move(0, 12 + 6)
  screen.text("res: " .. params:string("res"))  
  screen.update()
end

function mtof(m)
  return (2 ^ ((m - 69) / 12)) * 440
end


