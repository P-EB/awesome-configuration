-- Tags

local shifty = loadrc("shifty", "vbe/shifty")
local keydoc = loadrc("keydoc", "vbe/keydoc")

local tagicon = function(icon)
   if screen.count() > 1 then
      return beautiful.icons .. "/taglist/" .. icon .. ".png"
   end
   return nil
end

local filtertable = function (tab, value)
   local k = 1
   while tab[k] do
       if tab[k] == value then
           table.remove(tab, k)
       else
           k = k + 1
       end
   end
end

shifty.config.tags = {
--    www = {
--       position = 2,
--       mwfact = 0.7,
--       exclusive = true,
--       max_clients = 1,
--       screen = math.max(screen.count(), 2),
--       spawn = config.browser,
--       icon = tagicon("web")
--    },
--    gvim = {
--       position = 5,
--       mwfact = 0.6,
--       exclusive = true,
--       screen = 1,
--       spawn = "gvim",
--       icon = tagicon("dev"),
--    }
--    gterm = {
--       position = 1,
--       layout = awful.layout.suit.fair,
--       exclusive = true,
--       slave = true,
--       spawn = config.terminal,
--       icon = tagicon("main"),
--    }
--    im = {
--       position = 4,
--       mwfact = 0.2,
--       exclusive = true,
--       screen = math.max(screen.count(), 2),
--       icon = tagicon("im"),
--       nopopup = true,           -- don't give focus on creation
--    }
}

-- Also, see rules.lua
shifty.config.apps = {
--    {
--       match = { role = { "browser" } },
--       tag = "www",
--    },
--    {
--       match = { "gvim" },
--       tag = "gvim",
--    },
--    {
--       match = { class = { "Keepassx", "Key[-]mon" },
--                 role = { "pop[-]up" },
--                 name = { "Firebug" },
--                 check = function (c)
--                    return awful.rules.match(c,
--                                             { instance = "chromium",
--                                               class = "Chromium",
--                                               name = "Chromium",
--                                               fullscreen = true })
--                 end,
--                 instance = { "plugin[-]container", "exe" } },
--       intrusive = true,
--    },
}

shifty.config.defaults = {
   layout = config.layouts[1],
   mwfact = 0.6,
   ncol = 1,
   sweep_delay = 1,
}

shifty.taglist = config.taglist -- Set in widget.lua
shifty.init()

local tag_del_or_rename = function(tag)
   if not shifty.del(tag) then
      shifty.rename(tag)
   end
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   keydoc.group("Tag management"),
   awful.key({ modkey }, "Left", awful.tag.viewprev),
   awful.key({ modkey }, "Right", awful.tag.viewnext),
   awful.key({ modkey, "Shift"}, "o",
             function()
                if screen.count() == 1 then return nil end
                local s = mouse.screen
                local t = s.selected_tag
                local si = screen[awful.util.cycle(screen.count(), s.index + 1)]
                awful.tag.history.restore()
                t = shifty.tagtoscr(si, t)
                t:view_only()
                mouse.screen = si
             end,
             "Send tag to next screen"),
   awful.key({ modkey, "Control", "Shift"}, "o",
             function()
                if screen.count() == 1 then return nil end
                local s = mouse.screen
                local t = s.selected_tag
                local si = screen[awful.util.cycle(screen.count(), s.index + 1)]
                for _, t in pairs(screen[s.index].tags) do
                   shifty.tagtoscr(si, t)
                end
                mouse.screen = si
             end,
             "Send all tags to next screen"),
   awful.key({ modkey }, "#19", shifty.add, "Create a new tag"),
   awful.key({ modkey, "Shift" }, "#19", shifty.del, "Delete tag"),
   awful.key({ modkey, "Control" }, "#19", shifty.rename, "Rename tag"))

local tag_history = {}
-- historytagmove - Historizes tags moves and allows to go back
function historytagmove(i)
   if tag_history == nil then
      tag_history = {}
   end

   local histsize = #tag_history
   local ni = i

   if histsize > 1 and tag_history[histsize] == ni then
      local found = false
      while not found and histsize > 1 do
         ni = tag_history[histsize - 1]
         table.remove(tag_history)

         if not shifty.findpos(ni) then
            filtertable(tag_history, ni)
            histsize = #tag_history
         else
            found = true
         end
      end
   elseif (histsize >= 1 and tag_history[histsize] ~= ni) or histsize == 0 then
      table.insert(tag_history, ni)
   end

   local t = shifty.getpos(ni)
   local s = t.screen
   local c = awful.client.focus.history.get(s, 0)
   t:view_only()
   mouse.screen = s
   if c then client.focus = c end
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, (shifty.config.maxtags or 9) do
   config.keys.global = awful.util.table.join(
      config.keys.global,
      keydoc.group("Tag management"),
      awful.key({ modkey }, "#" .. i + 9,
                function ()
                    historytagmove(i)
                end,
                i == 5 and "Display only this tag" or nil),
      awful.key({ modkey, "Control" }, "#" .. i + 9,
                function ()
                   local t = shifty.getpos(i)
                   t.selected = not t.selected
                end,
                i == 5 and "Toggle display of this tag" or nil),
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function ()
                   local c = client.focus
                   if c then
                      local t = shifty.getpos(i, {nospawn = true })
                      c:move_to_tag(t)
                   end
                end,
                i == 5 and "Move window to this tag" or nil),
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                function ()
                   if client.focus then
                      awful.client.toggletag(shifty.getpos(i, {nospawn = true}))
                   end
                end,
                i == 5 and "Toggle this tag on this window" or nil),
      keydoc.group("Misc"))
end
