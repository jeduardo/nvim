local BUF_SIZE = 4096 -- do not read more than this

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

  return true
end

local function select_theme(default_light, default_dark)
  -- Check for overrides
  local env_light = os.getenv("NVIM_LIGHT_THEME")
  local env_dark = os.getenv("NVIM_DARK_THEME")

  local light = env_light or default_light
  local dark = env_dark or default_dark

  if is_dark() then
    vim.o.background = "dark"
    return dark
  end
  vim.o.background = "light"
  return light
end

return {
  { "nordtheme/vim", "NLKNguyen/papercolor-theme", "AlexvZyl/nordic.nvim", "ishan9299/nvim-solarized-lua" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = select_theme("PaperColor", "nord"),
    },
  },
}
