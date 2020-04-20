-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local table = table
local awful = require("awful")
local redflat = require("redflat")
local naughty = require("naughty")

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


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { mouse = {}, raw = {}, keys = {}, fake = {} }

-- key aliases
local apprunner = redflat.float.apprunner
local appswitcher = redflat.float.appswitcher
local current = redflat.widget.tasklist.filter.currenttags
local allscr = redflat.widget.tasklist.filter.allscreen
local laybox = redflat.widget.layoutbox
local redtip = redflat.float.hotkeys
local laycom = redflat.layout.common
local grid = redflat.layout.grid
local map = redflat.layout.map
-- local redtitle = redflat.titlebar
local qlaunch = redflat.float.qlaunch

-- Key support functions
-----------------------------------------------------------------------------------------------------------------------

-- change window focus by history
local function focus_to_previous()
	awful.client.focus.history.previous()
	if client.focus then client.focus:raise() end
end

-- change window focus by direction
local focus_switch_byd = function(dir)
	return function()
		awful.client.focus.bydirection(dir)
		if client.focus then client.focus:raise() end
	end
end

-- minimize and restore windows
local function minimize_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) then c.minimized = true end
	end
end

local function minimize_all_except_focused()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c ~= client.focus then c.minimized = true end
	end
end

local function restore_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c.minimized then c.minimized = false end
	end
end

local function restore_client()
	local c = awful.client.restore()
	if c then client.focus = c; c:raise() end
end

-- close window
local function kill_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and not c.sticky then c:kill() end
	end
end

-- new clients placement
local function toggle_placement(env)
	env.set_slave = not env.set_slave
	redflat.float.notify:show({ text = (env.set_slave and "Slave" or "Master") .. " placement" })
end

-- numeric keys function builders
local function tag_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then action(tag) end
		end
	)
end

local function client_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then action(tag) end
			end
		end
	)
end

-- brightness functions
local brightness = function(args)
	redflat.float.brightness:change_with_xbacklight(args) -- use xbacklight
end

