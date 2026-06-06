return {
  {
    'folke/snacks.nvim',
    opts = {
      dashboard = { enabled = false },
      picker = {
        win = {
          input = {
            keys = {
              ['<M-w>'] = { 'close', mode = { 'i', 'n' } },
            },
          },
          list = {
            keys = {
              ['<M-w>'] = { 'close', mode = { 'n' } },
            },
          },
        },
        sources = {
          explorer = {
            jump = { close = false },
            follow_file = true,
            win = {
              list = {
                keys = {
                  -- Override the global <M-w> = close: in the explorer, M-w
                  -- closes the file in the main window, NOT the explorer.
                  ['<M-w>'] = { 'close_main_file', mode = { 'n', 'i' } },
                },
              },
            },
            actions = {
              close_main_file = function(picker)
                local explorer_win = picker.list and picker.list.win and picker.list.win.win
                local target_buf
                for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                  if w ~= explorer_win then
                    local b = vim.api.nvim_win_get_buf(w)
                    if vim.bo[b].buftype == '' and vim.api.nvim_buf_get_name(b) ~= '' then
                      target_buf = b
                      break
                    end
                  end
                end
                if not target_buf then
                  vim.notify('No file open to close', vim.log.levels.INFO); return
                end
                _G._suppress_auto_insert = true
                _G._nvim_deliberate_exit = true
                if Snacks and Snacks.bufdelete then
                  pcall(Snacks.bufdelete, { buf = target_buf })
                else
                  pcall(vim.cmd, 'bdelete ' .. target_buf)
                end
                if explorer_win and vim.api.nvim_win_is_valid(explorer_win) then
                  pcall(vim.api.nvim_set_current_win, explorer_win)
                end
                _G._suppress_auto_insert = false
                if vim.fn.mode():match('^[iIRr]') then vim.cmd('stopinsert') end
                if _G._reinstall_explorer_cr then
                  vim.defer_fn(_G._reinstall_explorer_cr, 30)
                end
              end,
              confirm = function(picker, item, action)
                if not item then return end
                local explorer_win = picker.list and picker.list.win and picker.list.win.win
                if item.dir then
                  local ok_tree, tree = pcall(require, 'snacks.explorer.tree')
                  local ok_act, acts = pcall(require, 'snacks.explorer.actions')
                  if ok_tree and ok_act then
                    tree:toggle(item.file)
                    acts.update(picker, { refresh = true })
                  end
                  return
                end
                Snacks.picker.actions.jump(picker, item, action)
                if explorer_win and vim.api.nvim_win_is_valid(explorer_win) then
                  vim.schedule(function() pcall(vim.api.nvim_set_current_win, explorer_win) end)
                  vim.defer_fn(function()
                    if vim.api.nvim_win_is_valid(explorer_win) then
                      pcall(vim.api.nvim_set_current_win, explorer_win)
                    end
                  end, 50)
                end
              end,
            },
          },
        },
      },
    },
  },
}
