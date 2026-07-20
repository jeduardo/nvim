local BUF_SIZE = 4096 -- do not read more than this
-- local LIGHT_THEME = "nord-light"
-- local DARK_THEME = "nord-dark"
local LIGHT_THEME = "tokyonight-day"
local DARK_THEME = "tokyonight-storm"
local THEME_POLL_INTERVAL_MS = 5000
local uv = vim.uv or vim.loop
local theme_timer

local function isPatternMatch(str, pattern)
  if str == nil or pattern == nil then
    return false
  end
  return str:match(pattern) ~= nil
end

local function is_android()
  local handle = io.popen("getprop ro.build.version.release 2>/dev/null")
  if handle then
    local result = handle:read(BUF_SIZE)
    handle:close()
    return result ~= nil and result ~= ""
  end

  local android_paths = {
    "/system/build.prop",
    "/system/bin/getprop",
    "/data/data",
  }

  for _, path in ipairs(android_paths) do
    local file = io.open(path, "r")
    if file then
      file:close()
      return true
    end
  end

  if os.getenv("ANDROID_DATA") or os.getenv("TERMUX_VERSION") then
    return true
  end

  return false
end

local function read_command(command)
  local handle = io.popen(command)
  if not handle then
    return nil
  end

  local result = handle:read(BUF_SIZE)
  handle:close()
  return result
end

local function is_dark()
  local forced = os.getenv("NVIM_THEME")
  if forced then
    local v = forced:lower()
    if v == "light" then
      return false
    else
      return true
    end
  end

  local osname = vim.loop.os_uname().sysname

  if osname:match("Linux") and is_android() then
    return true
  end

  if osname:match("Darwin") then
    local result = read_command(
      'osascript -e "tell application \\"System Events\\" to tell appearance preferences to return dark mode" 2>/dev/null'
    )
    if result then
      return isPatternMatch(result, "true")
    end
  end

  if osname:match("Linux") then
    local portal_result = read_command(
      "gdbus call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.Settings.Read org.freedesktop.appearance color-scheme 2>/dev/null"
    )
    if portal_result and portal_result ~= "" then
      return isPatternMatch(portal_result, "uint32 1")
    end

    local result = read_command("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
    if result then
      return isPatternMatch(result, "dark")
    end
  end

  return true
end

local function select_theme()
  local env_light = os.getenv("NVIM_LIGHT_THEME")
  local env_dark = os.getenv("NVIM_DARK_THEME")

  local light = env_light or LIGHT_THEME
  local dark = env_dark or DARK_THEME

  if is_dark() then
    vim.o.background = "dark"
    return dark
  end
  vim.o.background = "light"
  return light
end

local function apply_os_theme()
  local theme = select_theme()
  if vim.g.colors_name == theme then
    return
  end

  vim.cmd.colorscheme(theme)
end

local function setup_os_theme_switching()
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("os-theme-switching", { clear = true }),
    callback = function()
      apply_os_theme()

      theme_timer = theme_timer or uv.new_timer()
      if theme_timer then
        theme_timer:start(
          THEME_POLL_INTERVAL_MS,
          THEME_POLL_INTERVAL_MS,
          vim.schedule_wrap(function()
            apply_os_theme()
          end)
        )
      end
    end,
  })
end

setup_os_theme_switching()

return {
  --[[
  Nord configuration retained for reference.
  {
    "dupeiran001/nord.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      light_brightness = 0,
      on_highlights = function(highlights, _colors)
        if vim.o.background ~= "light" then
          return
        end

        local light = {
          bg = "#eceff4",
          bg_alt = "#e5e9f0",
          fg = "#2e3440",
          muted = "#3b4252",
          subtle = "#4c566a",
          blue = "#315f91",
          cyan = "#2f6f73",
          green = "#4f7337",
          red = "#a33f49",
          orange = "#9a5a3f",
          yellow = "#8a6400",
          purple = "#7d5f85",
        }

        local groups = {
          Normal = { fg = light.fg, bg = light.bg },
          NormalNC = { fg = light.fg, bg = light.bg },
          NormalFloat = { fg = light.fg, bg = light.bg_alt },
          FloatBorder = { fg = light.subtle, bg = light.bg_alt },
          Pmenu = { fg = light.fg, bg = light.bg_alt },
          PmenuSel = { fg = light.bg, bg = light.blue, bold = true },
          PmenuSbar = { bg = "#d8dee9" },
          PmenuThumb = { bg = light.subtle },
          Comment = { fg = light.muted, italic = true },
          NonText = { fg = light.subtle },
          Whitespace = { fg = light.subtle },
          LineNr = { fg = light.subtle },
          CursorLineNr = { fg = light.fg, bold = true },
          WinSeparator = { fg = light.subtle },
          Visual = { bg = "#d8dee9" },
          Search = { fg = light.fg, bg = "#ebcb8b", bold = true },
          IncSearch = { fg = light.bg, bg = light.blue, bold = true },
          Identifier = { fg = light.fg },
          Function = { fg = light.blue, bold = true },
          Keyword = { fg = light.blue, bold = true },
          Statement = { fg = light.blue, bold = true },
          Conditional = { fg = light.blue, bold = true },
          Repeat = { fg = light.blue, bold = true },
          Operator = { fg = light.muted },
          Type = { fg = light.cyan, bold = true },
          Structure = { fg = light.cyan, bold = true },
          String = { fg = light.green },
          Character = { fg = light.green },
          Constant = { fg = light.purple },
          Number = { fg = light.purple },
          Boolean = { fg = light.purple, bold = true },
          Special = { fg = light.orange },
          PreProc = { fg = light.blue },
          Include = { fg = light.blue, bold = true },
          Todo = { fg = light.yellow, bg = "#d8dee9", bold = true },
          DiagnosticError = { fg = light.red },
          DiagnosticWarn = { fg = light.yellow },
          DiagnosticInfo = { fg = light.blue },
          DiagnosticHint = { fg = light.cyan },
          DiagnosticVirtualTextError = { fg = light.red, bg = light.bg_alt },
          DiagnosticVirtualTextWarn = { fg = light.yellow, bg = light.bg_alt },
          DiagnosticVirtualTextInfo = { fg = light.blue, bg = light.bg_alt },
          DiagnosticVirtualTextHint = { fg = light.cyan, bg = light.bg_alt },
          GitSignsAdd = { fg = light.green },
          GitSignsChange = { fg = light.blue },
          GitSignsDelete = { fg = light.red },
          ["@variable"] = { fg = light.fg },
          ["@property"] = { fg = light.fg },
          ["@field"] = { fg = light.fg },
          ["@function"] = { fg = light.blue, bold = true },
          ["@function.method"] = { fg = light.blue, bold = true },
          ["@keyword"] = { fg = light.blue, bold = true },
          ["@keyword.function"] = { fg = light.blue, bold = true },
          ["@type"] = { fg = light.cyan, bold = true },
          ["@string"] = { fg = light.green },
          ["@constant"] = { fg = light.purple },
          ["@number"] = { fg = light.purple },
          ["@boolean"] = { fg = light.purple, bold = true },
          ["@comment"] = { fg = light.muted, italic = true },
        }

        for group, opts in pairs(groups) do
          highlights[group] = opts
        end
      end,
    },
  },
  { "AlexvZyl/nordic.nvim" },
  --]]

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      light_style = "day",
    },
  },
  { "NLKNguyen/papercolor-theme" },
  { "ishan9299/nvim-solarized-lua" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = select_theme(),
    },
  },
}
