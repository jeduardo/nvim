local BUF_SIZE = 4096 -- do not read more than this

local function isPatternMatch(str, pattern)
  if str == nil or pattern == nil then
    return false
  end
  return str:match(pattern) ~= nil
end

local function is_android()
  -- Check if we're running on Android
  local handle = io.popen("getprop ro.build.version.release 2>/dev/null")
  if handle then
    local result = handle:read(BUF_SIZE)
    handle:close()
    -- If getprop returns anything, we're likely on Android
    return result ~= nil and result ~= ""
  end

  -- Alternative check: look for Android-specific paths
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

  -- Check environment variables that might indicate Android/Termux
  if os.getenv("ANDROID_DATA") or os.getenv("TERMUX_VERSION") then
    return true
  end

  return false
end

local function is_dark()
  local osname = vim.loop.os_uname().sysname

  -- Check for Android first (before general Linux check)
  if osname:match("Linux") and is_android() then
    -- Android detected - return dark theme
    return true
  end

  if osname:match("Darwin") then
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
    -- Regular Linux (non-Android) check
    local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
    if handle then
      local result = handle:read(BUF_SIZE)
      handle:close()
      return not isPatternMatch(result, "light")
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
  { "nordtheme/vim", "NLKNguyen/papercolor-theme", "AlexvZyl/nordic.nvim" },

  -- Configure LazyVim to dynamically select the colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = select_theme("PaperColor", "nord"),
    },
  },
}
