-- Autocmds are automatically loaded on the VeryLazy event


-- Always show diagnostics, including during insert mode
local function diag_config()
  vim.diagnostic.config({
    update_in_insert = true,
    virtual_text = true,
    underline = true,
    signs = true,
  })
end
diag_config()
vim.api.nvim_create_autocmd({ 'User', 'BufEnter', 'LspAttach' }, {
  pattern = { 'VeryLazy', '*' },
  callback = diag_config,
})

-- Never start in readonly mode for normal files
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufReadPost' }, {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype == '' and vim.bo[buf].modifiable then
      vim.bo[buf].readonly = false
    end
  end,
})

-- ── Always insert mode: enter insert when landing on a regular buffer ────────
local function is_regular_buf(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  local bt = vim.bo[buf].buftype
  local ft = vim.bo[buf].filetype
  -- Never auto-insert into a non-modifiable buffer (explorer, help, etc.).
  if not vim.bo[buf].modifiable then return false end
  return bt == '' and ft ~= '' and not ft:match('^snacks') and ft ~= 'dashboard'
end

-- Enter insert when landing on a regular buffer. Skip when
-- `_G._suppress_auto_insert` is set (used by the explorer Enter-to-open path
-- so opening a file doesn't briefly enter insert mode on the explorer).
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  callback = function(args)
    if _G._suppress_auto_insert then return end
    if is_regular_buf(args.buf) and vim.fn.mode() ~= 'i' then
      vim.cmd('startinsert')
    end
  end,
})

-- Return to insert after any unintentional exit (Esc, accidental C-c, etc.)
-- <C-o> also fires InsertLeave but mode will be 'niI' not 'n', so the check below is safe
_G._nvim_deliberate_exit = false
vim.api.nvim_create_autocmd('InsertLeave', {
  callback = function()
    if _G._nvim_deliberate_exit then
      _G._nvim_deliberate_exit = false
      return
    end
    if is_regular_buf() then
      vim.schedule(function()
        if vim.fn.mode() == 'n' then vim.cmd('startinsert') end
      end)
    end
  end,
})

-- ── Auto-save: write the buffer at natural pauses ──
local save_group = vim.api.nvim_create_augroup('auto_save', { clear = true })

local function maybe_save()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= '' then return end
  if not vim.bo[buf].modifiable then return end
  if vim.api.nvim_buf_get_name(buf) == '' then return end
  if not vim.bo[buf].modified then return end
  -- noautocmd skips BufWritePre (where format-on-save runs) so auto-save
  -- never reformats the file mid-edit. Manual save (Cmd+S → :write) still
  -- triggers BufWritePre and formats.
  pcall(vim.cmd, 'noautocmd write')
end

local function deferred_save()
  vim.defer_fn(maybe_save, 100)
end

-- Save only when the user pauses meaningfully (leaves insert, focus, or the
-- buffer) — never on every keystroke, since format-on-save would then collapse
-- a freshly typed blank line before the user gets to write anything in it.
vim.api.nvim_create_autocmd(
  { 'InsertLeave', 'FocusLost', 'BufLeave' },
  { group = save_group, callback = deferred_save }
)

-- Codelens display intentionally suppressed — use Option+r for the run popup
-- instead of the inline "▶︎ Run | Debug" virtual text.
vim.lsp.codelens.display = function() end
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  callback = function(args)
    pcall(vim.lsp.codelens.clear, nil, args.buf)
  end,
})

-- ── Bufferline: always show the tab bar while the explorer is open ──
local function explorer_is_open()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    if vim.bo[b].filetype == 'snacks_picker_list' then return true end
  end
  return false
end
local function count_named_buffers()
  local n = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
        and vim.bo[b].buftype == '' and vim.api.nvim_buf_get_name(b) ~= '' then
      n = n + 1
    end
  end
  return n
end
local function refresh_showtabline()
  if explorer_is_open() then
    vim.opt.showtabline = 2
  elseif count_named_buffers() >= 2 then
    vim.opt.showtabline = 2
  else
    vim.opt.showtabline = 0
  end
end
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufWinLeave', 'WinNew', 'WinClosed', 'TabEnter', 'BufAdd', 'BufDelete' }, {
  callback = function() vim.schedule(refresh_showtabline) end,
})

