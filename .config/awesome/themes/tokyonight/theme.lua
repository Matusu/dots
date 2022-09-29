-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')

local theme_assets = require('beautiful.theme_assets')
local xresources = require('beautiful.xresources')
local rnotification = require('ruled.notification')
local dpi = xresources.apply_dpi

local gfs = require('gears.filesystem')
local themes_path = gfs.get_themes_dir()

local layout = require('util.layout')

-- Widget imports
local create_volume_widget = require('widgets.volume')

local theme = {}

theme.color = {
  polar_night = {'#2e3440', '#3b4252', '#434c5e', '#4c566a'},
  snow_storm = {'#d8dee9', '#e5e9f0', '#eceff4'},
  frost = {'#8fbcbb', '#88c0d0', '#81a1c1', '#5e81ac'},
  femboy = {'#ffcce6', '#edaaf3', '#d4a1f3', '#be9cec', '#b798ec'},
  bg_dark = '#1f2335',
  bg = '#24283b',
  bg_highlight = '#292e42',
  terminal_black = '#414868',
  fg = '#c0caf5',
  fg_dark = '#a9b1d6',
  fg_gutter = '#3b4261',
  dark3 = '#545c7e',
  comment = '#565f89',
  dark5 = '#737aa2',
  blue0 = '#3d59a1',
  blue = '#7aa2f7',
  cyan = '#7dcfff',
  blue1 = '#2ac3de',
  blue2 = '#0db9d7',
  blue5 = '#89ddff',
  blue6 = '#B4F9F8',
  blue7 = '#394b70',
  magenta = '#bb9af7',
  magenta2 = '#ff007c',
  purple = '#9d7cd8',
  orange = '#ff9e64',
  yellow = '#e0af68',
  green = '#9ece6a',
  green1 = '#73daca',
  green2 = '#41a6b5',
  teal = '#1abc9c',
  red = '#f7768e',
  red1 = '#db4b4b'
}

theme.font = 'monospace 11'

theme.fonts = {icon = 'monospace 15', widget = theme.font}

theme.bg_normal = theme.color.bg
theme.bg_focus = theme.color.frost[4]
theme.bg_urgent = theme.color.red1
theme.bg_minimize = theme.color.polar_night[2]
theme.bg_systray = theme.bg

theme.fg_normal = theme.color.snow_storm[3]
theme.fg_focus = theme.color.snow_storm[1]
theme.fg_urgent = theme.color.orange
theme.fg_minimize = theme.color.snow_storm[1]

theme.taglist_bg_urgent = theme.orange
theme.taglist_bg_focus = theme.color.magenta
theme.taglist_fg_occupied = theme.color.magenta
theme.taglist_fg_urgent = theme.color.bg
theme.taglist_fg_empty = theme.color.polar_night[3]
theme.taglist_fg_focus = theme.color.bg
theme.taglist_font = theme.fonts.icon

theme.useless_gap = dpi(6)
theme.border_width = dpi(1)
theme.border_color_normal = theme.color.bg
theme.border_color_active = theme.color.magenta
theme.border_color_marked = '#91231c'

local taglist_square_size = dpi(2)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

-- Hotkeys
theme.hotkeys_modifiers_fg = theme.color.magenta

theme.menu_height = dpi(15)
theme.menu_width = dpi(100)

theme.icon_theme = nil

theme.spacing = {small = dpi(10), normal = dpi(15)}

rnotification.connect_signal(
  'request::rules',
  function()
    rnotification.append_rule {
      rule = {urgency = 'critical'},
      properties = {bg = '#ff0000', fg = '#ffffff'}
    }
  end
)

-- Separators
local spr = wibox.widget.textbox('     ')
local half_spr = wibox.widget.textbox('  ')
local split_spr = wibox.widget.textbox(' ')

