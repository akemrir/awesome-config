-----------------------------------------------------------------------------------------------------------------------
--                                                   Base setup                                                      --
-----------------------------------------------------------------------------------------------------------------------

local awful = require("awful")
local jn = require("jn")

package.loaded["naughty"] = {
  notify = function(notification)
    local result = jn.to_json(notification)

    awful.spawn.with_shell("/home/akemrir/bin/awesome_notify.sh '".. result .."'")

    print("notify:", result)
  end,
  config = {
    presets = {},
    defaults = {}
  }
}


-- Configuration file selection
-----------------------------------------------------------------------------------------------------------------------
--local rc = "colorless.rc-colorless"
--local rc = "color.red.rc-red"
--local rc = "color.blue.rc-blue"
local rc = "color.orange.rc-orange"
--local rc = "color.green.rc-green"

-- local rc = "shade.ruby.rc-ruby"
-- local rc = "shade.steel.rc-steel"

require(rc)
