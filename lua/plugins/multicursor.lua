return {
  {
    'mg979/vim-visual-multi',
    branch = 'master',
    event = 'VeryLazy',
    init = function()
      vim.g.VM_maps = {
        ['Find Under']         = '<C-d>',  -- select next occurrence of word under cursor
        ['Find Subword Under'] = '<C-d>',
        ['Select All']         = '<C-S-d>',
        ['Add Cursor Down']    = '<C-A-Down>',
        ['Add Cursor Up']      = '<C-A-Up>',
        ['Add Cursor At Pos']  = '<C-A-LeftMouse>',
      }
      vim.g.VM_theme = 'iceblue'
      vim.g.VM_silent_exit = 1
    end,
  },
}
