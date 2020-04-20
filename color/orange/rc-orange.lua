-----------------------------------------------------------------------------------------------------------------------
--                                                  Orange config                                                    --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local redutil = require("redflat.util")
local system = require("redflat.system")
local calendar = require("calendar")

require("awful.autofocus")

-- local naughty = require("naughty")
-- function table.val_to_str ( v )
--   if "string" == type( v ) then
--     v = string.gsub( v, "\n", "\\n" )
--     if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
--       return "'" .. v .. "'"
--     end
--     return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
--   else
--     return "table" == type( v ) and table.tostring( v ) or
--       tostring( v )
--   end
-- end

-- function table.key_to_str ( k )
--   if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
--     return k
--   else
--     return "[" .. table.val_to_str( k ) .. "]"
--   end
-- end

-- function table.tostring( tbl )
--   local result, done = {}, {}
--   for k, v in ipairs( tbl ) do
--     table.insert( result, table.val_to_str( v ) )
--     done[ k ] = true
--   end
--   for k, v in pairs( tbl ) do
--     if not done[ k ] then
--       table.insert( result,
--         table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
--     end
--   end
--   return "{" .. table.concat( result, "," ) .. "}"
-- end

-- User modules
------------------------------------------------------------
local redflat = require("redflat")

-- debug locker
local lock = lock or {}

redflat.startup.locked = lock.autostart
redflat.startup:activate()

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("colorless.ercheck-config") -- load file with error handling

-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("color.blue.env-config") -- load file with environment
env:init({ theme = "orange", color_border_focus = true })

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("color.blue.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("color.blue.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
-- local separator = redflat.gauge.separator.vertical()
local separator = nil

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

-- load list of app name aliases from files and set it as part of tasklist theme
tasklist.style = { appnames = require("color.blue.alias-config")}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { widget = redflat.gauge.tag.orange.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%Y-%m-%d" })
local calendar_widget = calendar({
  fdow = 1,                  -- Set Sunday as first day of the week (default is
                             -- 1 = Monday)
  position = "top_right", -- Useful if you prefer your wibox at the bottomn
                             -- of the screen
  today_color = beautiful.color.main
})
calendar_widget:attach(textclock.widget)

-- Software update indcator
--------------------------------------------------------------------------------
redflat.widget.updates:init({ command = env.updates })

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () mymenu.mainmenu:toggle() end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)

-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.red.new })

-- activate player widget
-- redflat.float.player:init({ name = env.player })

-- volume.buttons = awful.util.table.join(
-- 	awful.button({}, 4, function() volume.widget:change_volume()                end),
-- 	awful.button({}, 5, function() volume.widget:change_volume({ down = true }) end),
-- 	awful.button({}, 2, function() volume.widget:mute()                         end),
-- 	awful.button({}, 3, function() redflat.float.player:show()                  end),
-- 	awful.button({}, 1, function() redflat.float.player:action("PlayPause")     end),
-- 	awful.button({}, 8, function() redflat.float.player:action("Previous")      end),
-- 	awful.button({}, 9, function() redflat.float.player:action("Next")          end)
-- )

-- -- naughty.notify({ text = table.tostring(beautiful.theme) })
-- file = io.open("/home/akemrir/beautiful.x", "a")
-- -- file:write(table.tostring(beautiful.get()))
-- -- file:write(table.tostring(beautiful.get().fonts))
-- -- file:write(beautiful.get().fonts.clock)
-- file:close()


-- load the widget code
local volume_control = require("volume-control")

local theme = beautiful.get();
-- file = io.open("/home/akemrir/beautiful.x", "a")
-- file:write(table.tostring(theme))
-- file:close()

-- define your volume control, using default settings:
volumecfg = volume_control({
  device = "pulse",
  font = theme.fonts.clock,
  widget_text = {
    on  = '<span color="' .. theme.color.icon .. '">% 3d%%</span>',        -- three digits, fill with leading spaces
    off = '<span color="' .. theme.color.urgent .. '">% 3dM</span>',
  },
})

-- Keyboard layout indicator
--------------------------------------------------------------------------------
-- local kbindicator = {}
-- redflat.widget.keyboard:init({ "Polish", "English" })
-- kbindicator.widget = redflat.widget.keyboard()

-- kbindicator.buttons = awful.util.table.join(
-- 	awful.button({}, 1, function () redflat.widget.keyboard:toggle_menu() end),
-- 	awful.button({}, 4, function () redflat.widget.keyboard:toggle()      end),
-- 	awful.button({}, 5, function () redflat.widget.keyboard:toggle(true)  end)
-- )

-- Mail widget
--------------------------------------------------------------------------------
-- -- mail settings template
-- local my_mails = require("color.blue.mail-example")

-- -- safe load private mail settings
-- pcall(function() my_mails = require("private.mail-config") end)

-- -- widget setup
-- local mail = {}
-- redflat.widget.mail:init({ maillist = my_mails })
-- mail.widget = redflat.widget.mail()