-- Widgets {{{

local wrap_widget = function(widget)
  return layout.add_margin(
    layout.fixed_horizontal(widget),
    {
      left = theme.spacing.normal,
      right = theme.spacing.normal
    }
  )
end

-- Wifi widget
local create_wifi_widget = require('widgets.wifi')
local wifi =
  create_wifi_widget(
  {
    primary = theme.color.green1,
    wifi_disconnected = theme.color.red1,
    wifi_connecting = theme.color.polar_night[2]
  },
  {icon = theme.fonts.icon, widget = theme.fonts.widget},
  theme.spacing.small
)
local wifi_widget = wrap_widget(wifi.widget)

-- Volume widget
local volume = create_volume_widget({
  primary = theme.color.cyan,
  background = theme.color.polar_night[2],
  muted = theme.color.dark3
}, theme.fonts.icon, theme.spacing.small)
local volume_widget = layout.fixed_horizontal(layout.pad(volume.widget))
theme.update_volume = volume.update_volume

-- Keyboard layout widget
local create_keyboard_layout_widget = require('widgets.keyboard_layout')
local keyboard_layout =
  create_keyboard_layout_widget(
  {
    primary = theme.color.blue
  },
  {icon = theme.fonts.icon, widget = theme.fonts.widget},
  theme.spacing.small
)
local keyboard_layout_widget = wrap_widget(keyboard_layout.widget)

-- Battery widget
local create_battery_widget = require('widgets.battery')
local battery =
  create_battery_widget(
  {
    primary = theme.color.magenta,
    battery_empty = theme.color.red1
  },
  {icon = theme.fonts.icon, widget = theme.fonts.widget},
  theme.spacing.small
)
local battery_widget = wrap_widget(battery.widget)

-- Calendar
local calendaricon = wibox.widget.textbox(string.format(
                                              '<span color="%s" font="' ..
                                                  theme.fonts.icon ..
                                                  '"></span>',
                                              theme.color.orange))
local calendar = wibox.widget.textclock('<span font="' .. theme.fonts.widget ..
                                            '" color="' ..
                                            theme.color.orange ..
                                            '"> %-d %b %Y (%a)</span>')

-- Clock
local clockicon = wibox.widget.textbox(string.format(
                                           '<span color="%s" font="' ..
                                               theme.fonts.icon ..
                                               '"> </span>',
                                           theme.color.red))
local clock = wibox.widget.textclock('<span font="' .. theme.fonts.widget ..
                                         '" color="' ..
                                         theme.color.red ..
                                         '">%R</span>')

theme.on_screen_connect = function(s)
  -- Tags
  awful.tag({'1', '2', '3', '4', '5', '6', '7', '8', '9'}, s, awful.layout.layouts[1])

  -- Create a taglist widget
  s.mytaglist =
    awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    style = {shape = gears.shape.circle},
    widget_template = {
      {
        {
          {id = 'text_role', widget = wibox.widget.textbox},
          layout = wibox.layout.align.horizontal
        },
        left = 10,
        right = 10,
        widget = wibox.container.margin
      },
      id = 'background_role',
      widget = wibox.container.background
    },
    buttons = {
      awful.button(
        {},
        1,
        function(t)
          t:view_only()
        end
      ),
      awful.button(
        {MODKEY},
        1,
        function(t)
          if client.focus then
            client.focus:move_to_tag(t)
          end
        end
      ),
      awful.button({}, 3, awful.tag.viewtoggle),
      awful.button(
        {MODKEY},
        3,
        function(t)
          if client.focus then
            client.focus:toggle_tag(t)
          end
        end
      ),
      awful.button(
        {},
        4,
        function(t)
          awful.tag.viewprev(t.screen)
        end
      ),
      awful.button(
        {},
        5,
        function(t)
          awful.tag.viewnext(t.screen)
        end
      )
    }
  }
  -- }}}

  -- Create the wibox
  -- delete height
  s.mywibox = awful.wibar({position = 'top', screen = s})

  -- Add widgets to the wibox
  s.mywibox.widget = {
    layout = wibox.layout.align.horizontal,
    {
      -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      s.mytaglist
    },
    {
      -- Center widget
      layout = wibox.layout.align.horizontal
    },
    {
      -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      keyboard_layout_widget,
      wifi_widget,
      battery_widget,
      volume_widget,
      half_spr,
      {
        {
          layout = wibox.layout.fixed.horizontal,
          half_spr,
          clockicon,
          clock,
          half_spr
        },
        widget = wibox.container.background
      },
      half_spr,
      {
        {
          layout = wibox.layout.fixed.horizontal,
          half_spr,
          calendaricon,
          calendar,
          half_spr
        },
        widget = wibox.container.background
      },
      half_spr
    }
  }
end

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
