-- -- uno
-- -- baby steps

engine.name = "PolyPerc"

local midi_in_device

local function mtof(m)
  return (2 ^ ((m - 69) / 12)) * 440
end

local function midi_event(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    clock.run(
      function()
        -- ensure CC parameter reads happen before a note is fired
        clock.sleep(0.003)
        engine.amp(d.vel / 127)
        engine.hz(mtof(d.note))
      end
    )
  end
end

function init()
  midi_in_device = midi.connect(1)
  midi_in_device.event = midi_event

  params:add_separator("uno: setup")

  params:add({
    type = "number", 
    id = "midi_device", 
    name = "MIDI Device", 
    min = 1, 
    max = 4, 
    default = 1, 
    action = function(value)
      midi_in_device.event = nil
      midi_in_device = midi.connect(value)
      midi_in_device.event = midi_event
    end
  })

  local channels = {"All"}
  for i = 1, 16 do 
    table.insert(channels, i) 
  end
  params:add({
    type = "option", 
    id = "midi_channel", 
    name = "MIDI Channel", 
    options = channels
  })

  params:add_separator("uno: synth params")

  params:add_control("release", "Release", controlspec.new(0.1, 10, "lin", 0, 0.4, "s"))
  params:set_action(
    "release", 
    function(x)
      engine.release(x)
      redraw()
    end
  )
  
  params:add_control("cutoff", "Filter Cutoff", controlspec.new(100, 12500, "exp", 0, 1000, "hz"))
  params:set_action(
    "cutoff", 
    function(x)
      engine.cutoff(x)
      redraw()
    end
  )
  
  params:add_control("res", "Filter Resonance", controlspec.new(0, 5, "lin", 0, 2.5, "db"))
  params:set_action(
    "res", 
    function(x)
      engine.gain(x)
      redraw()
    end
  )

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


