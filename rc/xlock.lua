-- Lockscreen

local lock = function()
   os.execute("xset s activate")
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86ScreenSaver", lock),
   awful.key({ modkey, }, "Delete", lock))

-- Configure DPMS
os.execute("xset dpms 720 1200 1440")
