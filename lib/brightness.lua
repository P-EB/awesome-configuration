-- Handle brightness (with xbacklight)

local brightness = {}

local io           = require("io")
local awful        = require("awful")
local naughty      = require("naughty")
local tonumber     = tonumber
local string       = string
local os           = os
local math         = require("math")

-- A bit odd, but...
local icons        = require("lib/icons")

local nid = nil
local function change(what)
   os.execute("xbacklight -" .. what)
   local file = io.popen("xbacklight -get", 'r')
   local out = file:read('*all')
   if not out then return end

   out = math.floor(tonumber(out))
   local icon = icons.lookup({name = "display-brightness",
			      type = "status"})

   nid = naughty.notify({ text = string.format("%3d %%", out),
			  icon = icon,
			  font = "Free Sans Bold 24",
			  replaces_id = nid }).id
end

function brightness.increase()
   change("inc 5")
end

function brightness.decrease()
   change("dec 5")
end

return brightness
