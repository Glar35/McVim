return {
  -- nvim-notify (legacy notification UI)
  {
    'rcarriga/nvim-notify',
    opts = {
      timeout = 10000,
      max_width = 100,
      stages = 'fade',
    },
  },

  -- snacks.nvim (LazyVim's newer notifier — used by default in recent LazyVim)
  {
    'folke/snacks.nvim',
    opts = {
      notifier = {
        enabled = true,
        timeout = 10000,   -- 10 seconds before notifications fade
        width = { min = 40, max = 0.5 },
        height = { min = 1, max = 0.5 },
        margin = { top = 0, right = 1, bottom = 0 },
        padding = true,
        sort = { 'level', 'added' },
        style = 'compact',
      },
    },
  },

  -- noice.nvim (replaces vim's cmdline + messages UI)
  {
    'folke/noice.nvim',
    opts = function(_, opts)
      opts.messages = opts.messages or {}
      opts.messages.view_search = false
      opts.notify = opts.notify or {}
      opts.notify.enabled = true
      return opts
    end,
  },
}
