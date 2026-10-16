-- Render images inline in markdown buffers via the Kitty graphics protocol.
-- Works in Ghostty, including inside tmux (needs allow-passthrough, set in dot_tmux.conf).
-- ImageMagick (magick) converts non-PNG formats.
return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        doc = {
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
      },
    },
  },
}
