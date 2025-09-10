local os = require('os')
naughty = require('naughty')
local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')
local json = require('jsonutils')

local home = os.getenv('HOME')
local todo_path = home .. '/.config/todo/todo.json'

local widget = nil

function todo_list_widget(index, todo)

    local text = '\n    <b>' .. index .. '. ' .. todo.title .. '</b>    \n'

    for key, item in pairs(todo.items) do
        text = text .. '        ' .. key .. '. ' .. item .. '        \n'
    end

    local text = wibox.widget {
        markup = text,
        align  = 'left',
        valign = 'top',
        font = "Ubuntu 18",
        widget = wibox.widget.textbox
    }

    local widget = wibox.widget.background(text, todo.color, function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 20)
    end)

    widget.shape_border_width = 1
    widget.shape_border_color = "#ffffff"

    return widget

end

function update_background_widget(s)

    local margin = 25

    awful.spawn.easy_async_with_shell(":", function()

        if s.widget ~= nil then
            s.widget:remove()
        end

        local f = io.open(todo_path, "rb")

        if f ~= nil then

            local content = f:read("*all")
            f:close()

            todo = json.parse(content)

            local l = wibox.layout {
                homogeneous   = false,
                spacing       = margin,
                forced_num_cols = 3,
                layout        = wibox.layout.grid,
            }

            -- l:set_orientation('horizontal')

            local widgets = {}

            for key, val in pairs(todo) do
                l:add(todo_list_widget(key, val))
            end

            background_widget = awful.wibar({
                screen = s,
                height = s.geometry.height,
                bg = "#00000000",
            })

            background_widget:setup {
                wibox.container.margin(l, margin, margin, margin, margin),
                layout = wibox.layout.manual
            }

            background_widget:struts({left=0, right=0, top=0, bottom=0})

            s.widget = background_widget

        end

    end)

end

