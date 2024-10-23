local function is_dark()
  if vim.fn.has("mac") == 1 then
    -- macOS-specific check
    local handle =
      io.popen('osascript -e "tell application \\"System Events\\" to tell appearance preferences to return dark mode"')
    local result = handle:read("*a")
    handle:close()
    return result:match("true")
  end
  if vim.fn.has("linux") == 1 then
    local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
    local result = handle:read("*a")
    handle:close()
    return result:match("dark")
  end
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
