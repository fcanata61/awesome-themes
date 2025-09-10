local wibox = require("wibox")
local awful = require("awful")

volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")

function update_volume()

    awful.spawn.easy_async('amixer sget Master', function(stdout, stderr)
        local status = stdout
        local widget = volume_widget

        -- local volume = tonumber(string.match(status, "(%d?%d?%d)%%")) / 100
        local volume = string.match(status, "(%d?%d?%d)%%")
        volume = string.format("% 3d", volume)
        status = string.match(status, "%[(o[^%]]*)%]")

        if string.find(status, "on", 1, true) then
            -- For the volume numbers
            volume = volume .. "%"
        else
            -- For the mute button
            volume = volume .. "M"
        end
        widget:set_markup("V :" .. volume)
    end)
end

update_volume()
