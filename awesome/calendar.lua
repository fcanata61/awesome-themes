local awful = require("awful")

textclock_widget = awful.widget.textclock(" %a %d %b  %H:%M ")

calendar_widget = awful.tooltip({objects={textclock_widget}})
awful.spawn.easy_async('gcal -i- -s1 .+', function(stdout)
    calendar_widget:set_text(stdout)
end)
