local naughty = require("naughty")
local wibox = require("wibox")
local awful = require("awful")
local su = require('su')

local ret = {}

local function try_noop()

    awful.spawn.easy_async_with_shell('sleep 2s && music-client noop', function(stdout, stderr, reason, code)

        if code == 1 then
            try_noop()
        elseif code == 0 then
            ret.execute_command('noop')
        end
    end);

end

ret.execute_command = function(command, arg)

    awful.spawn.easy_async({'music-client', command, arg}, function(stdout, stderr, reason, code)

        local active_command =
            su.starts_with(command, 'file') or
            su.starts_with(command, 'next') or
            su.starts_with(command, 'previous')

        local start_server_command = active_command or
            su.starts_with(command, 'play') or
            su.starts_with(command, 'pause')

        if code ~= 0 then
            -- Start the server and re-exec the command
            awful.spawn.easy_async({'music-server', 'command', command, arg}, function(stdout, stderr, reason, code)
            end)
        end

    end)

end

return ret
