local os = require('os')
local math = require('math')
math.randomseed(os.time())

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
beautiful.gap_single_client   = false
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local volume_bar_widget = require("awesome-wm-widgets.volumebar-widget.volumebar")
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
-- local email_widget = require("awesome-wm-widgets.email-widget.email")
local calendar = require("calendar.calendar")
local music = require("music")

-- Custom imports
local options = require("options")
home = os.getenv('HOME')
local naughty_suspended = false

os.execute('xset m 16/1 0')
os.setlocale("fr_FR.UTF-8")

-- Run xsession if exists
function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

if file_exists(home..'/.config/awesome/autostart.sh') then
    os.execute(home .. '/.config/awesome/autostart.sh &')
end

if file_exists(home..'/.xsession') then
    os.execute(home .. '/.xsession &')
end


naughty.config.notify_callback = function(args)
    -- Set maximum size for notifactions
    if args.icon_size == nil or args.icon_size > 128 then
        args.icon_size = 128
    end
    return args
end
-- awful.util.spawn_with_shell("xcompmgr -cF &")

naughty.config.presets.normal.bg = "#000000"
-- naughty.config.presets.normal.width = 300
-- naughty.config.presets.normal.height = 100
naughty.config.presets.normal.font = "Ubuntu 12pt"
naughty.config.presets.normal.opacity = 0.7

naughty.config.presets.low.opacity = 0.7
naughty.config.presets.critical.opacity = 0.7
naughty.config.presets.critical.font = "Ubuntu 12pt"
naughty.config.presets.critical.timeout = 5
naughty.config.presets.critical.bg = "#111111"
naughty.config.presets.critical.fg = "#aaaaaa"

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = options.terminal
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.corner.ne,
    awful.layout.suit.corner.sw,
    awful.layout.suit.corner.se,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

