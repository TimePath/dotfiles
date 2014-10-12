-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
awful.util.spawn("dunst")
dbus = nil
local naughty = require("naughty")
local menubar = require("menubar")

-- {{{ Error handling
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end -- Make sure we don't go into an endless error loop
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = err
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Startup
-- Check if awesome was restarted or started for the first time
if awful.util.pread("cat .awesomepid") == awful.util.pread("pgrep -u $USER -x awesome | tee .awesomepid") then
    -- Restarting
    naughty.notify({
        preset = naughty.config.presets.normal,
        title = "Reloading...",
    })
    menubar.refresh() -- Refresh menubar's cache by reloading .desktop files
else -- First start
    awful.util.spawn("dex -a -e Awesome")
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"
altkey = "Mod1"

local mouse1 = 1
local mouse2 = 3
local mouse3 = 2
local mouseup = 4
local mousedown = 5
local mouse4 = 8
local mouse5 = 9

local titlebars_enabled = true
local resize_mode = false

local layouts = {
    --    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    --    awful.layout.suit.fair,
    --    awful.layout.suit.fair.horizontal,
    --    awful.layout.suit.spiral,
    --    awful.layout.suit.spiral.dwindle,
    --    awful.layout.suit.max,
    --    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Notifications
naughty.config.notify_callback = function(args)
    awful.util.spawn_with_shell("~/Scripts/notified awesome '" .. (args.title or "") .. "' '" .. args.text .. "'")
    return args
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

local mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})

local mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
menubar.app_folders = { "/usr/share/applications/", "/home/andrew/.gnome/apps/" }
menubar.show_categories = false -- Change to false if you want only programs to appear in the menu
-- }}}

-- {{{ Wibox
local mywibox = {}
local mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
local mytasklist = {}

mytaglist.buttons = awful.util.table.join(-- Taglist
    awful.button({}, mouse1, awful.tag.viewonly),
    awful.button({}, mouse4, awful.client.movetotag),
    awful.button({}, mouse2, awful.tag.viewtoggle),
    awful.button({}, mouse5, awful.client.toggletag),
    awful.button({}, mousedown, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({}, mouseup, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
--[[]])

mytasklist.buttons = awful.util.table.join(-- Tasklist
    awful.button({}, mouse1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({}, mouse2, function()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({
                theme = { width = 250 }
            })
        end
    end),
    awful.button({}, mousedown, function()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({}, mouseup, function()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end)
--[[]])

mytextclock = awful.widget.textclock(" %a %b %d, %I:%M:%S %p ", 1)

modeindicator = wibox.widget.textbox()

for s = 1, screen.count() do
    local layout = wibox.layout.align.horizontal()

    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(modeindicator)
    left_layout:add(awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons))
    mypromptbox[s] = awful.widget.prompt()
    left_layout:add(mypromptbox[s])
    layout:set_left(left_layout)

    layout:set_middle(awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons))

    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(-- Layout
        awful.button({}, mouse1, function() awful.layout.inc(layouts, 1) end),
        awful.button({}, mouse2, function() awful.layout.inc(layouts, -1) end),
        awful.button({}, mousedown, function() awful.layout.inc(layouts, 1) end),
        awful.button({}, mouseup, function() awful.layout.inc(layouts, -1) end)
    --[[]]))
    right_layout:add(mylayoutbox[s])
    layout:set_right(right_layout)

    mywibox[s] = awful.wibox({ position = "top", height = 20, screen = s })
    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Key bindings
local clientkeys = awful.util.table.join(-- Client keys
    awful.key({ modkey, "Shift" }, "space", awful.client.floating.toggle),
    awful.key({ modkey }, "f", function(c)
        local toggled = not c.maximized_horizontal
        awful.titlebar(c, toggled and { size = 0 } or nil)
        c.border_width = toggled and 0 or beautiful.border_width
        c.maximized_horizontal = toggled
        c.maximized_vertical = toggled
    end),
    awful.key({ modkey, "Shift" }, "f", function(c)
        local toggled = not c.fullscreen
        awful.titlebar(c, toggled and { size = 0 } or nil)
        c.fullscreen = toggled
    end),

    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end),
    awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end)
--    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
--    awful.key({ modkey }, "n", function(c) c.minimized = true end),
--[[]])

local globalkeys = awful.util.table.join(-- Root keys
    awful.key({ modkey, "Control" }, "Left", awful.tag.viewprev),
    awful.key({ modkey, "Control" }, "Right", awful.tag.viewnext),

    awful.key({ modkey }, "Escape", function() mymainmenu:show() end),

    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),

    -- Menu
    awful.key({ modkey }, "d", function() menubar.show() end),
    -- Prompt
    --    awful.key({ modkey }, "x", function() mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x", function()
        awful.prompt.run({ prompt = "Web search: " }, mypromptbox[mouse.screen].widget,
            function(command)
                awful.util.spawn("chromium 'http://yubnub.org/parser/parse?command=" .. command .. "'", true)
                if tags[mouse.screen][2] then awful.tag.viewonly(tags[mouse.screen][2]) end
            end)
    end),
    -- Terminal
    awful.key({ modkey }, "Return", function() awful.util.spawn(terminal) end),
    -- Screenshot
    awful.key({}, "Print", function() awful.util.spawn_with_shell("~/Scripts/screenshot root") end),
    awful.key({ altkey }, "Print", function() awful.util.spawn_with_shell("bash ~/Scripts/screenshot focus") end),
    -- Reload
    awful.key({ modkey, "Shift" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "e", awesome.quit),
    -- Resize mode
    awful.key({ modkey }, "r", function()
        resize_mode = not resize_mode
        -- Pango: http://www.pygtk.org/pygtk2reference/pango-markup-language.html
        modeindicator:set_markup(resize_mode and '<span weight="bold" foreground="' .. beautiful.bg_urgent .. '" background="' .. beautiful.fg_urgent .. '" face="Monospace"> RESIZE </span>' or '')
    end), -- TODO: label

    -- Window swapping
    awful.key({ modkey, "Shift" }, "Left", function() awful.client.swap.bydirection("left") end),
    awful.key({ modkey, "Shift" }, "Right", function() awful.client.swap.bydirection("right") end),
    awful.key({ modkey, "Shift" }, "Up", function() awful.client.swap.bydirection("up") end),
    awful.key({ modkey, "Shift" }, "Down", function() awful.client.swap.bydirection("down") end),
    -- Window switching
    awful.key({ modkey }, "Left", function()
        if resize_mode then
            awful.tag.incmwfact(-0.05)
        else
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end
    end),
    awful.key({ modkey }, "Right", function()
        if resize_mode then
            awful.tag.incmwfact(0.05)
        else
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end
    end),
    awful.key({ modkey }, "Up", function()
        if resize_mode then
            awful.tag.incmwfact(-0.05)
        else
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end
    end),
    awful.key({ modkey }, "Down", function()
        if resize_mode then
            awful.tag.incmwfact(0.05)
        else
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end
    end),
    -- Mode switching
    awful.key({ modkey }, "space", function()
        awful.layout.inc(layouts, 1)
    end),
    awful.key({ modkey, "Control" }, "space", function()
        awful.layout.inc(layouts, -1)
    end)
--[[]])

-- Bind all key numbers to tags using key code
local offset = 9
for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + offset, function()
            local tag = awful.tag.gettags(mouse.screen)[i]
            if tag then awful.tag.viewonly(tag) end
        end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + offset, function()
            local tag = awful.tag.gettags(mouse.screen)[i]
            if tag then awful.tag.viewtoggle(tag) end
        end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + offset, function()
            if not client.focus then return end
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if tag then awful.client.movetotag(tag) end
        end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + offset, function()
            if not client.focus then return end
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if tag then awful.client.toggletag(tag) end
        end)
    --[[]])
