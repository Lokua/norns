-- -- uno
-- -- baby steps
engine.name = "PolyPerc"

local midi_in_device
local last_pan = 1
local PAN = 0.62

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
        engine.pan(math.random() * last_pan) 
        engine.hz(mtof(d.note))
        if last_pan == 1 then last_pan = -1 else last_pan = 1 end
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

  params:add_control("release", "Amp Env Release", controlspec.new(0.1, 10, "lin", 0, 0.4, "s"))
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

  local float = function(default_value) 
    controlspec.new(0, 1, "lin", 0, default_value) 
  end

  -- hmmm...this isn't _really_ the delay level
  params:add_control("delay_level", "Delay Level", controlspec.new(0, 1, "lin", 0, 1))
  params:set_action(
    "delay_level",
    function(x)
      softcut.level(1, x)
      softcut.level(2, x)
    end
  )

  params:add_control("delay_feedback", "Delay Feedback", controlspec.new(0, 1, "lin", 0, 0.5))
  params:set_action(
    "delay_feedback",
    function(x)
      softcut.pre_level(1, x)
      softcut.pre_level(2, x)
    end
  )

  params:add_control("delay_rate", "Delay Rate", controlspec.new(-1, 10, "lin", 0, 1.4))
  params:set_action(
    "delay_rate",
    function(x)
      softcut.rate(1, x)
      softcut.rate(2, x)
    end
  )

  -- configure the delay
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  softcut.level(1, params:get("delay_level"))
  softcut.level(2, params:get("delay_level"))
  softcut.level_slew_time(1, 0.25)
  softcut.level_slew_time(2, 0.25)
  softcut.level_input_cut(1, 1, 1)
  softcut.level_input_cut(2, 2, 1)
  softcut.pre_level(1, params:get("delay_feedback"))
  softcut.pre_level(2, params:get("delay_feedback"))
  softcut.pan(1, 0.54)
  softcut.pan(2, -0.54)
  softcut.play(1, 1)
  softcut.play(2, 1)
  softcut.rate(1, params:get("delay_rate"))
  softcut.rate(2, params:get("delay_rate"))
  softcut.rate_slew_time(1, 0)
  softcut.rate_slew_time(2, 0)
  softcut.loop_start(1, 0)
  softcut.loop_start(2, 0)
  softcut.loop_end(1, 0.5)
  softcut.loop_end(2, 0.5)
  softcut.loop(1, 1)
  softcut.loop(2, 1)
  softcut.fade_time(1, 0.1)
  softcut.fade_time(2, 0.1)
  softcut.rec(1, 1)
  softcut.rec(2, 1)
  softcut.rec_level(1, 1)
  softcut.rec_level(2, 1)
  softcut.position(1, 0)
  softcut.position(2, 0)
  softcut.enable(1, 1)
  softcut.enable(2, 1)
  softcut.filter_dry(1, 0)
  softcut.filter_dry(1, 0)
  softcut.filter_lp(1, 1.0)
  softcut.filter_lp(2, 1.0)
  softcut.filter_bp(1, 1.0)
  softcut.filter_bp(2, 1.0)
  softcut.filter_hp(1, 1.0)
  softcut.filter_hp(2, 1.0)
  softcut.filter_fc(1, 300)
  softcut.filter_fc(2, 300)
  softcut.filter_rq(1, 2.0)
  softcut.filter_rq(2, 2.0)

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


