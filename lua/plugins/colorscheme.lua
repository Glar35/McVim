return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      flavour = 'mocha',
      transparent_background = false,
      color_overrides = {
        mocha = {
          base = '#241B36',   -- main bg (matches kitty/wezterm)
          mantle = '#1E1729', -- slightly darker for sidebars
          crust = '#181225',
        },
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = true,
        native_lsp = { enabled = true },
        telescope = { enabled = true },
        which_key = true,
        snacks = true,
        noice = true,
      },
    },
  },
  -- Make LazyVim use catppuccin
  {
    'LazyVim/LazyVim',
    opts = { colorscheme = 'catppuccin' },
  },
}
