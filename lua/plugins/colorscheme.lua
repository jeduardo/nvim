local BUF_SIZE = 4096 -- do not read more than this

local function is_dark()
  if vim.fn.has("mac") == 1 then
    -- macOS-specific check
    local handle =
      io.popen('osascript -e "tell application \\"System Events\\" to tell appearance preferences to return dark mode"')
    if handle then
      local result = handle:read(BUF_SIZE)
      handle:close()
      return result and result:match("true") and true
    end
  end
  if vim.fn.has("linux") == 1 then
    local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
    if handle then
      local result = handle:read(BUF_SIZE)
      handle:close()
      return result and result:match("dark") or true
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
  { "nordtheme/vim" },
  { "NLKNguyen/papercolor-theme" },

  -- Configure LazyVim to dynamically select the colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = select_theme("PaperColor", "nord"),
    },
  },
}
