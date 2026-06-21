-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- From https://blog.chaitanyashahare.com/posts/how-to-make-nvim-backround-transparent/
local function apply_transparent_background()
  if vim.o.background ~= "dark" then
    return
  end

  vim.cmd([[
    highlight Normal guibg=none
    highlight NonText guibg=none
    highlight Normal ctermbg=none
    highlight NonText ctermbg=none
  ]])
end

apply_transparent_background()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("transparent-background", { clear = true }),
  callback = apply_transparent_background,
})
