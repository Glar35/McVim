return {
  {
    'saghen/blink.cmp',
    opts = {
      completion = {
        -- Disable inline ghost-text preview of the selected completion
        ghost_text = { enabled = false },
      },
      keymap = {
        -- Esc: hide the completion menu if visible; otherwise fall back to normal Esc
        ['<Esc>'] = { 'hide', 'fallback' },
      },
      cmdline = {
        keymap = {
          ['<Down>'] = { 'select_next', 'fallback' },
          ['<Up>']   = { 'select_prev', 'fallback' },
          ['<CR>']   = { 'accept', 'fallback' },
        },
      },
    },
  },
}
