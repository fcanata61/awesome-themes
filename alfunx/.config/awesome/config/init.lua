
--[[

     Awesome WM configuration
     by alfunx (Alphonse Mariya)

--]]

local _config = {

    context = require("config.context"),

    brokers = require("config.brokers"),
    tags = require("config.tags"),
    util = require("config.util"),
    util_theme = require("config.util_theme"),

    keys = require("config.keys"),
    bindings_global = require("config.bindings_global"),
    bindings_client = require("config.bindings_client"),
    bindings_command = require("config.bindings_command"),
    bindings_taglist = require("config.bindings_taglist"),
    bindings_tasklist = require("config.bindings_tasklist"),

    menu = require("config.menu"),
    popups = require("config.popups"),
    sidebar = require("config.sidebar"),

    wallpaper = require("config.wallpaper"),
    rules = require("config.rules"),
    signals = require("config.signals"),
    screens = require("config.screens"),

    fix_startup_id = require("config.fix_startup_id"),

}

return _config
