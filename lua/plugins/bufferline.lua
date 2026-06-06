return {
  {
    'akinsho/bufferline.nvim',
    opts = {
      highlights = {
        -- When focus is on the explorer (or any non-file window), bufferline
        -- normally dims the "active" file tab. Force it to look the same as
        -- when the file window is focused so the user can always tell which
        -- file is currently open.
        buffer_visible = { bold = true, italic = true },
        modified_visible = { bold = true, italic = true },
        duplicate_visible = { bold = true, italic = true },
        diagnostic_visible = { bold = true, italic = true },
        warning_visible = { bold = true, italic = true },
        warning_diagnostic_visible = { bold = true, italic = true },
        error_visible = { bold = true, italic = true },
        error_diagnostic_visible = { bold = true, italic = true },
        info_visible = { bold = true, italic = true },
        info_diagnostic_visible = { bold = true, italic = true },
        hint_visible = { bold = true, italic = true },
        hint_diagnostic_visible = { bold = true, italic = true },
      },
      options = {
        always_show_bufferline = false,
        -- Reserve space matching the explorer width so tabs aren't hidden
        -- behind the side panel. text='' keeps the offset borderless.
        offsets = {
          {
            filetype = 'snacks_picker_list',
            text = '',
            highlight = 'Directory',
            text_align = 'left',
            separator = true,
          },
        },
        -- Hide scratch/nofile buffers (the "weird" empty buffer LazyVim opens
        -- when the dashboard is disabled) so they don't get their own tab.
        custom_filter = function(buf)
          local bt = vim.bo[buf].buftype
          if bt ~= '' then return false end
          local name = vim.api.nvim_buf_get_name(buf)
          if name == '' then return false end
          return true
        end,
      },
    },
  },
}