-- naughty.notify({ text = "normal", urgency = "normal" })
-- naughty.notify({ text = "low", urgency = "low" })
-- naughty.notify({ text = "critical", urgency = "critical" })

-- -- buttons
-- mail.buttons = awful.util.table.join(
-- 	-- awful.button({ }, 1, function () awful.spawn.with_shell(env.mail) end),
-- 	-- awful.button({ }, 2, function () redflat.widget.mail:update(true) end)
-- )

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {} }

-- battery
sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
	{ timeout = 60, widget = redflat.gauge.monitor.circle }
)

-- network speed
sysmon.widget.network = redflat.widget.net(
	{
		interface = "enp6s0",
		speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
		autoscale = false
	},
	{ timeout = 2, widget = redflat.gauge.icon.double }
)

-- CPU usage
sysmon.widget.cpu = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.cpu(80) },
	{ timeout = 2, widget = redflat.gauge.monitor.circle }
)

sysmon.buttons.cpu = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
)

-- RAM usage
sysmon.widget.ram = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.mem(80) },
	{ timeout = 10, widget = redflat.gauge.monitor.circle }
)

sysmon.buttons.ram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("mem") end)
)

local GET_MPD_CMD = "mpc -p 7600 status"
local NEXT_MPD_CMD = "mpc -p 7600 next"
local PAUSE_MPD_CMD = "mpc -p 7600 pause"
local PREV_MPD_CMD = "mpc -p 7600 prev"
local STOP_MPD_CMD = "mpc -p 7600 stop"
local TOGGLE_MPD_CMD = "mpc -p 7600 toggle"

local mpd_status = function()
  local ret = {}
  ret.text = 'Loading'
  ret.alert = false
  ret.value = 0.5

  local line = redutil.read.output(GET_MPD_CMD)
  local stdout = string.gsub(line, "\n", "")
  local mpdpercent = string.match(stdout, "(%d+)%%")

  if string.match(stdout, "%[playing]") then
    local value = tonumber(mpdpercent/100)
    ret.value = value
    -- ret.text = 'MPD: '.. mpdpercent .. '% utworu'
    ret.text = line
  elseif string.match(stdout, "%[paused]") then
    local value = tonumber(mpdpercent/100)
    ret.value = value
    -- ret.text = 'MPD: '..mpdpercent .. '% utworu'
    ret.text = line
    ret.alert = true
  elseif string.match(stdout, "MPD error") then
    ret.value = 1
    ret.text = "MPD: niepodłączone"
    ret.alert = false
  else
    ret.value = 1
    ret.text = "Sprawdź rc-orange.lua +261"
    ret.alert = true
  end

  return ret
end

sysmon.widget.mpd = redflat.widget.sysmon(
  { func = mpd_status },
  { timeout = 1, widget = redflat.gauge.monitor.circle }
)
sysmon.buttons.mpd = awful.util.table.join(
  awful.button({ }, 1, function() awful.spawn(TOGGLE_MPD_CMD) end),
  awful.button({ }, 2, function() awful.spawn(STOP_MPD_CMD) end),
  awful.button({ }, 3, function() awful.spawn(PAUSE_MPD_CMD) end),
  awful.button({ }, 4, function() awful.spawn(NEXT_MPD_CMD) end),
  awful.button({ }, 5, function() awful.spawn(PREV_MPD_CMD) end),
  awful.button({ }, 9, function()
    awful.spawn('/home/akemrir/bin/dmenu-mpd -a now_playing_album_songs')
  end),
  awful.button({ }, 8, function()
    awful.spawn('/home/akemrir/bin/dmenu-mpd -a open_album_dir')
  end)
)

local muil = { widget = {} }
muil.widget = awful.widget.watch('bash -c "cat /home/akemrir/.config/mutt/.dl"', 5)

-- local audio_output = { widget = {} }
-- audio_output.widget = awful.widget.watch('bash -c "cat /home/akemrir/bin/a-pa-switch.icon"', 3)

local torr = awful.widget.watch('/home/akemrir/bin/i3torrent', 3)
torr_t = awful.tooltip({ objects = { torr } })
torr:connect_signal("mouse::enter", function()
  awful.spawn.easy_async_with_shell('transmission-remote -l', function(stdout, stderr, reason, exit_code)
    torr_t.text = stdout
  end)
end)
torr:connect_signal("button::press", function()
  awful.spawn.easy_async_with_shell('thunar /home/akemrir/Pobrane')
end)

-- local new_record = { widget = {} }
-- new_record.widget = awful.widget.watch('bash -c "cat /home/akemrir/bin/.record-file"', 3)

-- local record = { widget = {} }
-- record.widget = awful.widget.watch('bash -c "cat /home/akemrir/bin/.record-state"', 5)
-- record.widget:connect_signal("button::press", function()
--   awful.spawn.easy_async_with_shell('notify-send record record')
-- end)

local record_2 = { widget = {} }
record_2.widget = wibox.widget {
    markup = 'This <i>is</i> a <b>textbox</b>!!!',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}