end

root.keys(globalkeys)
-- }}}

-- {{{ Mouse bindings
local clientbuttons = awful.util.table.join(-- Client mouse
    awful.button({}, mouse1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, mouse4, awful.client.floating.toggle),
    awful.button({ modkey }, mouse1, awful.mouse.client.move),
    awful.button({ modkey }, mouse2, awful.mouse.client.resize)
--[[]])

local globalbuttons = (awful.util.table.join(-- Root mouse
    awful.button({}, mouse2, function() mymainmenu:toggle() end), -- Order important
    awful.button({}, nil, function() mymainmenu:hide() end),
    awful.button({}, mouseup, awful.tag.viewprev),
    awful.button({}, mousedown, awful.tag.viewnext))
--[[]])

root.buttons(globalbuttons)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons
        }
    },
    -- Float XTerm
    {
        rule = { class = "XTerm" },
        properties = { floating = true }
    },
    -- Map Chromium to screen 1, tag 2
    {
        rule = { class = "Chromium" },
        properties = { tag = tags[1][2] }
    },
    -- Map Steam to screen 1, tag 10
    {
        rule = { class = "Steam" },
        properties = { tag = tags[1][10] }
    },
}
-- }}}

-- {{{ Signals
client.connect_signal("focus", function(c) c.opacity = 1 end)
client.connect_signal("unfocus", function(c) c.opacity = 0.7 end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Simulate floating layer like i3
function update_top_float(c) c.ontop = awful.client.floating.get(c) end
client.connect_signal("property::floating", update_top_float)

client.connect_signal("manage", function(c, startup) -- Signal function to execute when a new client appears.
    c:connect_signal("mouse::click", function(c) -- Enable sloppy focus with ::enter else ::click
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c)
        then client.focus = c
        end
    end)
    update_top_float(c)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        local buttons = awful.util.table.join(-- Mouse buttons for the titlebar
            awful.button({}, mouse1, function()
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
            end),
            awful.button({}, mouse2, function()
                client.focus = c
                c:raise()
                awful.mouse.client.resize(c)
            end)
        --[[]])

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)
        awful.titlebar(c):set_widget(layout)
    end
end)
-- }}}
