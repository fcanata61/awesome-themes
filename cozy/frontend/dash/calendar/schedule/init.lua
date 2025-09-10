
-- █▀ █▀▀ █░█ █▀▀ █▀▄ █░█ █░░ █▀▀
-- ▄█ █▄▄ █▀█ ██▄ █▄▀ █▄█ █▄▄ ██▄

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

return function()
  return nil, ui.textbox({ text = "Schedule" }), nil
end
