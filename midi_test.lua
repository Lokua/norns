-- local m = midi.connect(1)

-- function m.event(data)
--   tab.print(midi.to_msg(data))
-- end

local m

local function midi_event(data)
  tab.print(midi.to_msg(data))
end

function init()
  m = midi.connect(1)
  m.event = midi_event

  params:add{type = "number", id = "midi_device", name = "MIDI Device", min = 1, max = 4, default = 1, action = function(value)
    m.event = nil
    m = midi.connect(value)
    m.event = midi_event
  end}
end