-- record_2.widget = wibox.widget.textbox
record_2.widget:connect_signal("button::press", function()
  awful.spawn.spawn('bash -c /home/akemrir/bin/dmenu-record')
end)
awful.widget.watch('bash -c "cat /home/akemrir/bin/.record-file"', 3, function(widget, stdout)
  -- naughty.notify({ title = "Achtung!", text = stdout, timeout = 0 })
  record_2.widget:set_markup(stdout)
end)
record_2_t = awful.tooltip({ objects = { record_2.widget } })

-- torr.widget:connect_signal("mouse::enter", function()
--   awful.spawn.easy_async_with_shell('cat /home/akemrir/bin/.record-file', function(stdout, stderr, reason, exit_code)
--     record_2_t.text = stdout
--   end)
-- end)


local device_status = function(parameters)
  local device = parameters[1]
  local label = parameters[2]

  local ret = {}
  local status = system.fs_info("/dev/" .. device)
  local pused = status[1]

  ret.text = "Dysk " .. device .. " - ".. label .." używa " .. pused .."% swojej pojemności"
  if pused > 80 then
    ret.alert = true
  else
    ret.alert = false
  end
  ret.value = pused/100

  return ret
end

local DEV_TIMEOUT = 60 * 5
sysmon.widget.boot_dev = redflat.widget.sysmon(
  { func = device_status, arg = {'sda3', 'boot'} },
  { timeout = DEV_TIMEOUT, widget = redflat.gauge.monitor.circle }
)
sysmon.widget.root_dev = redflat.widget.sysmon(
  { func = device_status, arg = {'sda4', 'root'} },
  { timeout = DEV_TIMEOUT, widget = redflat.gauge.monitor.circle }
)
sysmon.widget.var_dev = redflat.widget.sysmon(
  { func = device_status, arg = {'sdb2', 'var'} },
  { timeout = DEV_TIMEOUT, widget = redflat.gauge.monitor.circle }
)
sysmon.widget.home_dev = redflat.widget.sysmon(
  { func = device_status, arg = {'sdb4', 'home'} },
  { timeout = DEV_TIMEOUT, widget = redflat.gauge.monitor.circle }
)

-- Screen setup
-----------------------------------------------------------------------------------------------------------------------

-- aliases for setup
local al = awful.layout.layouts

-- setup
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
    awful.tag({ "code", "browser", "chat", "mail", "music", "chr", "pid" }, s,
              { al[3], al[3], al[3], al[3], al[3], al[3], al[3] })

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)

		-- panel wibox
		s.panel = awful.wibar({ position = "top", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				separator,
				env.wrapper(taglist[s], "taglist"),
				-- separator,
				-- env.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),
				-- separator,
				-- env.wrapper(mail.widget, "mail", mail.buttons),
				separator,
        env.wrapper(record_2.widget, "record_2"),
				separator,
        env.wrapper(muil.widget, "muil"),
				separator,
        env.wrapper(torr, "torr"),
				separator,
			},
			{ -- middle widget
				layout = wibox.layout.align.horizontal,
				expand = "outside",

				nil,
				env.wrapper(tasklist[s], "tasklist"),
			},
			{ -- right widgets
				layout = wibox.layout.fixed.horizontal,
				-- separator,
				env.wrapper(sysmon.widget.network, "network"),
				separator,
				env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
				env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
				env.wrapper(sysmon.widget.mpd, "mpd", sysmon.buttons.mpd),
				env.wrapper(sysmon.widget.boot_dev, "boot"),
				env.wrapper(sysmon.widget.root_dev, "root"),
				env.wrapper(sysmon.widget.var_dev, "var"),
				env.wrapper(sysmon.widget.home_dev, "home"),
				-- env.wrapper(sysmon.widget.battery, "battery"),
        -- env.wrapper(audio_output.widget, "audio_output"),
				separator,
        -- env.wrapper(new_record.widget, "new_record"),
				-- separator,
				-- env.wrapper(volume.widget, "volume", volume.buttons),
				env.wrapper(volumecfg.widget, "volume2"),
				-- separator,
				env.wrapper(textclock.widget, "textclock"),
				separator,
				env.wrapper(tray.widget, "tray", tray.buttons),
			},
		}
	end
)

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
-- if not lock.desktop then
-- 	local desktop = require("color.orange.desktop-config") -- load file with desktop widgets configuration
-- 	desktop:init({
-- 		env = env,
-- 		buttons = awful.util.table.join(awful.button({}, 3, function () mymenu.mainmenu:toggle() end))
-- 	})
-- end


-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
local edges = require("color.blue.edges-config") -- load file with edges configuration
edges:init()


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local appkeys = require("color.blue.appkeys-config") -- load file with application keys sheetb

local hotkeys = require("color.blue.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu, appkeys = appkeys, volume = volume.widget })


-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("color.blue.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("colorless.titlebar-config") -- load file with titlebar configuration
titlebar:init()


-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("colorless.signals-config") -- load file with signals configuration
signals:init({ env = env })


-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
if redflat.startup.is_startup then
	local autostart = require("color.blue.autostart-config") -- load file with autostart application list
	autostart.run()
end
