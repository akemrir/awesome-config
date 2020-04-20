-----------------------------------------------------------------------------------------------------------------------
--                                                Rules config                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful =require("awful")
local beautiful = require("beautiful")
local redtitle = require("redflat.titlebar")
-- local naughty = require("naughty")

-- Initialize tables and vars for the module
-----------------------------------------------------------------------------------------------------------------------
local rules = {}

rules.base_properties = {
	border_width     = beautiful.border_width,
	border_color     = beautiful.border_normal,
	focus            = awful.client.focus.filter,
	raise            = true,
	size_hints_honor = false,
	screen           = awful.screen.preferred,
}

rules.floating_any = {
	class = {
		"Clipflap", "Run.py",
	},
	role = { "AlarmWindow", "pop-up", },
	type = { "dialog" }
}

rules.titlebar_exceptions = {
	class = { "Cavalcade", "Clipflap", "Steam", "Qemu-system-x86_64", "Xfce4-terminal" }
}

rules.maximized = {
	class = { "Emacs24" }
}

-- Build rule table
-----------------------------------------------------------------------------------------------------------------------
function rules:init(args)

	args = args or {}
	self.base_properties.keys = args.hotkeys.keys.client
	self.base_properties.buttons = args.hotkeys.mouse.client
	self.env = args.env or {}


	-- Build rules
	--------------------------------------------------------------------------------
	self.rules = {
		{
			rule       = {},
			properties = args.base_properties or self.base_properties
      -- callback = function(c) naughty.notify{
      --   title="new window",
      --   text = c.instance
      -- }
      -- end
		},
		{
			rule_any   = args.floating_any or self.floating_any,
			properties = { floating = true }
		},
		{
			rule_any   = self.maximized,
			callback = function(c)
				c.maximized = true
				redtitle.cut_all({ c })
				c.height = c.screen.workarea.height - 2 * c.border_width
			end
		},
		{
			rule_any   = { type = { "normal", "dialog" }},
			except_any = self.titlebar_exceptions,
			properties = { titlebars_enabled = false }
		},
		{
			rule_any   = { type = { "normal" }},
			properties = { placement = awful.placement.no_overlap + awful.placement.no_offscreen }
		},

    { rule = { class = "Gradio" },
      properties = { placement = 'centered', tag = 'music', floating = true }
    },
    { rule = { class = "Pavucontrol" },
      -- properties = { placement = 'centered', tag = 'Chat', floating = true }
      properties = { tag = 'chat', floating = false }
    },
    { rule = { class = "Sonata" },
      properties = { tag = 'music', skip_taskbar = true, placement = 'centered', floating = true }
    },
    { rule = { class = "Skype" },
      properties = { tag = 'chat', floating = false }
    },
    { rule = { class = "Pidgin", role = 'buddy_list' },
      properties = {
        x = 1892,
        y = 200,
        width = 500,
        height = 1000,
        tag = 'pid', floating = true }
    },
    { rule = { class = "Pidgin", role = 'accounts' },
      properties = { placement = 'centered', tag = 'pid', floating = true }
    },
    { rule = { class = "Pidgin", role = 'conversation' },
      properties = { placement = 'centered', tag = 'pid', floating = true }
    },
    { rule = { class = "Pidgin" },
      properties = { tag = 'pid', floating = true }
    },
    { rule = { class = "Thunderbird" },
      properties = { tag = 'mail', floating = false }
    },
    { rule = { class = "firefox" },
      properties = { tag = 'browser', floating = false }
    },
    -- { rule = { class = "firefox", instance = "Dialog" },
    --   properties = { ontop = true, floating = true, placement = 'centered' }
    -- },
        --{{{ FIREFOX DOWNLOAD
    --{ rule = { class = "Firefox",
    --           instance = "Download" },
    --  properties = { tag = 'browser',
    --                 switchtotag = true,
    --                 floating = true,
    --                 geometry = { x=20, y=40, height=220, width=420 },
    --                 --skip_taskbar = true,
    --                 border_with = 0
    --                }},
    { rule = { class = "Chromium" },
      properties = { tag = 'chr', floating = false }
    },
    { rule = { class = "discord" },
      properties = { tag = 'pid' }
    },
    { rule = { class = "Zathura" },
      properties = { floating = true }
    },
    { rule = { class = "Postman" },
      properties = { tags = { "code", "browser", "chat" } }
    },
    { rule = { class = "Zeal" },
      properties = {
        ontop = true,
        floating = true,
        border_width = 5,
        border_color = "#92C261",
        x = 768,
        y = 197,
        width = 1000,
        height = 1000
      }
    },
    { rule = { class = "xzoom" },
      properties = {
        ontop = true,
        floating = true,
        border_width = 5,
        -- border_color = "#92C261",
        -- x = 50,
        -- y = 50,
        width = 500,
        height = 500
      },
      callback = function(c)
        -- c.overwrite_class = "urxvt:dev"
        awful.placement.under_mouse(c)
        -- c.border_color = "#00ff00"
        -- awful.placement.stretch_right(c)
        -- awful.placement.maximize_vertically(c)

        -- awful.placement.right(c)

        -- awful.placement['maximize_'..axis]
        -- local axis = 'vertically'
        -- local f = awful.placement.scale
        --   + awful.placement.left
        --   + (axis and awful.placement['maximize_'..axis] or nil)
        -- f(client, {honor_workarea=true, to_percent = 0.5})
      end
    },
    -- { rule = { class = "Termite" },
    --   properties = { titlebars_enabled = false }
    -- },
    { rule = { class = "Qalculate-gtk" },
      properties = { floating = true, placement = 'centered' }
    },
    { rule = { name = "Slack Call Minipanel" },
      properties = { tag = 'chat', floating = true, ontop = true }
    },
    { rule = { class = "Slack" },
      properties = { tag = 'chat'}
    },

		-- Tags placement
		{
			rule = { instance = "Xephyr" },
			properties = { tag = self.env.theme == "ruby" and "Test" or "Free", fullscreen = true }
		},

		-- Jetbrains splash screen fix
		{
			rule_any = { class = { "jetbrains-%w+", "java-lang-Thread" } },
			callback = function(jetbrains)
				if jetbrains.skip_taskbar then jetbrains.floating = true end
			end
		}
	}


	-- Set rules
	--------------------------------------------------------------------------------
	awful.rules.rules = rules.rules
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rules
