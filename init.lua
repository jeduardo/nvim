-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- From https://blog.chaitanyashahare.com/posts/how-to-make-nvim-backround-transparent/
vim.cmd([[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]])
