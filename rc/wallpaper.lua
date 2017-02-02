-- Change wallpaper

local gears = require("gears")

local wtimer = gears.timer { timeout = 0 }

config.wallpaper = {}
config.wallpaper.directory = awful.util.getdir("config") .. "/wallpapers"
config.wallpaper.current = awful.util.getdir("cache") .. "/current-wallpaper.png"

-- We use fvwm-root because default backend for awsetbg does not seem
-- to accept to set multiscreen wallpapers.
local change = function()
   awful.spawn.with_shell(
      awful.util.getdir("config") .. "/bin/build-wallpaper " ..
	 "--crop --directory " .. config.wallpaper.directory ..
     " --target " .. config.wallpaper.current ..
     " && display -window root " .. config.wallpaper.current)
end

wtimer:connect_signal("timeout", function()
		     change()
		     wtimer:stop()
		     wtimer.timeout = math.random(3000, 3600)
		     wtimer:start()
			     end)
wtimer:start()
