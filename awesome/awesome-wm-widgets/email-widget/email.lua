local os = require("os")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")

local path_to_icons = "/usr/share/icons/Arc/actions/22/"

local home = os.getenv('HOME')

local email_widget = wibox.widget.textbox()
email_widget:set_font('Play 9')

local email_icon = wibox.widget.imagebox()
email_icon:set_image(path_to_icons .. "/mail-mark-new.png")

local previous_value = 0

local password1 = ''
local password2 = ''
local password3 = ''

awful.spawn.easy_async_with_shell('pass web/mail.ovh.com; pass web/webmail.gandi.net; pass web/cas.inp-toulouse.fr;', function(stdout)
    s = split(stdout, '\n')
    password1 = s[1]
    password2 = s[2]
    password3 = s[3]

    watch(
        "bash -c '" .. home .. "/.config/awesome/awesome-wm-widgets/email-widget/count_unread_emails.py \"" .. password1 .. "\" \"" .. password2 .. "\" \"" .. password3 .. "\"'", 60,
        function(widget, stdout, stderr, exitreason, exitcode)
            local unread_emails_num = tonumber(stdout) or 0

            if previous_value < unread_emails_num then
                previous_value = unread_emails_num
                show_emails(10)
            end

            email_widget:set_text(stdout)
            if (unread_emails_num > 0) then
                email_icon:set_image(path_to_icons .. "/mail-mark-unread.png")
            elseif (unread_emails_num == 0) then
                email_icon:set_image(path_to_icons .. "/mail-message-new.png")
            end
        end
    )
end)

function split(str, delimiter)
    if str == nil then
        return {}
    end
    local ret = {''}
    count = 1
    for i = 1, string.len(str) do
        local c = str:sub(i,i)
        if c == delimiter then
            count = count + 1
            ret[count] = ''
        else
            ret[count] = ret[count] .. c
        end
    end
    return ret
end

function show_emails(timeout)
    awful.spawn.easy_async_with_shell(home .. "/.config/awesome/awesome-wm-widgets/email-widget/read_unread_emails.py \"" .. password1 .. "\" \"" .. password2 .. "\" \"" .. password3 .."\"",
        function(stdout, stderr, reason, exit_code)

            s = split(stderr, '\n')
            local actions = {}

            if stderr ~= '' then
                for index, line in pairs(s) do
                    if index > 1 then
                        actions["Check email from account " .. tostring(index - 1)] = function ()
                            awful.spawn.easy_async("firefox " .. s[index - 1], function() end)
                        end
                    end
                end
            end

            naughty.notify{
                text = stdout,
                title = "Unread Emails",
                timeout = timeout,
                width = 400,
                actions = actions,
            }
        end
    )
end

email_icon:connect_signal("button::press", function() show_emails(5) end)

return {
    icon = email_icon,
    widget = email_widget
}
