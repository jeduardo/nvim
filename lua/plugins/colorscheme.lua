local BUF_SIZE = 4096 -- do not read more than this

local function isPatternMatch(str, pattern)
  if str == nil or pattern == nil then
    return false
  end
  return str:match(pattern) ~= nil
end

local function is_dark()
  local osname = vim.loop.os_uname().sysname
  if osname:match("Mac") then
    -- macOS-specific check
    local handle =
      io.popen('osascript -e "tell application \\"System Events\\" to tell appearance preferences to return dark mode"')
    if handle then
      local result = handle:read(BUF_SIZE)
      handle:close()
      return isPatternMatch(result, "true")
    end
  end
  if osname:match("Linux") then
    local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
    if handle then
      local result = handle:read(BUF_SIZE)
      handle:close()
      return isPatternMatch(result, "dark")
    end
  end
  -- Default to returning true, assuming that a light background is an exception
  return true
end

local function select_theme(light, dark)
  if is_dark() then
    vim.o.background = "dark"
    return dark
  end
  vim.o.background = "light"
  return light
end

return {
  -- Add themes
  { "nordtheme/vim", "NLKNguyen/papercolor-theme" },

  -- Configure LazyVim to dynamically select the colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = select_theme("PaperColor", "nord"),
    },
  },
}
