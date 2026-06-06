return {
  -- DAP (needed for Debug codelens via rustaceanvim — must be required before rust-analyzer starts)
  {
    'mfussenegger/nvim-dap',
    lazy = false,
    priority = 1000,
    config = function() require('dap') end,
  },

  -- Configure rustaceanvim (the LSP wrapper LazyVim's Rust extra uses)
  {
    'mrcjkb/rustaceanvim',
    dependencies = { 'mfussenegger/nvim-dap' },
    opts = function()
      local mason_path = vim.fn.stdpath('data') .. '/mason/packages/codelldb'
      local codelldb_path = mason_path .. '/extension/adapter/codelldb'
      local liblldb_path = mason_path .. '/extension/lldb/lib/liblldb.dylib'
      return {
        dap = {
          adapter = require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path),
        },
        server = {
          default_settings = {
            ['rust-analyzer'] = {
              check = {
                enable = false,
                command = 'clippy',
                extraArgs = { '--no-deps' },
              },
              cargo = { allFeatures = true },
              procMacro = { enable = true },
              diagnostics = {
                enable = true,
                experimental = { enable = true },
              },
              lens = {
                enable = true,
                run = { enable = true },
                debug = { enable = true },
                implementations = { enable = true },
                references = {
                  adt = { enable = false },
                  enumVariant = { enable = false },
                  method = { enable = false },
                  trait = { enable = false },
                },
              },
            },
          },
        },
      }
    end,
  },

  -- conform.nvim: just tell it which formatter to use for Rust.
  -- LazyVim handles format_on_save automatically — don't set it here.
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        rust = { 'rustfmt', lsp_format = 'fallback' },
      },
    },
  },
}
