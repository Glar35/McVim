-- When focused on the explorer, the statusline normally shows nothing useful
-- (no filename). Override so the filename component reflects the file in the
-- main window even when focus is on the explorer side panel.
return {
  {
    'nvim-lualine/lualine.nvim',
    opts = function(_, opts)
      local function main_buf()
        local cur = vim.api.nvim_get_current_buf()
        if vim.bo[cur].filetype ~= 'snacks_picker_list' then return cur end
        -- Focused on explorer — find a non-explorer named buffer.
        local explorer_win = vim.api.nvim_get_current_win()
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if w ~= explorer_win then
            local b = vim.api.nvim_win_get_buf(w)
            if vim.bo[b].buftype == '' and vim.api.nvim_buf_get_name(b) ~= '' then
              return b
            end
          end
        end
        return cur
      end

      local function main_path()
        local b = main_buf()
        local name = vim.api.nvim_buf_get_name(b)
        if name == '' then return '' end
        return vim.fn.fnamemodify(name, ':~:.')
      end

      local function main_filetype_icon()
        local b = main_buf()
        local ft = vim.bo[b].filetype
        local ok, devicons = pcall(require, 'nvim-web-devicons')
        if ok then
          local icon = devicons.get_icon_by_filetype(ft, { default = true })
          return icon or ''
        end
        return ''
      end

      opts.sections = opts.sections or {}
      opts.sections.lualine_c = {
        { main_filetype_icon, padding = { left = 1, right = 0 } },
        { main_path },
      }
    end,
  },
}
