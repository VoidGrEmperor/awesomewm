-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local logout_popup = require("awesome-wm-widgets.logout-popup-widget.logout-popup")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir("/home/void/.config/awesome/themes/vertex/theme.lua") .. "default/theme.lua")


-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("micro") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = "librewolf"
youtube = "freetube"
suckless_terminal = "st"
ranger = "alacritty -e ranger"
vim = "alacritty -e vim"
rofi = "rofi -show drun"
dmenu = "dmenu_run -l 10 -i -nb '#1f2335' -nf '#FFD700' -sb '#ffffff' -sf '#000000' -fn 'NotoSans:bold:pixelsize=13'"
--add "-l 10" in case dmenu is shifted back to the center.
file_manager = "pcmanfm"  
email = "re.sonny.Tangram"
htop = "alacritty -e htop"
emacs = "emacs"
screenshot = "gnome-screenshot -i"
xkill = "xkill"
i3exit = "i3exit.sh"
nitrogen = "nitrogen"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,

-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    --awful.layout.suit.floating,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
tbox_separator = wibox.widget.textbox(" | ")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "???", "???", "???", "???", "???", "???", "???", "???", "???" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s}) 
    for i=1, 5 do
        local w = wibox.widget {
            first,
            second,
            third,
            spacing = i*3,
            layout  = wibox.layout.fixed.horizontal
        }
    end

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            s.mytaglist,
            tbox_separator,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            spacing = 8,
            layout = wibox.layout.fixed.horizontal,
            tbox_separator,
            cpu_widget({
            	width = 30,
            	step_spacing = 0,
            	step_width = 2,
            	color = '#434c5e'
            }),
            wibox.widget.systray(),
 --           tbox_separator,         
            batteryarc_widget({
                            show_current_level = true,
                            arc_thickness = 1,
                          }),
 --           tbox_separator,
            brightness_widget({
                        type = 'arc',
                        program = 'xbacklight',
                        step = 5,        
                    }),
 --           tbox_separator,         
            volume_widget{
                        widget_type = 'arc'
                        },
 --           tbox_separator,
            mytextclock,
 --           tbox_separator,
            logout_menu_widget{
                       font = 'Play 8',
                         onlock = function() awful.spawn.with_shell('betterlockscreen -l dimblur -- --time-str="%H:%M"') end
                    }
           
            
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
  
    awful.key({ modkey,           }, "j",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
 
    awful.key({ modkey,           }, "k",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
 
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,  }, "Right", function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}
    ),

    awful.key({ modkey,  }, "Left", function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}
    ),

    awful.key({ modkey,           }, "w", function () awful.spawn(browser) end,
              {description = "web browser", group = "launcher"}),

    awful.key({ modkey,           }, "Print", function () awful.spawn(screenshot) end,
              {description = "Gnome Screenshot", group = "launcher"}),

    awful.key({ modkey,           }, "f", function () awful.spawn(file_manager) end,
              {description = "Launch File Manager", group = "launcher"}),

    awful.key({ modkey,           }, "e", function () awful.spawn(emacs) end,
              {description = "Launch Doom Emacs", group = "launcher"}),

    awful.key({ modkey,           }, "x", function () logout_popup.launch() end,
              {description = "Show Logout Screen", group = "custom"}),

    awful.key({ modkey }, "b", function () myscreen = awful.screen.focused()
      myscreen.mywibox.visible = not myscreen.mywibox.visible end,
          {description = "toggle statusbar"}
),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard programs 
    
    --Terminal
    awful.key({ modkey, "Shift"  }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    
    --Ranger
    awful.key({ modkey,           }, "r", function () awful.spawn(ranger) end,
              {description = "open ranger", group = "launcher"}),

    --Htop
    awful.key({ modkey, }, "t", function () awful.spawn(htop) end,
              {description = "open htop", group = "launcher"}),

    --Rofi-drun
    awful.key({ modkey, "Shift" }, "d", function () awful.spawn(rofi) end,
              {description = "open rofi", group = "launcher"}),
    
    --dmenu
    awful.key({ modkey,  }, "d", function () awful.spawn(dmenu) end,
              {description = "open dmenu", group = "launcher"}),

    --Freetube
    awful.key({ modkey,           }, "y", function () awful.spawn(youtube) end,
              {description = "open Freetube", group = "launcher"}),

    --Nitrogen 
    awful.key({ modkey, "Shift" }, "i", function () awful.spawn(nitrogen) end,
              {description = "open Nitrogen", group = "launcher"}),

    --Vim launcher
    awful.key({ modkey,           }, "v", function () awful.spawn(vim) end,
              {description = "open vim", group = "launcher"}),
    
    awful.key({ modkey,           }, "m", function () awful.spawn(email) end,
              {description = "open mailspring", group = "launcher"}),

    --Kitty 
   awful.key({ modkey,  }, "Return", function () awful.spawn(suckless_terminal) end,
             {description = "open st", group = "launcher"}),
    
    --Reload Awesome
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    
    --Quit Awesome
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    --Xkill
    awful.key({ modkey,    }, "Escape", function () awful.spawn(xkill) end,
              {description = "launch Xkill", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase  factor", group = "layout"}),
    
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    
    awful.key({ modkey, "Control"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

        -- Prompt
    awful.key({ modkey, "Control"  },            "d",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

--    awful.key({ modkey }, "x",
--             function ()
--               awful.prompt.run {
--               prompt       = "Run Lua code: ",
--                textbox      = awful.screen.focused().mypromptbox.widget,
--                   exe_callback = awful.util.eval,
--                  history_path = awful.util.get_cache_dir() .. "/history_eval"
--               }
--          end,
--         {description = "lua execute prompt", group = "awesome"}),
   
-- Menubar
     awful.key({ modkey }, "p", function() menubar.show() end,
           {description = "show the menubar", group = "launcher"})


   )

clientkeys = gears.table.join(
    awful.key({ modkey, "Shift"  }, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end,
        {description = "toggle fullscreen", group = "client"}),
    
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    
    awful.key({ modkey, "Shift" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 2,         --beautiful.border_width, 
                     border_color = red,       --beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Galculator",
          "MessageWin",  -- kalarm.
         -- "mpv",
          --"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
         -- "TelegramDesktop",
          "Wpa_gui",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--Nitrogen wallpaper
awful.spawn.with_shell("nitrogen --set-zoom-fill --random /home/void/Pictures/Wallpapers")

--Gaps in windows
beautiful.useless_gap = 2 
beautiful.gap_single_client = true

--Autostart
awful.spawn.with_shell ("nm-applet")
awful.spawn.with_shell("numlockx")
awful.spawn.with_shell("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &")

-- Multimedia keys
awful.key({ }, "XF86AudioRaiseVolume", function() awful.util.spawn("amixer -D pulse sset Master '5%+'") end)
awful.key({ }, "XF86AudioLowerVolume", function() awful.util.spawn("amixer -D pulse sset Master '5%-'") end)
awful.key({ }, "XF86AudioMute", function() awful.util.spawn("amixer set Master toggle") end)

awesome.connect_signal(
    'startup',
    function(args)
        awful.util.spawn('"~/.config/awesome/autostart.sh " ')
    end
)

--This is to give border color to the focused window
client.connect_signal("focus", function(c) c.border_color = "#ffffff" end)
client.connect_signal("unfocus", function(c) c.border_color = "#FF0000" end)
