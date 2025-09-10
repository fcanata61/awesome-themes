
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local task  = require("backend.system.task")

local title = ui.textbox({
  text = "Project",
  font = beautiful.font_reg_l,
})

local tag = ui.textbox({
  text  = "Tag",
  color = beautiful.neutral[400],
})

local remaining = ui.textbox({
  text  = "0/0 remaining",
  color = beautiful.neutral[400],
})

-- local wait_status = ui.textbox({
--   text  = " (Wait Shown)",
--   color = beautiful.neutral[400],
-- })

local percent = ui.textbox({
  text  = "0%",
  align = "right",
  color = beautiful.neutral[200],
  font  = beautiful.font_reg_l,
})

local progress = wibox.widget({
  value = 0,
  max_value = 100,
  background_color = beautiful.neutral[700],
  forced_height = dpi(8),
  shape = ui.rrect(),
  color = beautiful.primary[400],
  widget = wibox.widget.progressbar,
})

local header = wibox.widget({
  {
    title,
    percent,
    layout = wibox.layout.align.horizontal,
  },
  {
    tag,
    ui.textbox({
      text = " - ",
      color = beautiful.neutral[400],
    }),
    remaining,
    -- wait_status,
    layout = wibox.layout.fixed.horizontal,
  },
  progress,
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

task:connect_signal("selected::project", function(_, _tag, project)
  title:update_text(project)
  tag:update_text(_tag)
  task:fetch_project_stats(_tag, project)
end)

task:connect_signal("ready::project_stats", function(_, pending, completed)
  local val = math.floor((completed / (pending+completed)) * 100)
  remaining:update_text(pending..'/'..pending+completed..' remaining')
  percent:update_text(val..'%')
  progress.value = val
end)

return header