-- Ensure all loaded named regular buffers stay buflisted=true so they remain
-- visible in the bufferline (some operations silently unlist them).
vim.api.nvim_create_autocmd({ 'BufNew', 'BufAdd', 'BufWinEnter', 'BufReadPost' }, {
  callback = function(args)
    if vim.api.nvim_buf_is_loaded(args.buf)
        and vim.bo[args.buf].buftype == ''
        and vim.api.nvim_buf_get_name(args.buf) ~= '' then
      vim.bo[args.buf].buflisted = true
    end
  end,
})

-- Safety net: if focus is ever on the (nomodifiable) explorer buffer in insert
-- mode, drop to normal — defeats any race where the always-insert autocmd
-- ran before our suppression flag was active.
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'ModeChanged' }, {
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'snacks_picker_list' and vim.fn.mode():match('^[iIRr]') then
      _G._nvim_deliberate_exit = true
      vim.cmd('stopinsert')
    end
  end,
})

-- ── Snacks explorer: double-click opens file in a new tab; Option+W closes the explorer ──
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'snacks_picker_list',
  callback = function(args)
    vim.keymap.set('n', '<2-LeftMouse>', function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-t>', true, false, true), 'm', false)
    end, { buffer = args.buf, desc = 'Explorer: open in new tab' })
    -- <M-w> in the explorer is handled via the picker action `close_main_file`
    -- registered in plugins/snacks.lua (snacks's own <M-w> at picker level
    -- would otherwise override anything we install here).

    -- <CR> in the explorer: open file in any non-explorer window without
    -- shifting focus. Folders use the picker's default confirm (expand/
    -- collapse). Re-installed on every BufEnter/WinEnter and via the
    -- exported _G._reinstall_explorer_cr hook so the mapping survives
    -- picker resets.
    local function install_cr()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end
      vim.keymap.set('n', '<CR>', function()
        local got = Snacks and Snacks.picker and Snacks.picker.get and Snacks.picker.get()
        local picker = type(got) == 'table' and got[1] or nil
        if not picker or not picker.current then return end
        local item = picker:current()
        if not item then return end
        if item.dir then
          pcall(function() picker:action('confirm') end)
          return
        end
        local explorer_win = vim.api.nvim_get_current_win()
        local target
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if w ~= explorer_win then
            local b = vim.api.nvim_win_get_buf(w)
            if vim.bo[b].buftype == '' then target = w; break end
          end
        end
        if not target then
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if w ~= explorer_win then target = w; break end
          end
        end
        _G._suppress_auto_insert = true
        _G._nvim_deliberate_exit = true
        if target then
          pcall(function()
            vim.api.nvim_win_call(target, function()
              vim.cmd('silent! edit ' .. vim.fn.fnameescape(item.file))
            end)
          end)
        else
          local cur = vim.api.nvim_get_current_win()
          vim.cmd('rightbelow vsplit ' .. vim.fn.fnameescape(item.file))
          pcall(vim.api.nvim_set_current_win, cur)
        end
        _G._suppress_auto_insert = false
        if vim.fn.mode():match('^[iIRr]') then vim.cmd('stopinsert') end
      end, { buffer = args.buf, nowait = true, desc = 'Explorer: open file (keep focus)' })
    end
    install_cr()
    vim.defer_fn(install_cr, 30)
    vim.defer_fn(install_cr, 120)
    vim.defer_fn(install_cr, 300)
    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'CursorMoved' }, {
      buffer = args.buf,
      callback = install_cr,
    })
    _G._reinstall_explorer_cr = install_cr
  end,
})

-- ── Custom right-click menu: only contextually relevant items ──
pcall(vim.api.nvim_clear_autocmds, { group = 'nvim.popupmenu', event = 'MenuPopup' })

local function feedkeys(keys)
  return function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'm', false)
  end
end

