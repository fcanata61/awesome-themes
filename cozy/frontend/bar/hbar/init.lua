
-- █░█ █▄▄ ▄▀█ █▀█
-- █▀█ █▄█ █▀█ █▀▄

local awful = require("awful")
local wibox = require("wibox")
local conf  = require("cozyconf")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local beautiful  = require("beautiful")

local logo    = require("frontend.bar.common.logo")
local timew   = require("frontend.bar.common.timewarrior")
local clock   = require("frontend.bar.common.clock")("%H:%M")
local battery = require("frontend.bar.common.battery")
local taglist = require(... .. ".taglist")

local align = (conf.bar_align == "top") and "top" or "bottom"

return function(s)
  local systray = require("frontend.bar.common.systray")(s)

  -- The way this is written is weird but the taglist won't be easily centered otherwise.
  -- Leftside and rightside widgets are inside their own separate align layout.
  -- Taglist is chillin by itself, container.place'd in the middle.
  -- Then they're stacked to ensure taglist is perfectly centered.
  local bar = wibox.widget({
    {
      { -- Left
        logo,
        timew,
        spacing = dpi(15),
        align = "left",
        layout = wibox.layout.fixed.horizontal,
      },
      nil,
      { -- Right
        battery,
        clock,
        conf.show_systray and systray,
        spacing = dpi(15),
        align = "end",
        layout = wibox.layout.fixed.horizontal,
      },
      layout = wibox.layout.align.horizontal,
    },
    {
      taglist(s),
      widget = wibox.container.place,
    },
    forced_width = s.geometry.width - dpi(30),
    layout = wibox.layout.stack,
  })

  s.bar = awful.popup({
    screen = s,
    type = "dock",
    minimum_width = s.geometry.width,
    maximum_width = s.geometry.width,
    minimum_height = dpi(42),
    maximum_height = dpi(42),
    placement = awful.placement[align],
    widget = {
      {
        {
          bar,
          widget = wibox.container.place,
        },
        margins = dpi(3),
        widget  = wibox.container.margin,
      },
      bg      = beautiful.neutral[900],
      widget  = wibox.container.background,
    },
  })

  -- Reserve screen space
  s.bar:struts({
    [align] = s.bar.maximum_height
  })
end