-- right bottom corner position
-- local rb_corner = function()
-- 	return { x = screen[mouse.screen].workarea.x + screen[mouse.screen].workarea.width,
-- 	         y = screen[mouse.screen].workarea.y + screen[mouse.screen].workarea.height }
-- end

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init(args)

	-- Init vars
	args = args or {}
	local env = args.env
	-- local volume = args.volume
	local mainmenu = args.menu
	local appkeys = args.appkeys or {}

	self.mouse.root = (awful.util.table.join(
		awful.button({ }, 3, function () mainmenu:toggle() end)
		-- awful.button({ }, 4, awful.tag.viewnext),
		-- awful.button({ }, 5, awful.tag.viewprev)
	))

	-- volume functions
	-- local volume_raise = function() volume:change_volume({ show_notify = true })              end
	-- local volume_lower = function() volume:change_volume({ show_notify = true, down = true }) end
	-- local volume_mute  = function() volume:mute() end

	-- Init widgets
	redflat.float.qlaunch:init()

	-- Application hotkeys helper
	--------------------------------------------------------------------------------
	local apphelper = function(keys)
		if not client.focus then return end

		local app = client.focus.class:lower()
		for name, sheet in pairs(keys) do
			if name == app then
				redtip:set_pack(
						client.focus.class, sheet.pack, sheet.style.column, sheet.style.geometry,
						function() redtip:remove_pack() end
				)
				redtip:show()
				return
			end
		end

		redflat.float.notify:show({ text = "No tips for " .. client.focus.class })
	end

	-- Keys for widgets
	--------------------------------------------------------------------------------

	-- Apprunner widget
	------------------------------------------------------------
	local apprunner_keys_move = {
		{
			{ env.mod }, "j", function() apprunner:down() end,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "k", function() apprunner:up() end,
			{ description = "Select previous item", group = "Navigation" }
		},
	}

	-- apprunner:set_keys(awful.util.table.join(apprunner.keys.move, apprunner_keys_move), "move")
	apprunner:set_keys(apprunner_keys_move, "move")

	-- Menu widget
	------------------------------------------------------------
	local menu_keys_move = {
		{
			{ env.mod }, "j", redflat.menu.action.down,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "k", redflat.menu.action.up,
			{ description = "Select previous item", group = "Navigation" }
		},
		{
			{ env.mod }, "h", redflat.menu.action.back,
			{ description = "Go back", group = "Navigation" }
		},
		{
			{ env.mod }, "l", redflat.menu.action.enter,
			{ description = "Open submenu", group = "Navigation" }
		},
	}

	-- redflat.menu:set_keys(awful.util.table.join(redflat.menu.keys.move, menu_keys_move), "move")
	redflat.menu:set_keys(menu_keys_move, "move")

	-- Appswitcher widget
	------------------------------------------------------------
	local appswitcher_keys = {
		{
			{ env.mod }, "a", function() appswitcher:switch() end,
			{ description = "Select next app", group = "Navigation" }
		},
		{
			{ env.mod, env.shift }, "a", function() appswitcher:switch() end,
			{} -- hidden key
		},
		{
			{ env.mod }, "q", function() appswitcher:switch({ reverse = true }) end,
			{ description = "Select previous app", group = "Navigation" }
		},
		{
			{ env.mod, env.shift }, "q", function() appswitcher:switch({ reverse = true }) end,
			{} -- hidden key
		},
		{
			{}, "Super_L", function() appswitcher:hide() end,
			{ description = "Activate and exit", group = "Action" }
		},
		{
			{ env.mod }, "Super_L", function() appswitcher:hide() end,
			{} -- hidden key
		},
		{
			{ env.mod, env.shift }, "Super_L", function() appswitcher:hide() end,
			{} -- hidden key
		},
		{
			{}, "Return", function() appswitcher:hide() end,
			{ description = "Activate and exit", group = "Action" }
		},
		{
			{}, "Escape", function() appswitcher:hide(true) end,
			{ description = "Exit", group = "Action" }
		},
		{
			{ env.mod }, "Escape", function() appswitcher:hide(true) end,
			{} -- hidden key
		},
		{
			{ env.mod }, "F1", function() redtip:show()  end,
			{ description = "Show hotkeys helper", group = "Action" }
		},
	}

	appswitcher:set_keys(appswitcher_keys)

	-- Emacs like key sequences
	--------------------------------------------------------------------------------

	-- initial key
	local keyseq = { { env.mod }, "c", {}, {} }

	-- group
	keyseq[3] = {
		{ {}, "k", {}, {} }, -- application kill group
		{ {}, "c", {}, {} }, -- client managment group
		{ {}, "r", {}, {} }, -- client managment group
		{ {}, "n", {}, {} }, -- client managment group
		{ {}, "g", {}, {} }, -- run or rise group
		{ {}, "f", {}, {} }, -- launch application group
	}

	-- quick launch key sequence actions
	for i = 1, 9 do
		local ik = tostring(i)
		table.insert(keyseq[3][5][3], {
			{}, ik, function() qlaunch:run_or_raise(ik) end,
			{ description = "Run or rise application №" .. ik, group = "Run or Rise", keyset = { ik } }
		})
		table.insert(keyseq[3][6][3], {
			{}, ik, function() qlaunch:run_or_raise(ik, true) end,
			{ description = "Launch application №".. ik, group = "Quick Launch", keyset = { ik } }
		})
	end

	-- application kill sequence actions
	keyseq[3][1][3] = {
		{
			{}, "f", function() if client.focus then client.focus:kill() end end,
			{ description = "Kill focused client", group = "Kill application", keyset = { "f" } }
		},
		{
			{}, "a", kill_all,
			{ description = "Kill all clients with current tag", group = "Kill application", keyset = { "a" } }
		},
	}

	-- client managment sequence actions
	keyseq[3][2][3] = {
		{
			{}, "p", function () toggle_placement(env) end,
			{ description = "Switch master/slave window placement", group = "Clients managment", keyset = { "p" } }
		},
	}

	keyseq[3][3][3] = {
		{
			{}, "f", restore_client,
			{ description = "Restore minimized client", group = "Clients managment", keyset = { "f" } }
		},
		{
			{}, "a", restore_all,
			{ description = "Restore all clients with current tag", group = "Clients managment", keyset = { "a" } }
		},
	}

	keyseq[3][4][3] = {
		{
			{}, "f", function() if client.focus then client.focus.minimized = true end end,
			{ description = "Minimized focused client", group = "Clients managment", keyset = { "f" } }
		},
		{
			{}, "a", minimize_all,
			{ description = "Minimized all clients with current tag", group = "Clients managment", keyset = { "a" } }
		},
		{
			{}, "e", minimize_all_except_focused,
			{ description = "Minimized all clients except focused", group = "Clients managment", keyset = { "e" } }
		},
	}


	-- Layouts
	--------------------------------------------------------------------------------

	-- shared layout keys
	local layout_tile = {
		{
			{ env.mod }, "l", function () awful.tag.incmwfact( 0.05) end,
			{ description = "Increase master width factor", group = "Layout" }
		},
		{
			{ env.mod }, "h", function () awful.tag.incmwfact(-0.05) end,
			{ description = "Decrease master width factor", group = "Layout" }
		},
		{
			{ env.mod }, "k", function () awful.client.incwfact( 0.05) end,
			{ description = "Increase window factor of a client", group = "Layout" }
		},
		{
			{ env.mod }, "j", function () awful.client.incwfact(-0.05) end,
			{ description = "Decrease window factor of a client", group = "Layout" }
		},
		{
			{ env.mod, }, "+", function () awful.tag.incnmaster( 1, nil, true) end,
			{ description = "Increase the number of master clients", group = "Layout" }
		},
		{
			{ env.mod }, "-", function () awful.tag.incnmaster(-1, nil, true) end,
			{ description = "Decrease the number of master clients", group = "Layout" }
		},
		{
			{ env.mod, env.ctrl }, "+", function () awful.tag.incncol( 1, nil, true) end,
			{ description = "Increase the number of columns", group = "Layout" }
		},
		{
			{ env.mod, env.ctrl }, "-", function () awful.tag.incncol(-1, nil, true) end,
			{ description = "Decrease the number of columns", group = "Layout" }
		},
	}

	laycom:set_keys(layout_tile, "tile")

	-- grid layout keys
	local layout_grid_move = {
		{
			{ env.mod }, "KP_Up", function() grid.move_to("up") end,
			{ description = "Move window up", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Down", function() grid.move_to("down") end,
			{ description = "Move window down", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Left", function() grid.move_to("left") end,
			{ description = "Move window left", group = "Movement" }
		},
		{
			{ env.mod }, "KP_right", function() grid.move_to("right") end,
			{ description = "Move window right", group = "Movement" }
		},
		{
			{ env.mod, env.ctrl }, "KP_Up", function() grid.move_to("up", true) end,
			{ description = "Move window up by bound", group = "Movement" }
		},
		{
			{ env.mod, env.ctrl }, "KP_Down", function() grid.move_to("down", true) end,
			{ description = "Move window down by bound", group = "Movement" }
		},
		{
			{ env.mod, env.ctrl }, "KP_Left", function() grid.move_to("left", true) end,
			{ description = "Move window left by bound", group = "Movement" }
		},
		{
			{ env.mod, env.ctrl }, "KP_Right", function() grid.move_to("right", true) end,
			{ description = "Move window right by bound", group = "Movement" }
		},
	}

	local layout_grid_resize = {
		{
			{ env.mod }, "k", function() grid.resize_to("up") end,
			{ description = "Inrease window size to the up", group = "Resize" }
		},
		{
			{ env.mod }, "j", function() grid.resize_to("down") end,
			{ description = "Inrease window size to the down", group = "Resize" }
		},
		{
			{ env.mod }, "h", function() grid.resize_to("left") end,
			{ description = "Inrease window size to the left", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() grid.resize_to("right") end,
			{ description = "Inrease window size to the right", group = "Resize" }
		},
		{
			{ env.mod, env.shift }, "k", function() grid.resize_to("up", nil, true) end,
			{ description = "Decrease window size from the up", group = "Resize" }
		},
		{
			{ env.mod, env.shift }, "j", function() grid.resize_to("down", nil, true) end,
			{ description = "Decrease window size from the down", group = "Resize" }
		},
		{
			{ env.mod, env.shift }, "h", function() grid.resize_to("left", nil, true) end,
			{ description = "Decrease window size from the left", group = "Resize" }
		},
		{
			{ env.mod, env.shift }, "l", function() grid.resize_to("right", nil, true) end,
			{ description = "Decrease window size from the right", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "k", function() grid.resize_to("up", true) end,
			{ description = "Increase window size to the up by bound", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "j", function() grid.resize_to("down", true) end,
			{ description = "Increase window size to the down by bound", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "h", function() grid.resize_to("left", true) end,
			{ description = "Increase window size to the left by bound", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "l", function() grid.resize_to("right", true) end,
			{ description = "Increase window size to the right by bound", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl, env.shift }, "k", function() grid.resize_to("up", true, true) end,
			{ description = "Decrease window size from the up by bound ", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl, env.shift }, "j", function() grid.resize_to("down", true, true) end,
			{ description = "Decrease window size from the down by bound ", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl, env.shift }, "h", function() grid.resize_to("left", true, true) end,
			{ description = "Decrease window size from the left by bound ", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl, env.shift }, "l", function() grid.resize_to("right", true, true) end,
			{ description = "Decrease window size from the right by bound ", group = "Resize" }
		},
	}

	redflat.layout.grid:set_keys(layout_grid_move, "move")
	redflat.layout.grid:set_keys(layout_grid_resize, "resize")

	-- user map layout keys
	local layout_map_layout = {
		{
			{ env.mod }, "s", function() map.swap_group() end,
			{ description = "Change placement direction for group", group = "Layout" }
		},
		{
			{ env.mod }, "v", function() map.new_group(true) end,
			{ description = "Create new vertical group", group = "Layout" }
		},
		{
			{ env.mod }, "h", function() map.new_group(false) end,
			{ description = "Create new horizontal group", group = "Layout" }
		},
		{
			{ env.mod, env.ctrl }, "v", function() map.insert_group(true) end,
			{ description = "Insert new vertical group before active", group = "Layout" }
		},
		{
			{ env.mod, env.ctrl }, "h", function() map.insert_group(false) end,
			{ description = "Insert new horizontal group before active", group = "Layout" }
		},
		{
			{ env.mod }, "d", function() map.delete_group() end,
			{ description = "Destroy group", group = "Layout" }
		},
		{
			{ env.mod, env.ctrl }, "d", function() map.clean_groups() end,
			{ description = "Destroy all empty groups", group = "Layout" }
		},
		{
			{ env.mod }, "f", function() map.set_active() end,
			{ description = "Set active group", group = "Layout" }
		},
		{
			{ env.mod }, "g", function() map.move_to_active() end,
			{ description = "Move focused client to active group", group = "Layout" }
		},
		{
			{ env.mod, env.ctrl }, "f", function() map.hilight_active() end,
			{ description = "Hilight active group", group = "Layout" }
		},
		{
			{ env.mod }, "a", function() map.switch_active(1) end,
			{ description = "Activate next group", group = "Layout" }
		},
		{
			{ env.mod }, "q", function() map.switch_active(-1) end,
			{ description = "Activate previous group", group = "Layout" }
		},
		{
			{ env.mod }, "]", function() map.move_group(1) end,
			{ description = "Move active group to the top", group = "Layout" }
		},
		{
			{ env.mod }, "[", function() map.move_group(-1) end,
			{ description = "Move active group to the bottom", group = "Layout" }
		},
		{
			{ env.mod }, "r", function() map.reset_tree() end,
			{ description = "Reset layout structure", group = "Layout" }
		},
	}

	local layout_map_resize = {
		{
			{ env.mod }, "h", function() map.incfactor(nil, 0.1, false) end,
			{ description = "Increase window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() map.incfactor(nil, -0.1, false) end,
			{ description = "Decrease window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "k", function() map.incfactor(nil, 0.1, true) end,
			{ description = "Increase window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod }, "j", function() map.incfactor(nil, -0.1, true) end,
			{ description = "Decrease window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "h", function() map.incfactor(nil, 0.1, false, true) end,
			{ description = "Increase group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "l", function() map.incfactor(nil, -0.1, false, true) end,
			{ description = "Decrease group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "k", function() map.incfactor(nil, 0.1, true, true) end,
			{ description = "Increase group vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, env.ctrl }, "j", function() map.incfactor(nil, -0.1, true, true) end,
			{ description = "Decrease group vertical size factor", group = "Resize" }
		},
	}

	redflat.layout.map:set_keys(layout_map_layout, "layout")
	redflat.layout.map:set_keys(layout_map_resize, "resize")


	-- Global keys
	--------------------------------------------------------------------------------
	self.raw.root = {
		{
			{ env.mod }, "F1", function() redtip:show() end,
			{ description = "[Hold] Show awesome hotkeys helper", group = "Main" }
		},
		{
			{ env.mod, env.ctrl }, "F1", function() apphelper(appkeys) end,
			{ description = "[Hold] Show hotkeys helper for application", group = "Main" }
		},
		{
			{ env.mod }, "c", function() redflat.float.keychain:activate(keyseq, "User") end,
			{ description = "[Hold] User key sequence", group = "Main" }
		},

		{
			{ env.mod }, "F2", function () redflat.service.navigator:run() end,
			{ description = "[Hold] Tiling window control mode", group = "Window control" }
		},
		{
			{ env.mod, env.shift }, "f", function() redflat.float.control:show() end,
			{ description = "[Hold] Floating window control mode", group = "Window control" }
		},
		{
			{ env.mod }, "b", function() redflat.float.bartip:show() end,
			{ description = "[Hold] Titlebar control", group = "Window control" }
		},
		{
			{ env.mod }, "Return", function() awful.spawn(env.terminal) end,
			{ description = "Open a terminal", group = "Actions" }
		},
		-- {
		-- 	{ env.mod, "Mod1" }, "space", function() awful.spawn("clipflap --show") end,
		-- 	{ description = "Clipboard manager", group = "Actions" }
		-- },
		{
			{ env.mod, env.ctrl }, "r", awesome.restart,
			{ description = "Reload WM", group = "Actions" }
		},

		{
			{ env.mod }, "l", focus_switch_byd("right"),
			{ description = "Go to right client", group = "Client focus" }
		},
		{
			{ env.mod }, "h", focus_switch_byd("left"),
			{ description = "Go to left client", group = "Client focus" }
		},
		{
			{ env.mod }, "k", focus_switch_byd("up"),
			{ description = "Go to upper client", group = "Client focus" }
		},
		{
			{ env.mod }, "j", focus_switch_byd("down"),
			{ description = "Go to lower client", group = "Client focus" }
		},
		{
			{ env.mod }, "u", awful.client.urgent.jumpto,
			{ description = "Go to urgent client", group = "Client focus" }
		},
		{
			{ env.mod }, "Tab", focus_to_previous,
			{ description = "Go to previos client", group = "Client focus" }
		},
		{
			{ env.mod }, "w", function() mainmenu:show() end,
			{ description = "Show main menu", group = "Widgets" }
		},
		{
			{ env.mod }, "r", function() apprunner:show() end,
			{ description = "Application launcher", group = "Widgets" }
		},
		-- {
		-- 	{ env.mod }, "p", function() redflat.float.prompt:run() end,
		-- 	{ description = "Show the prompt box", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod }, "x", function() redflat.float.top:show("cpu") end,
		-- 	{ description = "Show the top process list", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod, env.ctrl }, "m", function() redflat.widget.mail:update(true) end,
		-- 	{ description = "Check new mail", group = "Widgets" }
		-- },
		{
			{ env.mod, env.ctrl }, "k", function() redflat.widget.minitray:toggle() end,
			{ description = "Show minitray", group = "Widgets" }
		},
		-- {
		-- 	{ env.mod, env.ctrl }, "u", function() redflat.widget.updates:update(true) end,
		-- 	{ description = "Check available updates", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod }, "g", function() qlaunch:show() end,
		-- 	{ description = "Application quick launcher", group = "Widgets" }
		-- },
		{
			{ env.mod }, "t", function() naughty.notify({ text = "Aktualny tag: " ..  mouse.screen.selected_tag.name }) end,
			{ description = "Show current tag", group = "Layouts" }
		},
		{
			{ env.mod }, "y", function() laybox:toggle_menu(mouse.screen.selected_tag) end,
			{ description = "Show layout menu", group = "Layouts" }
		},
		{
			{ env.mod}, "Up", function() awful.layout.inc(1) end,
			{ description = "Select next layout", group = "Layouts" }
		},
		{
			{ env.mod }, "Down", function() awful.layout.inc(-1) end,
			{ description = "Select previous layout", group = "Layouts" }
		},

		{
			{}, "XF86MonBrightnessUp", function() brightness({ step = 2 }) end,
			{ description = "Increase brightness", group = "Brightness control" }
		},
		{
			{}, "XF86MonBrightnessDown", function() brightness({ step = 2, down = true }) end,
			{ description = "Reduce brightness", group = "Brightness control" }
		},

    -- wyłączyłeś specjalnie dla swojego
		-- {
		-- 	{}, "XF86AudioRaiseVolume", volume_raise,
		-- 	{ description = "Increase volume", group = "Volume control" }
		-- },
		-- {
		-- 	{}, "XF86AudioLowerVolume", volume_lower,
		-- 	{ description = "Reduce volume", group = "Volume control" }
		-- },
		-- {
		-- 	{}, "XF86AudioMute", volume_mute,
		-- 	{ description = "Mute audio", group = "Volume control" }
		-- },

		{
			{ env.mod }, "a", nil, function() appswitcher:show({ filter = current }) end,
			{ description = "Switch to next with current tag", group = "Application switcher" }
		},
		{
			{ env.mod }, "q", nil, function() appswitcher:show({ filter = current, reverse = true }) end,
			{ description = "Switch to previous with current tag", group = "Application switcher" }
		},
		{
			{ env.mod, env.shift }, "a", nil, function() appswitcher:show({ filter = allscr }) end,
			{ description = "Switch to next through all tags", group = "Application switcher" }
		},
		{
			{ env.mod, env.shift }, "q", nil, function() appswitcher:show({ filter = allscr, reverse = true }) end,
			{ description = "Switch to previous through all tags", group = "Application switcher" }
		},

		{
			{ env.mod }, "Escape", awful.tag.history.restore,
			{ description = "Go previos tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Right", awful.tag.viewnext,
			{ description = "View next tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Left", awful.tag.viewprev,
			{ description = "View previous tag", group = "Tag navigation" }
		},

		-- {
		-- 	{ env.mod }, "t", function() redtitle.toggle(client.focus) end,
		-- 	{ description = "Show/hide titlebar for focused client", group = "Titlebar" }
		-- },
		-- {
		-- 	{ env.mod, env.ctrl }, "t", function() redtitle.switch(client.focus) end,
		-- 	{ description = "Switch titlebar view for focused client", group = "Titlebar" }
		-- },
		-- {
		-- 	{ env.mod, env.shift }, "t", function() redtitle.toggle_all() end,
		-- 	{ description = "Show/hide titlebar for all clients", group = "Titlebar" }
		-- },
		-- {
		-- 	{ env.mod, env.ctrl, env.shift }, "t", function() redtitle.global_switch() end,
		-- 	{ description = "Switch titlebar view for all clients", group = "Titlebar" }
		-- },

		-- {
		-- 	{ env.mod }, "e", function() redflat.float.player:show(rb_corner()) end,
		-- 	{ description = "Show/hide widget", group = "Audio player" }
		-- },
		-- {
		-- 	{}, "XF86AudioPlay", function() redflat.float.player:action("PlayPause") end,
		-- 	{ description = "Play/Pause track", group = "Audio player" }
		-- },
		-- {
		-- 	{}, "XF86AudioNext", function() redflat.float.player:action("Next") end,
		-- 	{ description = "Next track", group = "Audio player" }
		-- },
		-- {
		-- 	{}, "XF86AudioPrev", function() redflat.float.player:action("Previous") end,
		-- 	{ description = "Previous track", group = "Audio player" }
		-- },
    {
      {}, "XF86AudioRaiseVolume", function() awful.spawn('/home/akemrir/bin/vol -u') end,
      { description = "Increase volume", group = "Volume control" }
    },
    {
      {}, "XF86AudioLowerVolume", function() awful.spawn('/home/akemrir/bin/vol -d') end,
      { description = "Reduce volume", group = "Volume control" }
    },
    {
      {}, "XF86AudioMute", function() awful.spawn('/home/akemrir/bin/vol -m') end,
      { description = "Toggle mute", group = "Volume control" }
    },
    {
      {}, "XF86AudioPlay", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a pause') end,
      { description = "Play/Pause track", group = "Audio player" }
    },
    {
      {}, "XF86AudioNext", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a next') end,
      { description = "Next track", group = "Audio player" }
    },
    {
      {}, "XF86AudioPrev", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a prev') end,
      { description = "Previous track", group = "Audio player" }
    },

    {
      { env.mod }, "v", function() awful.util.spawn('/home/akemrir/bin/transmission-dmenu') end,
      { description = "Show dmenu for torrents", group = "Util" }
    },
    -- {
    --   { env.mod, }, "g", function() awful.spawn('gromit-mpx --opacity 1') end,
    --   { description = "Paint on screen app", group = "Util" }
    -- },
    {
      {}, "Print", function() awful.util.spawn_with_shell('/home/akemrir/bin/maimfull') end,
      { description = "Take screenshot", group = "Util" }
    },
    {
      { env.shift }, "Print", function() awful.util.spawn_with_shell('/home/akemrir/bin/maimpick') end,
      { description = "Take screenshot", group = "Util" }
    },
    -- {
    --   { env.mod, env.shift }, "Print", function() awful.util.spawn_with_shell('/home/akemrir/bin/a-socr') end,
    --   { description = "Take screenshot and ocr it", group = "Util" }
    -- },

    {
      { env.mod, env.shift }, "[", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a play_album_song') end,
      { description = "Play album song from mpd", group = "Mpd" }
    },
    -- {
    --   { env.mod }, "]", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a play_song') end,
    --   { description = "Play song from mpd", group = "Mpd" }
    -- },
    {
      { env.mod }, "[", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a add_album') end,
      { description = "Add album to mpd", group = "Mpd" }
    },
    -- {
    --   { env.mod }, "x", function() awful.spawn('pavucontrol') end,
    --   { description = "Pavucontrol", group = "Mpd", floating = true }
    -- },
    {
      { env.mod }, "n", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a now_playing') end,
      { description = "Now playing mpd", group = "Mpd" }
    },
    {
      { env.mod }, ",", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a open_album_dir') end,
      { description = "Open album directory", group = "Mpd" }
    },
    {
      { env.mod, env.shift }, "n", function() awful.spawn('/home/akemrir/bin/dmenu-mpd -a now_playing_album_songs') end,
      { description = "Now playing mpd songs list", group = "Mpd" }
    },
    -- {
    --   { env.mod, env.shift }, "a", function() awful.spawn('st -e alsamixer') end,
    --   { description = "Alsamixer", group = "Util" }
    -- },
    {
      { env.ctrl, env.alt }, "p", function() awful.util.spawn_with_shell('passmenu') end,
      { description = "Dmenu passmenu", group = "Util" }
    },

    {
      { env.mod, env.shift }, "p", function() awful.util.spawn_with_shell('/home/akemrir/bin/a-winactivate') end,
      { description = "Choose window", group = "Util" }
    },
    {
      { env.mod, env.shift }, "r", function() awful.util.spawn_with_shell('/home/akemrir/bin/dmenu-record') end,
      { description = "Turn on desktop recording", group = "Util" }
    },
    {
      { env.mod, env.shift }, "b", function() awful.spawn('/home/akemrir/bin/a-pa-switch') end,
      { description = "Switch audio output analog/digital", group = "Util" }
    },
    {
      { env.mod }, ".", function() awful.util.spawn_with_shell('/home/akemrir/bin/zraz') end,
      { description = "Search via dmenu in browser", group = "Util" }
    },
    {
      { env.mod }, "e", function() awful.util.spawn_with_shell('/home/akemrir/bin/emoji') end,
      { description = "Select emoticon", group = "Util" }
    },
    {
      { env.mod }, "p", function() awful.spawn('dmenu_run') end,
      { description = "Launcher", group = "Util" }
    },
    {
      { env.mod, env.shift }, "c", function() awful.spawn('qalculate-gtk') end,
      { description = "Qalculate", group = "Util" }
    },
    {
      { env.mod }, "z", function()
        awful.spawn('xzoom', {
          floating = true,
          ontop = true,
          tag = mouse.screen.selected_tag
        })
      end,
      { description = "Desktop zoom", group = "Util" }
    },

		{
			{ env.mod }, "F3", function () awful.util.spawn_with_shell('/home/akemrir/bin/search_wiki.sh') end,
			{ description = "Search local arch wiki", group = "Util" }
		},

    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
    {
      { env.mod }, "i", awful.tag.viewprev,
      { description = "View previous tag", group = "Tag navigation" }
    },
    {
      { env.mod }, "o", awful.tag.viewnext,
      { description = "View next tag", group = "Tag navigation" }
    },

    -- {
    --   { env.mod, env.shift }, redflat.menu.action.enter, function() awful.spawn('gvim') end,
    --   { description = "Gvim", group = "Util" }
    -- },

    -- {
    --   { env.mod }, "space", function()
    --     naughty.destroy_all_notifications()
    --   end,
    --   { description = "Clear notifications", group = "Util" }
    -- },

    {
      { env.mod }, "s", function() awful.spawn("tdrop --class st_tdrop -ma -y 36 -w 100% -h -100 st") end,
      { description = "Tdrop st", group = "Util" }
    },

    {
      { env.ctrl, env.alt }, "e", function()
        awful.util.spawn_with_shell('/home/akemrir/.dmenu/dmenu-edit-configs.sh')
      end,
      { description = "Dmenu passmenu", group = "Util" }
    },

		{
			{ env.mod, env.ctrl }, "s", function() for s in screen do env.wallpaper(s) end end,
			{} -- hidden key
		}
	}

	-- Client keys
	--------------------------------------------------------------------------------
	self.raw.client = {
		{
			{ env.mod }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
			{ description = "Toggle fullscreen", group = "Client keys" }
		},
		{
			{ env.mod }, "F4", function(c) c:kill() end,
			{ description = "Close", group = "Client keys" }
		},
		{
			{ env.mod, env.ctrl }, "f", awful.client.floating.toggle,
			{ description = "Toggle floating", group = "Client keys" }
		},
		{
			{ env.mod, env.ctrl }, "o", function(c) c.ontop = not c.ontop end,
			{ description = "Toggle keep on top", group = "Client keys" }
		},
		{
			{ env.mod, env.ctrl }, "n", function(c) c.minimized = true end,
			{ description = "Minimize", group = "Client keys" }
		},
		{
			{ env.mod }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
			{ description = "Maximize", group = "Client keys" }
		}
	}

	self.keys.root = redflat.util.key.build(self.raw.root)
	self.keys.client = redflat.util.key.build(self.raw.client)

	-- Numkeys
	--------------------------------------------------------------------------------

	-- add real keys without description here
	for i = 1, 9 do
		self.keys.root = awful.util.table.join(
			self.keys.root,
			tag_numkey(i,    { env.mod },                     function(t) t:view_only()               end),
			tag_numkey(i,    { env.mod, env.ctrl },          function(t) awful.tag.viewtoggle(t)     end),
			client_numkey(i, { env.mod, env.shift },            function(t) client.focus:move_to_tag(t) end),
			client_numkey(i, { env.mod, env.ctrl, env.shift }, function(t) client.focus:toggle_tag(t)  end)
		)
	end

	-- make fake keys with description special for key helper widget
	local numkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

	self.fake.numkeys = {
		{
			{ env.mod }, "1..9", nil,
			{ description = "Switch to tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, env.ctrl }, "1..9", nil,
			{ description = "Toggle tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, env.shift }, "1..9", nil,
			{ description = "Move focused client to tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, env.ctrl, env.shift }, "1..9", nil,
			{ description = "Toggle focused client on tag", group = "Numeric keys", keyset = numkeys }
		},
	}

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	redflat.float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.numkeys), 2)

	-- Mouse buttons
	--------------------------------------------------------------------------------
	self.mouse.client = awful.util.table.join(
		awful.button({}, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ env.mod }, 2, awful.mouse.client.move),
		awful.button({ env.mod }, 3, awful.mouse.client.resize)
		-- awful.button({}, 8, function(c) c:kill() end)
	)

	-- Set root hotkeys
	--------------------------------------------------------------------------------
	root.keys(self.keys.root)
	root.buttons(self.mouse.root)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