vim.api.nvim_create_autocmd('MenuPopup', {
  callback = function()
    pcall(vim.cmd, 'aunmenu PopUp')

    -- Snacks explorer: show file operations
    if vim.bo.filetype == 'snacks_picker_list' then
      _G._popup_explorer = {
        new      = feedkeys('a'),
        delete   = feedkeys('d'),
        rename   = feedkeys('r'),
        cut      = feedkeys('m'),
        copy     = feedkeys('c'),
        paste    = feedkeys('p'),
        yank     = feedkeys('y'),
        open     = feedkeys('<CR>'),
      }
      vim.cmd([[
        anoremenu PopUp.Open               <Cmd>lua _G._popup_explorer.open()<CR>
        anoremenu PopUp.-1-                <Nop>
        anoremenu PopUp.New\ file/dir      <Cmd>lua _G._popup_explorer.new()<CR>
        anoremenu PopUp.Rename             <Cmd>lua _G._popup_explorer.rename()<CR>
        anoremenu PopUp.Delete             <Cmd>lua _G._popup_explorer.delete()<CR>
        anoremenu PopUp.-2-                <Nop>
        anoremenu PopUp.Cut\ (move)        <Cmd>lua _G._popup_explorer.cut()<CR>
        anoremenu PopUp.Copy               <Cmd>lua _G._popup_explorer.copy()<CR>
        anoremenu PopUp.Paste\ here        <Cmd>lua _G._popup_explorer.paste()<CR>
        anoremenu PopUp.Yank\ path         <Cmd>lua _G._popup_explorer.yank()<CR>
      ]])
      return
    end


    local has_word = vim.fn.expand('<cword>') ~= ''
    local mode = vim.fn.mode()
    local in_visual = mode:match('[vVsS\22\19]') ~= nil
    local clients = vim.lsp.get_clients({ bufnr = 0 })

    local function any(method)
      for _, c in ipairs(clients) do
        if c:supports_method(method) then return true end
      end
      return false
    end

    local entries = {}
    if has_word and any('textDocument/hover') then
      table.insert(entries, [[anoremenu PopUp.Hover\ docs           <Cmd>lua vim.lsp.buf.hover()<CR>]])
    end
    if has_word and any('textDocument/definition') then
      table.insert(entries, [[anoremenu PopUp.Go\ to\ definition    <Cmd>lua vim.lsp.buf.definition()<CR>]])
    end
    if has_word and any('textDocument/declaration') then
      table.insert(entries, [[anoremenu PopUp.Go\ to\ declaration   <Cmd>lua vim.lsp.buf.declaration()<CR>]])
    end
    if has_word and any('textDocument/typeDefinition') then
      table.insert(entries, [[anoremenu PopUp.Go\ to\ type\ def     <Cmd>lua vim.lsp.buf.type_definition()<CR>]])
    end
    if has_word and any('textDocument/references') then
      table.insert(entries, [[anoremenu PopUp.Find\ references      <Cmd>lua vim.lsp.buf.references()<CR>]])
    end
    if has_word and any('textDocument/implementation') then
      table.insert(entries, [[anoremenu PopUp.Find\ implementations <Cmd>lua vim.lsp.buf.implementation()<CR>]])
    end
    if has_word and any('textDocument/rename') then
      table.insert(entries, [[anoremenu PopUp.Rename                <Cmd>lua vim.lsp.buf.rename()<CR>]])
    end
    if has_word and any('textDocument/codeAction') then
      table.insert(entries, [[anoremenu PopUp.Code\ action          <Cmd>lua vim.lsp.buf.code_action()<CR>]])
    end

    local has_clipboard = vim.fn.getreg('+') ~= ''
    if #entries > 0 and (in_visual or has_clipboard) then
      table.insert(entries, [[anoremenu PopUp.-1-                   <Nop>]])
    end
    if in_visual then
      table.insert(entries, [[vnoremenu PopUp.Copy                  "+y]])
      table.insert(entries, [[vnoremenu PopUp.Cut                   "+d]])
    end
    if has_clipboard then
      table.insert(entries, [[anoremenu PopUp.Paste                 "+p]])
    end

    for _, e in ipairs(entries) do
      vim.cmd(e)
    end
  end,
})

-- ── Fix upstream rustaceanvim bug in rust-analyzer.runSingle (runnables[1] → ra_runnables[1]) ──
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  once = true,
  callback = function()
    vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
      local runnables = require('rustaceanvim.runnables')
      local cached_commands = require('rustaceanvim.cached_commands')
      local ra_runnables = command.arguments
      local runnable = ra_runnables[1]
      local cargoRunnable = runnables.as_cargo_runnable(runnable)
      if cargoRunnable then
        local cargo_args = cargoRunnable.args.cargoArgs
        if #cargo_args > 0 and vim.startswith(cargo_args[1], 'test') then
          cached_commands.set_last_testable(1, ra_runnables)
        end
      end
      cached_commands.set_last_runnable(1, ra_runnables)
      runnables.run_command(1, ra_runnables)
    end
  end,
})

-- Codelens display intentionally disabled — use Option+r for the run popup
-- instead of the inline "▶︎ Run (F6) | Debug (F7)" virtual text.
vim.lsp.codelens.display = function() end