-- local background = require('background_widget')
local delimiter = wibox.widget.textbox(" | ")
local delimiter2 = wibox.widget.textbox(" ")

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    -- s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    local wibar_height = 15
    if s == screen.primary then
        local wibar_width = 512
        local wibar_height = 15
        s.mywibox = wibox({
            x = s.geometry.x + s.geometry.width - wibar_width,
            y = s.geometry.y + s.geometry.height - wibar_height,
            width = wibar_width,
            height = wibar_height,
            expand = true,
            visible = true,
            ontop = true,
            screen = s
        })

        s.textclock = awful.widget.textclock(" %a %d %b  %H:%M ")
        calendar({position = "bottom_right"}):attach(s.textclock)

        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                -- mylauncher,
                s.mytaglist,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                -- delimiter,
                -- email_widget.icon,
                -- delimiter2,
                -- email_widget.widget,
                -- delimiter,
                ram_widget,
                -- delimiter2,
                cpu_widget,
                -- delimiter,
                volume_widget,
                -- delimiter2,
                -- volume_bar_widget,
                -- delimiter,
                battery_widget,
                -- delimiter,
                -- mykeyboardlayout,
                wibox.widget.systray(),
                s.textclock,
                s.mylayoutbox,
            },
        }
    else
        -- Light wibox for secondary screen
        local wibar_width = 200
        s.mywibox = wibox({
            x = s.geometry.x + s.geometry.width - wibar_width,
            y = s.geometry.y + s.geometry.height - wibar_height,
            width = wibar_width,
            height = wibar_height,
            expand = true,
            visible = true,
            ontop = true,
            screen = s
        })
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                -- mylauncher,
                s.mytaglist,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                s.mylayoutbox,
            },
        }
    end

    -- Auto hide wibar
    -- s.detect = gears.timer {
    --     timeout = 0.35,
    --     callback = function ()
    --         if (mouse.screen ~= s) or
    --             (mouse.coords().y < s.geometry.y + s.geometry.height - wibar_height)
    --         then
    --             s.mywibox.visible = false
    --             s.detect:stop()
    --         end
    --     end
    -- }
    --
    -- s.enable_wibar = function ()
    --     s.mywibox.visible = true
    --     if not s.detect.started then
    --         s.detect:start()
    --     end
    -- end
    --
    -- s.activation_zone = wibox ({
    --     x = s.geometry.x, y = s.geometry.y + s.geometry.height - 1,
    --     opacity = 0.0, width = s.geometry.width, height = 1,
    --     screen = s, input_passthrough = false, visible = true,
    --     ontop = true, type = "dock",
    -- })
    --
    -- s.activation_zone:connect_signal("mouse::enter", function ()
    --     s.enable_wibar()
    -- end)

    -- update_background_widget(s)

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            -- awful.client.focus.history.previous()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    -- Standard program
    awful.key({ modkey,           }, "Return", function ()
        awful.util.spawn_with_shell(terminal)
        naughty.notify({title = "Starting " .. options.terminal})
    end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
    --           {description = "increase master width factor", group = "layout"}),
    -- awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
    --           {description = "decrease master width factor", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    --           {description = "increase the number of master clients", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    --           {description = "decrease the number of master clients", group = "layout"}),
    -- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    --           {description = "increase the number of columns", group = "layout"}),
    -- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    --           {description = "decrease the number of columns", group = "layout"}),
    -- awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
    --           {description = "select next", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --           {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),

    awful.key({ modkey },            "r",     function () awful.spawn('rofi -show drun -theme ~/.config/rofi/theme.rasi') end,
              {description = "run prompt", group = "launcher"}),
    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run {
    --                 prompt       = "Run Lua code: ",
    --                 textbox      = awful.screen.focused().mypromptbox.widget,
    --                 exe_callback = awful.util.eval,
    --                 history_path = awful.util.get_cache_dir() .. "/history_eval"
    --               }
    --           end,
    --           {description = "lua execute prompt", group = "awesome"}),

    -- Custom shortcuts
    awful.key({ }, "XF86AudioRaiseVolume", function()
        awful.util.spawn("pactl set-sink-volume 0 +3%", false)
    end, {description = "increase the volume by 3%", group="Fn Keys"}),

    awful.key({ }, "XF86AudioLowerVolume", function()
        awful.util.spawn("pactl set-sink-volume 0 -3%", false)
    end, {description = "decrease the volume by 3%", group="Fn Keys"}),

    awful.key({modkey}, "Up", function()
        awful.util.spawn("pactl set-sink-volume 0 +3%", false)
    end, {description = "increase the volume by 3%", group="Sound controls"}),

    awful.key({modkey}, "Down", function()
        awful.util.spawn("pactl set-sink-volume 0 -3%", false)
    end, {description = "decrease the volume by 3%", group="Sound controls"}),

    awful.key({ }, "XF86AudioMute", function()
            awful.util.spawn("pactl set-sink-mute 0 toggle", false)
        end, {description = "mute sound", group="Fn Keys"}),

    awful.key({ }, "XF86MonBrightnessDown", function ()
            awful.util.spawn("xbacklight -dec 2")
        end, {description = "decrease brightness", group="Fn Keys"}),

    awful.key({ }, "XF86MonBrightnessUp", function ()
            awful.util.spawn("xbacklight -inc 2")
        end, {description = "increase brightness", group="Fn Keys"}),

    awful.key({ }, "XF86AudioPlay", function ()
            awful.util.spawn("playerctl -a play-pause")
        end, {description = "pause or resume music", group="Media Keys"}),

    awful.key({ }, "XF86AudioStop", function ()
            awful.util.spawn("playerctl -a stop")
        end, {description = "stop music", group="Media Keys"}),

    awful.key({ }, "XF86AudioNext", function ()
            awful.util.spawn("playerctl -a next")
        end, {description = "next music", group="Media Keys"}),

    awful.key({modkey}, "#82", function ()
            awful.util.spawn("xbacklight -dec 2")
        end, {description = "decrease brightness", group="Brightness controls"}),

    awful.key({modkey}, "#86", function ()
            awful.util.spawn("xbacklight -inc 2")
        end, {description = "increase brightness", group="Brightness controls"}),

    awful.key({ }, "XF86PowerOff", function ()
            awful.util.spawn(home .. "/.config/dotfiles/bin-extra/shutdown now")
        end, {description = "Shutdown", group="Fn Keys"}),

    awful.key({ }, "XF86AudioPlay", function()
        music.execute_command('play')
        end, {description = "play or pause the current music", group="Fn Keys"}),

    awful.key({ }, "XF86AudioStop", function()
        music.execute_command('stop')
        end, {description = "stop the current music", group="Fn Keys"}),

    awful.key({ }, "XF86AudioNext", function()
        music.execute_command('next')
        end, {description = "skip to the next music", group="Fn Keys"}),

    awful.key({ }, "XF86AudioPrev", function()
        music.execute_command('previous')
        end, {description = "skip to the previous music", group="Fn Keys"}),

    awful.key({ }, "Print", function ()
            awful.spawn.easy_async('flameshot gui', function() end)
        end, {description = "capture the screen", group="Fn Keys"}),

    awful.key({"Shift"}, "Print", function ()
            awful.spawn.easy_async('flameshot gui -d 1000', function() end)
        end, {description = "capture the screen", group="Fn Keys"}),

    awful.key({modkey}, "a", function ()
            awful.spawn.easy_async(options.browser, function() end)
            naughty.notify({title = "Starting " .. options.browser})
        end, {description="start the web browser", group="shortcuts"}),

    awful.key({modkey}, "z", function()
        awful.spawn.easy_async(options.browser .. " http://jdb.localhost/todo.html https://web.telegram.org https://web.whatsapp.com/ https://discord.com/app https://nuage.polymny.studio/index.php/apps/calendar/ https://mail.infomaniak.com/2 https://mail.infomaniak.com/0", function() end)
        naughty.notify({title = "Starting social media"})
    end, {description="Open social media", group="shortcuts"}),

    awful.key({modkey}, "l", function()
        awful.spawn.easy_async_with_shell('sleep 1; xset dpms force off; slock', function() end)
    end, { description="Locks the screen", group="screen control"}),

    awful.key({modkey, "Shift"}, "l", function()
        awful.spawn.easy_async_with_shell('sleep 1; xset dpms force off', function() end)
    end, { description="Turns off the screen", group="screen control"}),

    awful.key({modkey, "Shift"}, "Tab", function()
            awful.spawn.easy_async('xdotool key Caps_Lock', function() end)
        end, {description="switch the caps lock", group="screen control"}),

    awful.key({modkey}, "#88", function()
        awful.spawn.easy_async("x b", function() end)
    end, {description="Sets the two screens view", group="screen control"}),

    awful.key({modkey}, "#87", function()
        awful.spawn.easy_async("x d", function() end)
    end, {description="Default view", group="screen control"}),

    awful.key({modkey, "Shift"}, "#87", function()
        awful.spawn.easy_async("x s", function() end)
    end, {description="Inverse of the default view", group="screen control"}),

    awful.key({modkey}, "d", function()
        if naughty_suspended then
            naughty.resume()
            naughty_suspended = false
        else
            naughty.suspend()
            naughty_suspended = true
        end
    end, {description="Suspend / Resume notifications", group="shortcuts"}),

    awful.key({modkey, "Shift"}, "m", function()
        awful.spawn.easy_async('sleep 0.5', function()
            os.execute('xdotool type --clearmodifiers ' .. options.email)
        end)
    end, {description="Automatically enters the key to type your email", group="shortcuts"}),

    awful.key({modkey, "Shift"}, "ù", function()
        awful.spawn.easy_async('sleep 0.5', function()
            os.execute('xdotool type --clearmodifiers ' .. options.email2)
        end)
    end, {description="Automatically enters the key to type your secondary email", group="shortcuts"}),

    awful.key({modkey}, "q", function()
        awful.spawn.easy_async("mailspring --password-store=gnome-libsecret", function() end)
    end, {description="Opens mailspring", group="shortcuts"}),

    awful.key({modkey}, "e", function()
        awful.spawn.easy_async("firefox ext+container:name=Yuzzit&url=https://yip.atlassian.net/ ext+container:name=Yuzzit&url=https://app.slack.com/client/T03UFFGJK/D07KS0S1LDT ext+container:name=Yuzzit&url=https://app.gather.town/app/bZRkf3gh7MIximOa/ytopenspace", function() end)
    end, {description="Starts yuzzit", group="shortcuts"}),

    awful.key({modkey}, ",", function()
        awful.spawn.easy_async("firefox ext+container:name=Yuzzit&url=https://duckduckgo.com", function() end)
    end, {description="Starts yuzzit empty window", group="shortcuts"}),

    awful.key({ modkey }, "p", function()
        awful.spawn.easy_async("pavucontrol", function(e) end)
    end, {description = "starts pavucontrol", group = "shortcuts"}),

    awful.key({ modkey }, "b", function()
        awful.spawn.easy_async("blueberry", function(e) end)
    end, {description = "starts blueberry", group = "shortcuts"}),

    awful.key({ modkey }, "c", function()
        awful.spawn.easy_async("alacritty -e numbat", function(e) end)
    end, {description = "starts numbat", group = "shortcuts"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                              tag:view_only()
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width -- your border width
        end
    end
end)

-- Make wibar not on top when fullscreen clients
function toggle_wibar_ontop(c)
    if c.fullscreen then
        c.screen.mywibox.ontop = false
    else
        c.screen.mywibox.ontop = true
    end
end

client.connect_signal("manage", toggle_wibar_ontop)
client.connect_signal("focus", toggle_wibar_ontop)
client.connect_signal("property::floating", toggle_wibar_ontop)
client.connect_signal("property::fullscreen", toggle_wibar_ontop)

-- awful.screen.set_auto_dpi_enabled(true)

-- load the widget code

-- attach it as popup to your text clock widget:

-- }}}
