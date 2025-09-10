-- This function returns a formatted string with the current battery status. It
-- can be used to populate a text widget in the awesome window manager. Based
-- on the "Gigamo Battery Widget" found in the wiki at awesome.naquadah.org

local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local awful = require('awful')
local su = require('su')

local previous_percent = 0

function batteryInfo(callback)
    awful.spawn.easy_async('acpi', function(stdout)
        -- Consider only the first line
        local line = su.split(stdout, '\n')[1]

        local split = su.split(line, ':')

        -- Extract the percentage from the string
        local percent = tonumber(su.split(split[2],',')[2]:sub(1, -2))

        -- callback(percent, isCharging)
        callback(tonumber(percent), not string.find(line, 'Discharging'))
    end)
end

function update_battery()

    batteryInfo(function(percent, isCharging)

        local color
        local symbol

        if percent < 15 then
            color="red"
        elseif percent < 30 then
            color="orange"
        elseif percent > 90 then
            color="green"
        else
            color="white"
        end

        if isCharging then
            color = 'green'
            symbol = '⚡'
        else
            symbol = '%'
        end

        if previous_percent >= 15 and percent < 15 then
            naughty.notify({
                title = "Low battery...",
                text = "Battery level is lower than 15% !",
                fg="#000000",
                bg="#ff0000",
                timeout=5
            })
        end

        battery_widget:set_markup('<span color="' .. color .. '">' .. percent .. ' ' .. symbol .. '</span>')

        previous_percent = percent

    end)

end

battery_widget = wibox.widget.textbox()
battery_widget.timer = timer({timeout=5})
battery_widget.timer:connect_signal("timeout", update_battery)
battery_widget.timer:start()
update_battery()
