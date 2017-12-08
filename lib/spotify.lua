-- Drive spotify

-- Spotify uses the MPRIS D-BUS interface. See more information here:
--   http://specifications.freedesktop.org/mpris-spec/latest/

-- To get the complete interface:
--   mdbus2 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2

local spotify_module = {}

local awful = require("awful")
local dbg   = dbg
local pairs = pairs
local os    = os
local capi = {
   client = client
}

-- Get spotify window
local function spotify()
   local clients = capi.client.get()
   for k, c in pairs(clients) do
      if awful.rules.match(c, { instance = "spotify",
                                class = "Spotify" }) then
         return c
      end
   end
   return nil
end

-- Send a command to spotify
local function cmd(command)
   local client = spotify()
   if client then
      os.execute("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify " ..
         "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." .. command)
   end
end

-- Show spotify
function spotify_module.gcshow()
   local client = spotify()
   if client then
      if not client:isvisible() then
         awful.tag.viewonly(client:tags()[1])
      end
      capi.client.focus = client
      client:raise()
   else
      awful.util.spawn("spotify")
   end
end

function spotify_module.gcplaypause()
   cmd("PlayPause")
end

function spotify_module.gcplay()
   cmd("Play")
end

function spotify_module.gcpause()
   cmd("Pause")
end

function spotify_module.gcstop()
   cmd("Stop")
end

function spotify_module.gcnext()
   cmd("Next")
end

function spotify_module.gcprevious()
   cmd("Previous")
end

function spotify_module.gcmixer()
   awful.util.spawn("pavucontrol")
end

return spotify_module
