local function is_dark()
  -- Change the background based on system preference
  if vim.fn.has('mac') == 1 then
    -- macOS-specific check
    local handle =
      io.popen('osascript -e "tell application \\"System Events\\" to tell appearance preferences to return dark mode"')
    local result = handle:read('*a')
    handle:close()
    return result:match('true')
  end
  return true
end

return {
  -- Add themes
  { "nordtheme/vim" },
  { "NLKNguyen/papercolor-theme" },

  -- Configure LazyVim to dynamically select the colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        if is_dark() then
          vim.o.background = 'dark'
          return 'nord'
        end
        vim.o.background = 'light'
        return 'papercolor'
      end,
    },
  },
}
