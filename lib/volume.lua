-- Handle volume (through pulseaudio)

local volume = {}

local io           = require("io")
local awful        = require("awful")
local naughty      = require("naughty")
local tonumber     = tonumber
local string       = string
local os           = os

-- A bit odd, but...
local icons = require("lib/icons")

local volid = nil
local function change(what)
   os.execute("amixer -q sset Master " .. what, false)
   -- Read the current value
   local file = io.popen("amixer sget Master", "r")
   local out = file:read("*all")
   local vol, mute = out:match("([%d]+)%%.*%[([%l]*)")
   if not mute or not vol then return end

   vol = tonumber(vol)
   local icon = "high"
   if mute ~= "on" or vol == 0 then
      icon = "muted"
   elseif vol < 30 then
      icon = "low"
   elseif vol < 60 then
      icon = "medium"
   end
   icon = icons.lookup({name = "audio-volume-" .. icon,
		       type = "status"})

   volid = naughty.notify({ text = string.format("%3d %%", vol),
			    icon = icon,
			    font = "Free Sans Bold 24",
			    replaces_id = volid }).id
end

function volume.increase()
   change("5%+")
end

function volume.decrease()
   change("5%-")
end

function volume.toggle()
   change("toggle")
end

-- run pavucontrol
function volume.mixer()
   awful.util.spawn("pavucontrol", false)
end

return volume
