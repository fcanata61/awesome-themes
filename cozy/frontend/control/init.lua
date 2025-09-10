
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░    █▀█ ▄▀█ █▄░█ █▀▀ █░░ 
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄    █▀▀ █▀█ █░▀█ ██▄ █▄▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local keynav = require("modules.keynav")

local manager = require("backend.cozy").control
local ctrl_ui

local profile = require(... .. ".profile")
local fetch  = require(... .. ".fetch")
local stats  = require(... .. ".stats")
local actions, nav_actions = require(... .. ".actions")()
local picom, nav_picom = require(... .. ".picom")()
local poweropts, poweropts_confirm, nav_poweropts = require(... .. ".poweropts")()

local navigator, _ = keynav.navigator({
  items = {
    nav_picom,
    nav_actions,
    nav_poweropts,
  }
})

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

local body = wibox.widget({
  {
    {
      {
        profile,
        fetch,
        spacing = dpi(15),
        layout = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    },
    stats,
    picom,
    actions,
    spacing = dpi(30),
    layout = wibox.layout.fixed.vertical,
  },
  margins = dpi(25),
  widget = wibox.container.margin,
})

local bottom_tab = wibox.widget({
  {
    {
      ui.hpad(dpi(15)),
      {
        require(... .. ".uptime"),
        valign = "bottom",
        widget = wibox.container.place,
      },
      layout = wibox.layout.fixed.horizontal,
    },
    nil,
    {
      poweropts,
      bg = beautiful.neutral[700],
      widget = wibox.container.background,
    },
    forced_height = dpi(50),
    layout = wibox.layout.align.horizontal,
  },
  bg = beautiful.neutral[900],
  widget = wibox.container.background,
})

ctrl_ui = awful.popup ({
  minimum_width = dpi(420),
  maximum_width = dpi(420),
  placement     = awful.placement.centered,
  type    = "splash",
  bg      = beautiful.transparent,
  shape   = ui.rrect(),
  ontop   = true,
  widget  = {
    {
      {
        body,
        margins = {
          top = dpi(10),
          bottom = dpi(10),
        },
        widget = wibox.container.margin,
      },
      bottom_tab,
      poweropts_confirm,
      layout = wibox.layout.fixed.vertical,
    },
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  },
  visible = false,
})

manager.popup = ctrl_ui

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

manager:connect_signal("setstate::open", function()
  ctrl_ui.screen = awful.screen.focused()
  ctrl_ui.visible = true
  navigator:start()
end)

manager:connect_signal("setstate::close", function()
  navigator:stop()
  ctrl_ui.visible = false
  collectgarbage("collect")
end)

return function() return ctrl_ui end
