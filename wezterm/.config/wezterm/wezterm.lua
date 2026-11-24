local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Everforest Dark Hard palette (sainnhe/everforest)
local p = {
  bg_dim = "#1e2326",
  bg0 = "#272e33",
  bg1 = "#2e383c",
  bg2 = "#374145",
  bg3 = "#414b50",
  bg4 = "#495156",
  bg5 = "#4f5b58",
  bg_visual = "#4c3743",
  fg = "#d3c6aa",
  red = "#e67e80",
  orange = "#e69875",
  yellow = "#dbbc7f",
  green = "#a7c080",
  aqua = "#83c092",
  blue = "#7fbbb3",
  purple = "#d699b6",
  grey0 = "#7a8478",
  grey1 = "#859289",
  grey2 = "#9da9a0",
}

config.color_schemes = {
  ["Everforest Dark Hard"] = {
    foreground = p.fg,
    background = p.bg0,

    cursor_bg = p.fg,
    cursor_fg = p.bg0,
    cursor_border = p.fg,

    selection_bg = p.bg_visual,
    selection_fg = p.fg,

    scrollbar_thumb = p.bg4,
    split = p.bg3,

    ansi = { p.bg3, p.red, p.green, p.yellow, p.blue, p.purple, p.aqua, p.fg },
    brights = { p.grey1, p.red, p.green, p.yellow, p.blue, p.purple, p.aqua, p.fg },

    tab_bar = {
      background = p.bg_dim,
      inactive_tab_edge = p.bg_dim,
      active_tab = { bg_color = p.bg0, fg_color = p.green, intensity = "Bold" },
      inactive_tab = { bg_color = p.bg_dim, fg_color = p.grey1 },
      inactive_tab_hover = { bg_color = p.bg1, fg_color = p.fg },
      new_tab = { bg_color = p.bg_dim, fg_color = p.grey1 },
      new_tab_hover = { bg_color = p.bg1, fg_color = p.fg },
    },
  },
}
config.color_scheme = "Everforest Dark Hard"

-- Font
config.font_size = 14.0

-- Window
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_decorations = "RESIZE"

-- Background sedikit transparan + blur (macOS)
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- Tab bar: gaya pill bulat
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

local PILL_LEFT = "\u{e0b6}" --
local PILL_RIGHT = "\u{e0b4}" --
local FOLDER_ICON = "\u{f07b}" --
local shells = { fish = true, zsh = true, bash = true, sh = true, nu = true }

local function basename(s)
  s = s:gsub("[/\\]+$", "")
  return s:match("[^/\\]+$") or s
end

-- Nama folder dari cwd (bisa berupa objek Url atau string, tergantung versi)
local function cwd_name(cwd)
  if not cwd then
    return nil
  end
  local path = type(cwd) == "userdata" and cwd.file_path or tostring(cwd):gsub("^file://[^/]*", "")
  if not path or path == "" then
    return nil
  end
  path = path:gsub("/$", "")
  if path == wezterm.home_dir then
    return "~"
  end
  return basename(path)
end

-- Judul tab: nama program, atau nama folder kalau sedang di shell
local function tab_title(tab)
  if tab.tab_title and #tab.tab_title > 0 then
    return tab.tab_title
  end
  local pane = tab.active_pane
  local proc = basename(pane.foreground_process_name or "")
  if proc == "" or shells[proc] then
    return cwd_name(pane.current_working_dir) or pane.title
  end
  return proc
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
  local title = wezterm.truncate_right((tab.tab_index + 1) .. " " .. tab_title(tab), max_width - 4)

  if tab.is_active then
    return {
      { Background = { Color = p.bg_dim } },
      { Foreground = { Color = p.green } },
      { Text = PILL_LEFT },
      { Background = { Color = p.green } },
      { Foreground = { Color = p.bg0 } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. title .. " " },
      { Attribute = { Intensity = "Normal" } },
      { Background = { Color = p.bg_dim } },
      { Foreground = { Color = p.green } },
      { Text = PILL_RIGHT },
    }
  end

  return {
    { Background = { Color = p.bg_dim } },
    { Foreground = { Color = hover and p.fg or p.grey1 } },
    { Text = "  " .. title .. "  " },
  }
end)

-- Status kanan: folder pane aktif
wezterm.on("update-status", function(window, pane)
  window:set_left_status(wezterm.format({
    { Background = { Color = p.bg_dim } },
    { Text = " " },
  }))

  local name = cwd_name(pane:get_current_working_dir())
  if not name then
    window:set_right_status("")
    return
  end
  window:set_right_status(wezterm.format({
    { Background = { Color = p.bg_dim } },
    { Foreground = { Color = p.aqua } },
    { Text = FOLDER_ICON .. "  " },
    { Foreground = { Color = p.grey2 } },
    { Text = name .. "  " },
  }))
end)

-- Pane tidak aktif sedikit diredupkan
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

-- Option kiri = Alt (untuk shortcut fish), Option kanan tetap untuk karakter khusus
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Scrollback & performa
config.scrollback_lines = 50000
config.max_fps = 120

-- Keybindings: split & navigasi pane
local act = wezterm.action
config.keys = {
  { key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "z", mods = "CMD|SHIFT", action = act.TogglePaneZoomState },
  { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Down") },
}

return config
