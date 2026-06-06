-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ══════════════════════════════════════════════════════════
--  Mac-style keybindings for Neovim
-- ══════════════════════════════════════════════════════════
local map = vim.keymap.set
local nvi = { 'n', 'i', 'v' }
local ni  = { 'n', 'i' }

-- ── Cursor motion ────────────────────────────────────────
-- Option + ←/→  : word back / forward (Mac-style: don't cross line boundary)
local function word_motion(forward)
  return function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col('.') - 1
    if forward and col >= #line then return end           -- at end of line: stop
    if not forward and col <= 0 then return end           -- at start of line: stop
    vim.cmd('normal! ' .. (forward and 'e' or 'b'))
  end
end
map(nvi, '<M-Left>',  word_motion(false), { desc = 'Word back' })
map(nvi, '<M-Right>', word_motion(true),  { desc = 'Word forward' })

-- Cmd + ←/→  : start (non-blank) / end of line
map({ 'n', 'v' }, '<Home>', '^',        { desc = 'Start of line' })
map({ 'n', 'v' }, '<End>',  '$',        { desc = 'End of line' })
map('i',          '<Home>', '<C-o>^',   { desc = 'Start of line' })
map('i',          '<End>',  '<C-o>$',   { desc = 'End of line' })

-- Cmd + ↑/↓  : top / bottom of file
map({ 'n', 'v' }, '<D-Up>',   'gg',     { desc = 'Top of file' })
map({ 'n', 'v' }, '<D-Down>', 'G',      { desc = 'Bottom of file' })
map('i',          '<D-Up>',   '<C-o>gg',{ desc = 'Top of file' })
map('i',          '<D-Down>', '<C-o>G', { desc = 'Bottom of file' })

-- ── Selection (extend cursor motion with Shift) ──────────
-- Shift + ←/→ : extend selection one character (explicit, doesn't rely on keymodel)
local function select_char(direction)
  return function()
    local mode = vim.fn.mode()
    if mode == 'i' then
      local keys = vim.api.nvim_replace_termcodes('<Esc>v' .. direction, true, false, true)
      vim.api.nvim_feedkeys(keys, 'n', false)
    elseif mode == 'n' then
      vim.api.nvim_feedkeys('v' .. direction, 'n', false)
    else
      vim.api.nvim_feedkeys(direction, 'n', false)
    end
  end
end
map({ 'n', 'i', 'v' }, '<S-Left>',  select_char('h'), { desc = 'Select char back' })
map({ 'n', 'i', 'v' }, '<S-Right>', select_char('l'), { desc = 'Select char forward' })
-- Shift + ↑/↓ : extend selection line (handled by 'keymodel'/'selectmode' in options)
-- Cmd + Shift + ←/→ : select to line start / end
map({ 'n', 'v' }, '<S-Home>', 'v^', { desc = 'Select to line start' })
map({ 'n', 'v' }, '<S-End>',  'v$', { desc = 'Select to line end' })
map('i', '<S-Home>', '<Esc>v^', { desc = 'Select to line start' })
map('i', '<S-End>',  '<Esc>lv$', { desc = 'Select to line end' })

-- Plain arrows in visual mode: collapse selection and return to insert
map('v', '<Left>',  '<Esc>i',  { desc = 'Collapse selection' })
map('v', '<Right>', '<Esc>a',  { desc = 'Collapse selection' })
map('v', '<Up>',    '<Esc>ki', { desc = 'Collapse selection, move up' })
map('v', '<Down>',  '<Esc>ji', { desc = 'Collapse selection, move down' })

-- Backspace/Delete in visual or select mode: delete selection, return to insert
local function delete_selection()
  local m = vim.fn.mode()
  local keys = (m == 's' or m == 'S' or m == '\19')
    and vim.api.nvim_replace_termcodes('<C-g>"_d', true, false, true)
    or '"_d'
  vim.api.nvim_feedkeys(keys, 'n', false)
  vim.schedule(function()
    if vim.fn.mode() ~= 'i' then vim.cmd('startinsert') end
  end)
end
map({ 'v', 's' }, '<BS>',  delete_selection, { desc = 'Delete selection' })
map({ 'v', 's' }, '<Del>', delete_selection, { desc = 'Delete selection' })

-- Cmd + Shift + ↑/↓ → Shift+PageUp/Down from WezTerm
map({ 'n', 'v' }, '<S-PageUp>',   'vgg', { desc = 'Select to top of file' })
map({ 'n', 'v' }, '<S-PageDown>', 'vG',  { desc = 'Select to bottom of file' })
map('i',          '<S-PageUp>',   '<Esc>vgg', { desc = 'Select to top of file' })
map('i',          '<S-PageDown>', '<Esc>vG',  { desc = 'Select to bottom of file' })

-- Option + Shift + ←/→ : extend selection by word
local function select_word(forward)
  return function()
    local motion = forward and 'e' or 'b'
    local mode = vim.fn.mode()
    if mode == 'i' then
      local keys = vim.api.nvim_replace_termcodes('<Esc>v' .. motion, true, false, true)
      vim.api.nvim_feedkeys(keys, 'n', false)
    elseif mode == 'n' then
      vim.api.nvim_feedkeys('v' .. motion, 'n', false)
    else
      vim.api.nvim_feedkeys(motion, 'n', false)
    end
  end
end
-- Bind to multiple modifier-name forms in case nvim sees the key as <S-M-...> or <M-S-...>
for _, key in ipairs({ '<S-M-Left>', '<M-S-Left>' }) do
  map({ 'n', 'i', 'v' }, key, select_word(false), { desc = 'Select word back' })
end
for _, key in ipairs({ '<S-M-Right>', '<M-S-Right>' }) do
  map({ 'n', 'i', 'v' }, key, select_word(true), { desc = 'Select word forward' })
end

-- Cmd + A : select all
map(ni, '<D-a>', '<Esc>ggVG', { desc = 'Select all' })

-- ── Deletion ─────────────────────────────────────────────
-- Option + Backspace : delete previous word
map('i', '<M-BS>', '<C-w>', { desc = 'Delete word back' })
-- Cmd + Backspace : delete to start of line
map('i', '<D-BS>', '<C-u>', { desc = 'Delete to start of line' })
map('n', '<D-BS>', 'd^',    { desc = 'Delete to start of line' })
-- WezTerm sends Ctrl+U for Cmd+Backspace
map('n', '<C-u>', 'd^', { desc = 'Cmd+Backspace: delete to start of line' })

-- ── Save / undo / redo ───────────────────────────────────
map(nvi, '<D-s>',   '<Cmd>w<CR>',    { desc = 'Save' })
-- Save + run clippy (for Rust files) on Cmd+S
local function save_and_check()
  vim.cmd('write')
  if vim.bo.filetype == 'rust' then
    pcall(vim.cmd, 'RustLsp flyCheck')
  end
end
map(nvi, '<C-M-s>', save_and_check, { desc = 'Save + clippy (Cmd+S)' })
map(ni,  '<C-M-a>', '<Esc>ggVG',            { desc = 'Select all (Cmd+A)' })
map('v', '<C-M-c>', '"+y',                  { desc = 'Copy (Cmd+C)' })
map('n', '<C-M-v>', '"+p',          { desc = 'Paste (Cmd+V)' })
map('i', '<C-M-v>', '<C-r>+',       { desc = 'Paste (Cmd+V)' })
map('v', '<C-M-v>', '"_d"+P',       { desc = 'Paste over selection' })
map(ni,  '<C-M-z>', '<Cmd>undo<CR>',        { desc = 'Undo (Cmd+Z)' })
map(ni,  '<D-z>',   '<Cmd>undo<CR>', { desc = 'Undo' })
map(ni,  '<D-S-z>', '<Cmd>redo<CR>', { desc = 'Redo' })

-- ── Clipboard ────────────────────────────────────────────
-- Copy: selection in visual, current line in normal/insert
map('v', '<D-c>', '"+y<Cmd>startinsert<CR>', { desc = 'Copy selection' })
map('n', '<D-c>', '"+yy',                    { desc = 'Copy line' })
map('i', '<D-c>', '<C-o>"+yy',               { desc = 'Copy line' })
-- Cut
map('v', '<D-x>', '"+d<Cmd>startinsert<CR>', { desc = 'Cut selection' })
map('n', '<D-x>', '"+dd',                    { desc = 'Cut line' })
map('i', '<D-x>', '<C-o>"+dd',               { desc = 'Cut line' })
-- Paste
map('n', '<D-v>', '"+p',                                             { desc = 'Paste' })
map('i', '<D-v>', '<Cmd>set paste<CR><C-r>+<Cmd>set nopaste<CR>',   { desc = 'Paste' })

-- ── Find ─────────────────────────────────────────────────
map(nvi, '<D-f>', '/',                                                    { desc = 'Find in file' })
map(nvi, '<D-S-f>', '<Cmd>Telescope live_grep<CR>',                       { desc = 'Find in project' })
map(nvi, '<D-p>',   '<Cmd>Telescope find_files<CR>',                      { desc = 'Quick open file' })

-- ── Comment toggle (Cmd + /) ─────────────────────────────
map('n', '<D-/>', 'gcc',          { desc = 'Toggle comment', remap = true })
map('v', '<D-/>', 'gc',           { desc = 'Toggle comment', remap = true })
map('i', '<D-/>', '<Esc>gccgi',   { desc = 'Toggle comment', remap = true })

-- ── Line manipulation ────────────────────────────────────
-- Cmd + Shift + K : delete line
map(ni, '<D-S-k>', '<Cmd>delete<CR>',          { desc = 'Delete line' })
-- Cmd + D : duplicate line
map(ni, '<D-d>',   '<Cmd>t.<CR>',              { desc = 'Duplicate line' })
-- Option + ↑/↓ : move current line up / down (VSCode-style)
map('n', '<M-Up>',   '<Cmd>m .-2<CR>==',       { desc = 'Move line up' })
map('n', '<M-Down>', '<Cmd>m .+1<CR>==',       { desc = 'Move line down' })
map('i', '<M-Up>',   '<Esc><Cmd>m .-2<CR>==gi',{ desc = 'Move line up' })
map('i', '<M-Down>', '<Esc><Cmd>m .+1<CR>==gi',{ desc = 'Move line down' })
map('v', '<M-Up>',   ":m '<-2<CR>gv=gv",       { desc = 'Move selection up' })
map('v', '<M-Down>', ":m '>+1<CR>gv=gv",       { desc = 'Move selection down' })

-- ── Window / tab ─────────────────────────────────────────
-- Option + W : close the thing under the cursor (popup / special window / buffer / tab)
local function smart_close()
  local cur = vim.api.nvim_get_current_win()
  local cfg = vim.api.nvim_win_get_config(cur)
  -- 1) Floating window at cursor → close it
  if cfg.relative ~= '' then
    pcall(vim.api.nvim_win_close, cur, false)
    return
  end
  local bt = vim.bo.buftype
  local ft = vim.bo.filetype
  -- 2) Dashboard / start screen variants → quit nvim
  if ft == 'snacks_dashboard' or ft == 'dashboard' or ft == 'alpha'
      or ft == 'starter' or ft == 'ministarter' or ft == 'lazyvim_starter' then
    pcall(vim.cmd, 'qa')
    return
  end
  -- 2b) Single window with an empty/scratch buffer (start state) → quit nvim
  if #vim.api.nvim_tabpage_list_wins(0) == 1
      and vim.fn.tabpagenr('$') == 1
      and vim.api.nvim_buf_get_name(0) == ''
      and (bt == 'nofile' or bt == '') then
    pcall(vim.cmd, 'qa')
    return
  end
  -- 3) Snacks picker (explorer list, input prompt, preview) → close the picker
  if ft:match('^snacks_picker') then
    local got = Snacks and Snacks.picker and Snacks.picker.get and Snacks.picker.get()
    local p = type(got) == 'table' and got[1] or nil
    if p and p.close then
      pcall(function() p:close() end)
    else
      pcall(vim.cmd, 'close')
    end
    return
  end
  -- 4) Other special / sidebar windows → close window
  if bt == 'terminal' or bt == 'quickfix' or bt == 'help' or bt == 'nofile'
      or ft == 'qf' or ft == 'help' or ft == 'lspinfo' or ft == 'checkhealth'
      or ft == 'man' or ft == 'noice' then
    pcall(vim.cmd, 'close')
    return
  end
  local has_name = vim.api.nvim_buf_get_name(0) ~= ''
  local n_wins = #vim.api.nvim_tabpage_list_wins(0)
  local buf = vim.api.nvim_get_current_buf()
  local wins_with_buf = 0
  local explorer_win = nil
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    if b == buf then wins_with_buf = wins_with_buf + 1 end
    if vim.bo[b].filetype == 'snacks_picker_list' then explorer_win = w end
  end
  -- Special case: explorer is open and cursor is on a named file (only window for this buf) → delete buffer, keep window, focus explorer
  if has_name and explorer_win and explorer_win ~= cur and wins_with_buf == 1 then
    local target_buf = buf
    if Snacks and Snacks.bufdelete then
      pcall(Snacks.bufdelete, { buf = target_buf })
    else
      pcall(vim.cmd, 'bdelete! ' .. target_buf)
    end
    -- Move cursor to explorer (keep the main window alive so future file opens reuse it)
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(explorer_win) then
        pcall(vim.api.nvim_set_current_win, explorer_win)
      end
    end)
    return
  end
  -- 3) Unnamed buffer in a split → just close the split window
  if not has_name and n_wins > 1 then
    pcall(vim.cmd, 'close')
    return
  end
  -- 4) Named buffer shown in multiple windows → close only the current window
  if has_name and wins_with_buf > 1 then
    pcall(vim.cmd, 'close')
    return
  end
  -- 5) Named buffer in only one window → delete the buffer (closes its bufferline tab)
  if bt == '' and has_name then
    if pcall(require, 'snacks') and Snacks and Snacks.bufdelete then
      Snacks.bufdelete()
    else
      pcall(vim.cmd, 'bdelete')
    end
    -- After delete: do NOT auto-open the dashboard (we disabled it for a
    -- reason — opening it from here creates the broken multi-window state
    -- with stray [Scratch] buffers). Just let nvim sit on the [No Name]
    -- scratch — the explorer remains reachable via Option+\+e.
    return
  end
  -- 5) Multiple tabpages → close the current tab
  if vim.fn.tabpagenr('$') > 1 then
    pcall(vim.cmd, 'tabclose')
    return
  end
  -- 6) Only one window, nothing else to close → quit nvim
  if n_wins == 1 then
    pcall(vim.cmd, 'qa')
    return
  end
  -- 7) Catch-all — dismiss any in-progress UI
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'n', false)
end
map({ 'n', 'i', 'v', 't' }, '<M-w>', function()
  if vim.fn.mode() == 't' then
    vim.cmd('stopinsert')
  end
  smart_close()
end, { desc = 'Close popup/help/quickfix/tab' })

-- Smart Cmd+E / <leader>e : open explorer, focus if open elsewhere, close if cursor inside it
local function smart_explorer()
  local function find_explorer_win()
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(w)
      if vim.bo[buf].filetype == 'snacks_picker_list' then
        return w
      end
    end
    return nil
  end
  local cur = vim.api.nvim_get_current_win()
  local exp = find_explorer_win()
  if not exp then
    Snacks.explorer()
    return
  end
  if exp == cur then
    pcall(vim.api.nvim_win_close, exp, false)
  else
    pcall(vim.api.nvim_set_current_win, exp)
  end
end
map('n', '<leader>e', smart_explorer, { desc = 'Explorer: open / focus / close' })
map('n', '<D-e>',    smart_explorer, { desc = 'Explorer (Cmd+E)' })
map('n', '<C-M-e>',  smart_explorer, { desc = 'Explorer (Cmd+E via terminal)' })

-- Cmd + W : close current nvim split (if more than one window in this tab)
local function close_split()
  if #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.cmd('close')
  end
end
map('n', '<D-w>',   close_split, { desc = 'Close split' })
-- WezTerm sends Ctrl+Alt+w for Cmd+W
map('n', '<C-M-w>', close_split, { desc = 'Close split (Cmd+W)' })

-- Option + 1..9 : jump to buffer N in bufferline. If focus is currently on
-- the explorer (or any non-main window), move to a main window first so the
-- buffer switch happens there and doesn't clobber the sidebar.
-- Pick the N-th tab from bufferline's *display* order, then set it as the
-- buffer of a main (non-explorer) window. Keeps focus where it started.
local function go_to_buffer(n)
  return function()
    local cur = vim.api.nvim_get_current_win()
    local started_in_explorer = vim.bo.filetype == 'snacks_picker_list'
    -- Find the buffer at display position n via bufferline's element list.
    local ok, bl = pcall(require, 'bufferline')
    if not ok then return end
    local elements = bl.get_elements() and bl.get_elements().elements or {}
    if not elements[n] then return end
    local target_buf = elements[n].id
    -- Find a main window to host it.
    local main_win
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local b = vim.api.nvim_win_get_buf(w)
      if vim.bo[b].buftype == '' and vim.bo[b].filetype ~= 'snacks_picker_list' then
        main_win = w; break
      end
    end
    if not main_win then return end
    _G._suppress_auto_insert = true
    _G._nvim_deliberate_exit = true
    pcall(function()
      vim.api.nvim_win_call(main_win, function()
        vim.cmd('silent! buffer ' .. target_buf)
      end)
    end)
    if started_in_explorer and vim.api.nvim_win_is_valid(cur) then
      pcall(vim.api.nvim_set_current_win, cur)
    end
    _G._suppress_auto_insert = false
    if vim.fn.mode():match('^[iIRr]') and vim.bo.filetype == 'snacks_picker_list' then
      vim.cmd('stopinsert')
    end
  end
end
for i = 1, 9 do
  map({ 'n', 'i', 'v' }, '<M-' .. i .. '>', go_to_buffer(i), { desc = 'Go to buffer ' .. i })
end

-- Cmd+Option + Left/Right : previous / next buffer (bufferline tabs)
map({ 'n', 'i', 'v' }, '<D-M-Right>', '<Cmd>bnext<CR>',     { desc = 'Next buffer' })
map({ 'n', 'i', 'v' }, '<D-M-Left>',  '<Cmd>bprevious<CR>', { desc = 'Previous buffer' })

-- Cmd+Shift+Option + Left/Right : move current buffer left/right in bufferline
map('n', '<D-M-S-Right>', '<Cmd>BufferLineMoveNext<CR>', { desc = 'Move buffer right' })
map('n', '<D-M-S-Left>',  '<Cmd>BufferLineMovePrev<CR>', { desc = 'Move buffer left' })

-- Option+Shift+W : close current buffer tab (keeps the window open, switches to next buffer)
local function close_current_buffer()
  if Snacks and Snacks.bufdelete then
    Snacks.bufdelete()
  else
    pcall(vim.cmd, 'bdelete')
  end
end
map(nvi, '<M-S-w>', close_current_buffer, { desc = 'Close buffer tab' })
map(nvi, '<M-W>',   close_current_buffer, { desc = 'Close buffer tab' })

-- Option+Shift+1..9 : close buffer at position N in bufferline
local function close_buffer_at(n)
  local ok, elements = pcall(function()
    return require('bufferline').get_elements().elements
  end)
  if not ok or not elements or not elements[n] then return end
  local buf_id = elements[n].id
  if Snacks and Snacks.bufdelete then
    Snacks.bufdelete({ buf = buf_id })
  else
    pcall(vim.cmd, 'bdelete ' .. buf_id)
  end
end
-- Shift+number symbols (what the terminal actually sends for Option+Shift+1..9)
local shift_num_syms = { '!', '@', '#', '$', '%', '^', '&', '*', '(' }
for i, sym in ipairs(shift_num_syms) do
  map(nvi, '<M-' .. sym .. '>', function() close_buffer_at(i) end, { desc = 'Close buffer ' .. i })
  map(nvi, '<M-S-' .. i .. '>', function() close_buffer_at(i) end, { desc = 'Close buffer ' .. i })
end

-- Ctrl + Option + arrows : move cursor between splits in that direction
map(ni, '<C-M-Left>',  '<Cmd>wincmd h<CR>', { desc = 'Focus split left' })
map(ni, '<C-M-Down>',  '<Cmd>wincmd j<CR>', { desc = 'Focus split below' })
map(ni, '<C-M-Up>',    '<Cmd>wincmd k<CR>', { desc = 'Focus split above' })
map(ni, '<C-M-Right>', '<Cmd>wincmd l<CR>', { desc = 'Focus split right' })

-- Ctrl + Option + Shift + arrows : create a split in that direction
map(ni, '<C-M-S-Right>', '<Cmd>rightbelow vsplit<CR>', { desc = 'Split right' })
map(ni, '<C-M-S-Left>',  '<Cmd>leftabove vsplit<CR>',  { desc = 'Split left' })
map(ni, '<C-M-S-Down>',  '<Cmd>rightbelow split<CR>',  { desc = 'Split below' })
map(ni, '<C-M-S-Up>',    '<Cmd>leftabove split<CR>',   { desc = 'Split above' })

-- Ctrl + , : open floating terminal (also Ctrl+/ default)
map({ 'n', 'i', 't' }, '<C-,>', function() Snacks.terminal() end, { desc = 'Toggle terminal' })
map({ 'n', 'i', 't' }, '<C-/>', function() Snacks.terminal() end, { desc = 'Toggle terminal' })
-- ── Normal mode: Esc clears search and returns to insert ────────────────────
local function is_regular_buf()
  local bt = vim.bo.buftype
  local ft = vim.bo.filetype
  return bt == '' and ft ~= '' and not ft:match('^snacks') and ft ~= 'dashboard'
end
map('n', '<Esc>', function()
  vim.cmd('nohlsearch')
  if is_regular_buf() then vim.cmd('startinsert') end
end, { desc = 'Clear search / return to insert' })

-- ── Option+I: deliberate escape to normal (bypasses auto-return) ─────────────
map('i', '<M-i>', function()
  _G._nvim_deliberate_exit = true
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false
  )
end, { desc = 'Deliberate escape to normal (Option+I)' })
map('v', '<M-i>', '<Esc>', { desc = 'Escape visual → normal' })
map('c', '<M-i>', '<C-c>', { desc = 'Cancel cmdline' })
map('i', '<C-M-i>', function()
  _G._nvim_deliberate_exit = true
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false
  )
end, { desc = 'Deliberate escape to normal (Cmd+I)' })
map('v', '<C-M-i>', '<Esc>', { desc = 'Escape visual → normal' })
map('c', '<C-M-i>', '<C-c>', { desc = 'Cancel cmdline' })

-- ── Insert-mode Vim motions (stay in insert, no mode switching needed) ──────
-- strip_meta: normalize a raw getchar() byte sequence to its bare letter when
-- the Alt/Option modifier is set. Handles:
--   * ESC+<char>      (legacy 2-byte Meta encoding)
--   * CSI-u <cp>;<mod>u  (Kitty keyboard protocol)
local function strip_meta(key)
  if not key or key == '' then return nil end
  -- ESC + char (legacy 2-byte Meta encoding)
  if #key == 2 and key:byte(1) == 0x1b then return key:sub(2) end
  -- CSI-u (kitty kbd protocol)
  local cp, mod_str = key:match('^\x1b%[(%d+);(%d+)u$')
  if cp and mod_str then
    -- mod bits: 1=Shift, 2=Alt, 4=Ctrl, 8=Super. (mod-1) is the bitmask.
    if (tonumber(mod_str) - 1) % 4 >= 2 then
      return vim.fn.nr2char(tonumber(cp))
    end
  end
  -- Vim's internal <80>... encoding for special / modifier keys. Convert to
  -- printable form ("<M-e>") and extract the bare letter.
  local ok, trans = pcall(vim.fn.keytrans, key)
  if ok and trans then
    local m_char = trans:match('^<[MA]%-(.)>$')
    if m_char then return m_char end
    -- Shift+Alt → uppercase the letter (e.g. <M-S-e> → E)
    local s_char = trans:match('^<[MA]%-S%-(%a)>$') or trans:match('^<S%-[MA]%-(%a)>$')
    if s_char then return s_char:upper() end
  end
  return nil
end

-- enter_normal_then: from insert mode, deliberately exit to normal and then
-- run `fn`. Auto-insert autocmd brings us back to insert after the command.
local function enter_normal_then(fn)
  return function()
    local m = vim.fn.mode()
    if m == 'i' or m == 'ic' or m == 'ix' then
      _G._nvim_deliberate_exit = true
      vim.cmd('stopinsert')
    end
    fn()
  end
end

-- Option+\ → feed bare `\` (leader). In insert mode, leave insert first so
-- which-key's `\` trigger fires in normal mode. Fast-held Option+\+letter
-- works because wk's getchar patch strips Alt from subsequent keys while wk
-- is in its blocking input loop.
-- Normal mode: call wk's leader directly. If wk's state isn't ready for the
-- current buffer (dashboard, no tree built yet), fall back to feeding `\` so
-- nvim's native leader resolution still works.
map('n', '<M-\\>', function()
  local ok, wk_state = pcall(require, 'which-key.state')
  if ok and wk_state.start({ keys = '\\' }) ~= false then return end
  vim.api.nvim_feedkeys('\\', 'm', false)
end, { desc = 'Leader (Option+\\)' })
-- Insert mode: invoke wk's leader directly. We skip the feedkeys('\\') dance
-- because any Option+letter raw input that arrives during stopinsert would
-- fire its own insert-mode mapping before `\` reaches wk's trigger.
map('i', '<M-\\>', function()
  _G._nvim_deliberate_exit = true
  vim.cmd('stopinsert')
  vim.schedule(function()
    local ok, wk_state = pcall(require, 'which-key.state')
    if ok then wk_state.start({ keys = '\\' })
    else vim.api.nvim_feedkeys('\\', 'm', false) end
  end)
end, { desc = 'Leader from insert (Option+\\)' })

map('i', '<M-;>', '<C-o>:',  { desc = 'Open command line' })
map('i', '<M-:>', '<C-o>:',  { desc = 'Open command line' })
map('n', '<M-;>', ':',        { desc = 'Open command line' })
map('n', '<M-:>', ':',        { desc = 'Open command line' })

map('i', '<M-/>', '<C-o>/',  { desc = 'Search' })
map('n', '<M-/>', '/',        { desc = 'Search' })

map('i', '<M-n>', '<C-o>n',  { desc = 'Next search match' })
map('i', '<M-N>', '<C-o>N',  { desc = 'Prev search match' })
map('n', '<M-n>', 'n',        { desc = 'Next search match' })
map('n', '<M-N>', 'N',        { desc = 'Prev search match' })

map('i', '<M-%>', '<C-o>%',  { desc = 'Jump to matching bracket' })
map('n', '<M-%>', '%',        { desc = 'Jump to matching bracket' })

map('i', '<M-j>', '<C-o>J',  { desc = 'Join line below' })
map('i', '<M-J>', '<C-o>J',  { desc = 'Join line below' })
map('n', '<M-j>', 'J',        { desc = 'Join line below' })
map('n', '<M-J>', 'J',        { desc = 'Join line below' })

-- NOTE: <M-z> intentionally NOT mapped here — z is a which-key prefix,
-- handled by the opt_prefix loop below so Option+z+z works (centers screen).

map('i', '<M-{>', '<C-o>{',  { desc = 'Paragraph back' })
map('i', '<M-}>', '<C-o>}',  { desc = 'Paragraph forward' })
map('n', '<M-{>', '{',        { desc = 'Paragraph back' })
map('n', '<M-}>', '}',        { desc = 'Paragraph forward' })

map('i', '<M-f>', '<C-o>f',  { desc = 'Find char on line (type char after)' })
map('n', '<M-f>', 'f',        { desc = 'Find char on line (type char after)' })

-- ── Normal mode: safe defaults ───────────────────────────────────────────────
-- Backspace deletes (not move-left)
map('n', '<BS>', '"_X', { desc = 'Delete char before cursor' })

-- ── Option+letter → translate to bare letter (uniform passthrough) ──────────
-- Plain `\`, `g`, `z`, `:` work normally. Option+letter is just a translation
-- layer: <M-x> → x, so Option+\ + Option+e fires `\e` (leader explorer) by
-- letting nvim's native key handling resolve the sequence.
--
-- Skip list: letters reserved for Option-only commands (defined elsewhere).
--   i = deliberate escape (always-insert autocmd would otherwise re-enter)
--   w = smart-close window/buffer
--   r = run menu prefix
--   j = join (Option+j = J, not j-down)
local opt_skip = { i = 1, w = 1, r = 1, j = 1, I = 1, W = 1, R = 1, J = 1 }

-- Patch which-key's getchar so a held Option modifier is stripped while wk is
-- waiting for a continuation key — fast-held Option+g+d delivers `gd` as if
-- Option weren't there.
_G._wk_getchar_log = {}
vim.api.nvim_create_user_command('WkGetcharLog', function()
  if #_G._wk_getchar_log == 0 then print('(log empty)'); return end
  for _, l in ipairs(_G._wk_getchar_log) do print(l) end
end, {})
vim.api.nvim_create_user_command('WkGetcharClear', function()
  _G._wk_getchar_log = {}
end, {})

local function patch_wk_getchar()
  local ok, wk_state = pcall(require, 'which-key.state')
  if not ok then return false end
  if wk_state._opt_getchar_patched then return true end
  wk_state._opt_getchar_patched = true

  -- Patch can_start: wk's default aborts if any input is pending. With
  -- fast-held Option+\+e, <M-e> sits in typeahead when `\` fires, causing wk
  -- to bail. We override to ignore pending input that is just an Alt-modified
  -- letter (a continuation of our leader sequence) — pass for everything else
  -- so wk's safety checks (macro/visual/command-mode) still trigger.
  local orig_can_start = wk_state.can_start
  wk_state.can_start = function(mode_change)
    local old, _new = unpack(vim.split(mode_change, ':', { plain = true }))
    if old == 'c' then return false, 'command-mode' end
    local Util = require('which-key.util')
    if Util.in_macro() then return false, 'macro' end
    if mode_change:lower() == 'v:v' then return false, 'visual-block' end
    -- Skip the pending-input gate entirely — fast-held Option sequences are
    -- legitimate continuations, and any unexpected pending input will be
    -- handled by wk's normal getchar loop.
    return true
  end

  local orig_get = wk_state.getchar
  wk_state.getchar = function()
    local success, char = orig_get()
    if not success or not char or char == '' then return success, char end
    local hex = (char:gsub('.', function(c) return string.format('%02x ', c:byte()) end))
    local ok2, trans = pcall(vim.fn.keytrans, char)
    table.insert(_G._wk_getchar_log,
      string.format('hex=%s keytrans=%s', hex, ok2 and trans or '?'))
    if #_G._wk_getchar_log > 50 then table.remove(_G._wk_getchar_log, 1) end
    local s = strip_meta(char)
    if s then return true, s end
    return success, char
  end
  return true
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  once = true,
  callback = function() vim.schedule(patch_wk_getchar) end,
})
-- Fallback: also try on BufEnter once, in case VeryLazy already fired before
-- this autocmd was registered.
vim.api.nvim_create_autocmd('BufEnter', {
  once = true,
  callback = function() vim.schedule(patch_wk_getchar) end,
})

-- Open the explorer at startup so wk's per-buffer tree is warm.
vim.schedule(function()
  pcall(function() Snacks.explorer() end)
end)

do
  -- Try wk first: if `ch` is a known prefix it opens the popup; while wk's
  -- blocking getchar runs, our patch strips Alt from continuation keys so
  -- fast-held Option+ch+letter executes the full sequence. If wk returns
  -- false (no prefix), feed the bare letter so its normal action fires.
  local function opt_normal(ch)
    return function()
      local ok, wk_state = pcall(require, 'which-key.state')
      if ok and wk_state.start({ keys = ch }) ~= false then return end
      vim.api.nvim_feedkeys(ch, 'm', false)
    end
  end
  local function opt_insert(ch)
    return function()
      _G._nvim_deliberate_exit = true
      vim.cmd('stopinsert')
      vim.schedule(function()
        local ok, wk_state = pcall(require, 'which-key.state')
        if ok and wk_state.start({ keys = ch }) ~= false then return end
        vim.api.nvim_feedkeys(ch, 'm', false)
      end)
    end
  end
  for byte = string.byte('a'), string.byte('z') do
    local lo = string.char(byte)
    local hi = string.char(byte - 32)
    if not opt_skip[lo] then
      map('n', '<M-'..lo..'>', opt_normal(lo), { desc = 'Option ' .. lo })
      map('i', '<M-'..lo..'>', opt_insert(lo), { desc = 'Option ' .. lo .. ' (insert)' })
    end
    if not opt_skip[hi] then
      map('n', '<M-'..hi..'>', opt_normal(hi), { desc = 'Option ' .. hi })
      map('i', '<M-'..hi..'>', opt_insert(hi), { desc = 'Option ' .. hi .. ' (insert)' })
    end
  end
end

-- gi → goto implementation (override built-in "insert at last insert position")
map('n', 'gi', function() vim.lsp.buf.implementation() end, { desc = 'Goto implementation' })

-- ── Mouse: double-click / Ctrl+click on a symbol → goto definition (only in code buffers) ──
local function click_goto_def()
  vim.schedule(function()
    local bt = vim.bo.buftype
    -- In quickfix/loclist/help/terminal, fall back to default behavior (open location, etc.)
    if bt == 'quickfix' or bt == 'help' or bt == 'terminal' or bt == 'nofile' then
      vim.cmd('normal! \r')
      return
    end
    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then return end
    vim.lsp.buf.definition()
  end)
end
map('n', '<2-LeftMouse>', click_goto_def, { desc = 'Goto definition (double-click)' })
map('n', '<C-LeftMouse>', click_goto_def, { desc = 'Goto definition (Ctrl+click)' })

-- ── Debug (nvim-dap / rustaceanvim) ──────────────────────
map({ 'n', 'i' }, '<F5>',  function() require('dap').continue() end,          { desc = 'Debug: continue' })
map({ 'n', 'i' }, '<F9>',  function() require('dap').toggle_breakpoint() end, { desc = 'Debug: toggle breakpoint' })
map({ 'n', 'i' }, '<F10>', function() require('dap').step_over() end,         { desc = 'Debug: step over' })
map({ 'n', 'i' }, '<F11>', function() require('dap').step_into() end,         { desc = 'Debug: step into' })
map({ 'n', 'i' }, '<F12>', function() require('dap').step_out() end,          { desc = 'Debug: step out' })
map({ 'n', 'i' }, '<F8>',  function() require('dap').terminate(); require('dap').close() end, { desc = 'Debug: stop' })
map('n', '<leader>dq', function() require('dap').terminate(); require('dap').close() end, { desc = 'Debug: stop session' })
map('n', '<leader>dr', '<Cmd>RustLsp debuggables<CR>',                    { desc = 'Rust debuggables' })
map('n', '<leader>rr', '<Cmd>RustLsp runnables<CR>',                      { desc = 'Rust runnables (Run)' })
-- Execute a codelens on or above current line, filtered by title (Run / Debug)
local function run_lens_matching(pattern)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local best, best_row = nil, -1
  for _, lens in ipairs(vim.lsp.codelens.get(0)) do
    local lr = lens.range.start.line
    if lr <= row and lr > best_row and lens.command and lens.command.title:match(pattern) then
      best, best_row = lens, lr
    end
  end
  if best then
    vim.lsp.commands[best.command.command](best.command, { bufnr = 0 })
  else
    vim.notify('No matching codelens above this line', vim.log.levels.WARN)
  end
end
map({ 'n', 'i', 'v' }, '<F6>', function() run_lens_matching('[Rr]un') end,   { desc = 'Codelens: Run' })
map({ 'n', 'i', 'v' }, '<F7>', function() run_lens_matching('[Dd]ebug') end, { desc = 'Codelens: Debug' })
map('n', '<leader>cl', function() vim.lsp.codelens.run() end,  { desc = 'Run codelens (picker)' })

-- ── Run menu (Option+r) + Ctrl+Enter (run thing under cursor) ─────────────────
local function shell_in_term(cmd)
  if Snacks and Snacks.terminal then
    Snacks.terminal(cmd, {
      interactive = false,
      win = { position = 'bottom', height = 0.3, border = 'rounded' },
    })
  else
    vim.cmd('botright split | resize 15 | terminal ' .. cmd)
  end
end

local function dispatch(kind, extra)
  extra = extra or ''
  local ft = vim.bo.filetype
  local file = vim.fn.shellescape(vim.fn.expand('%'))
  local function append(cmd) return extra == '' and cmd or (cmd .. ' ' .. extra) end

  -- Rust: cargo for project-level run/test/build/check (works regardless of
  -- cursor position); rustaceanvim for debug picker.
  if ft == 'rust' then
    if kind == 'run'   then shell_in_term(append('cargo run' .. (extra == '' and '' or ' --'))); return end
    if kind == 'test'  then shell_in_term(append('cargo test'));    return end
    if kind == 'build' then shell_in_term(append('cargo build'));   return end
    if kind == 'check'  then shell_in_term(append('cargo check'));   return end
    if kind == 'clippy' then shell_in_term(append('cargo clippy'));  return end
    if kind == 'debug' then
      if extra == '' then vim.cmd('RustLsp debuggables')
      else shell_in_term(append('cargo run --')) end
      return
    end
  end

  -- Debug: hand off to nvim-dap if available
  if kind == 'debug' then
    local ok, dap = pcall(require, 'dap')
    if ok then dap.continue() else vim.notify('No debugger for ' .. ft, vim.log.levels.WARN) end
    return
  end

  -- C / C++: single-file compile to /tmp/<name>.out; if a Makefile is next to
  -- the source, prefer `make`. .h files compile as their language (best-effort).
  if ft == 'c' or ft == 'cpp' then
    local compiler = (ft == 'cpp') and 'g++' or 'gcc'
    local std = (ft == 'cpp') and '-std=c++17' or '-std=c11'
    local out = '/tmp/' .. vim.fn.expand('%:t:r') .. '.out'
    local has_makefile = vim.fn.filereadable(vim.fn.getcwd() .. '/Makefile') == 1
    if kind == 'check' then
      shell_in_term(append(compiler .. ' ' .. std .. ' -fsyntax-only ' .. file)); return
    end
    if kind == 'clippy' then
      shell_in_term(append('clang-tidy ' .. file .. ' --')); return
    end
    if kind == 'build' then
      if has_makefile then shell_in_term(append('make'))
      else shell_in_term(append(compiler .. ' ' .. std .. ' -Wall -O2 ' .. file .. ' -o ' .. out)) end
      return
    end
    if kind == 'run' then
      local build = has_makefile and 'make' or
        (compiler .. ' ' .. std .. ' -Wall -O2 ' .. file .. ' -o ' .. out)
      local runner = has_makefile and './a.out' or out
      shell_in_term(build .. ' && ' .. runner .. (extra == '' and '' or ' ' .. extra)); return
    end
    if kind == 'test' then
      shell_in_term(append('ctest --output-on-failure')); return
    end
  end

  -- Python
  if ft == 'python' then
    if kind == 'run'    then shell_in_term(append('python '          .. file)); return end
    if kind == 'test'   then shell_in_term(append('pytest '          .. file)); return end
    if kind == 'check'  then shell_in_term(append('python -m py_compile ' .. file)); return end
    if kind == 'clippy' then
      -- Prefer ruff (fast), fall back to pylint.
      if vim.fn.executable('ruff') == 1 then shell_in_term(append('ruff check ' .. file))
      else shell_in_term(append('pylint ' .. file)) end
      return
    end
    if kind == 'build' then
      vim.notify('Python has no build step', vim.log.levels.INFO); return
    end
  end

  local table_by_ft = {
    go         = { run = 'go run '   .. file, test = 'go test ./...',   build = 'go build',
                   check = 'go vet ./...', clippy = 'staticcheck ./...' },
    javascript = { run = 'node '     .. file, test = 'npm test',        build = nil,
                   check = 'node --check ' .. file, clippy = 'eslint ' .. file },
    typescript = { run = 'ts-node '  .. file, test = 'npm test',        build = 'tsc',
                   check = 'tsc --noEmit', clippy = 'eslint ' .. file },
    lua        = { run = 'lua '      .. file, test = nil,               build = nil,
                   check = 'luac -p ' .. file, clippy = 'luacheck ' .. file },
    sh         = { run = 'bash '     .. file, test = nil,               build = nil,
                   check = 'bash -n ' .. file, clippy = 'shellcheck ' .. file },
  }
  local r = table_by_ft[ft]
  local cmd = r and r[kind]
  if not cmd then
    vim.notify(('No %s command for filetype %q'):format(kind, ft), vim.log.levels.WARN)
    return
  end
  shell_in_term(append(cmd))
end

-- Prompt for extra flags/args, then run.
local function dispatch_with_args(kind)
  vim.ui.input({ prompt = kind:sub(1,1):upper() .. kind:sub(2) .. ' args: ' }, function(input)
    if input == nil then return end
    dispatch(kind, input)
  end)
end

-- Sub-keys under Option+r — which-key auto-detects <M-r> as a prefix and pops up
map({ 'n', 'i' }, '<M-r>r', function() dispatch('run')   end, { desc = 'Run project/file' })
map({ 'n', 'i' }, '<M-r>d', function() dispatch('debug') end, { desc = 'Debug' })
map({ 'n', 'i' }, '<M-r>t', function() dispatch('test')  end, { desc = 'Run tests' })
map({ 'n', 'i' }, '<M-r>b', function() dispatch('build') end, { desc = 'Build' })
map({ 'n', 'i' }, '<M-r>c', function() dispatch('check')  end, { desc = 'Check (cargo check)' })
map({ 'n', 'i' }, '<M-r>C', function() dispatch('clippy') end, { desc = 'Clippy' })
map('n', 'rc', function() dispatch('check')  end, { desc = 'Check (cargo check)' })
map('n', 'rC', function() dispatch('clippy') end, { desc = 'Clippy' })

-- Plain `r` in normal mode is repurposed as the run-menu prefix (replacing
-- vim's built-in replace-char). wk auto-detects `r` as a prefix from these
-- sub-mappings and shows the popup on press.
map('n', 'rr', function() dispatch('run')   end, { desc = 'Run project/file' })
map('n', 'rd', function() dispatch('debug') end, { desc = 'Debug' })
map('n', 'rt', function() dispatch('test')  end, { desc = 'Run tests' })
map('n', 'rb', function() dispatch('build') end, { desc = 'Build' })

-- Capital variants: prompt for extra flags/args before running.
map({ 'n', 'i' }, '<M-r>R', function() dispatch_with_args('run')   end, { desc = 'Run (with args)' })
map({ 'n', 'i' }, '<M-r>D', function() dispatch_with_args('debug') end, { desc = 'Debug (with args)' })
map({ 'n', 'i' }, '<M-r>T', function() dispatch_with_args('test')  end, { desc = 'Test (with args)' })
map({ 'n', 'i' }, '<M-r>B', function() dispatch_with_args('build') end, { desc = 'Build (with args)' })
map('n', 'rR', function() dispatch_with_args('run')   end, { desc = 'Run (with args)' })
map('n', 'rD', function() dispatch_with_args('debug') end, { desc = 'Debug (with args)' })
map('n', 'rT', function() dispatch_with_args('test')  end, { desc = 'Test (with args)' })
map('n', 'rB', function() dispatch_with_args('build') end, { desc = 'Build (with args)' })

-- `rs` / Option+r+s : run the SPECIFIC thing under the cursor (test fn, main,
-- etc.) automatically — no picker.
local function run_specific()
  local ft = vim.bo.filetype
  if ft == 'rust' then vim.cmd('RustLsp run'); return end
  -- Fallback: nearest codelens "Run" above cursor; if none, file's run cmd.
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local best, best_row = nil, -1
  for _, lens in ipairs(vim.lsp.codelens.get(0)) do
    local lr = lens.range.start.line
    if lr <= row and lr > best_row and lens.command
        and lens.command.title:lower():match('run') then
      best, best_row = lens, lr
    end
  end
  if best then vim.lsp.commands[best.command.command](best.command, { bufnr = 0 }); return end
  dispatch('run')
end
-- `rS` / Option+r+S : show the runnables PICKER (all candidates).
local function run_specific_picker()
  local ft = vim.bo.filetype
  if ft == 'rust' then vim.cmd('RustLsp runnables'); return end
  vim.notify('No runnables picker for filetype ' .. ft, vim.log.levels.WARN)
end
map({ 'n', 'i' }, '<M-r>s', run_specific, { desc = 'Run specific (under cursor)' })
map({ 'n', 'i' }, '<M-r>S', run_specific_picker, { desc = 'Run specific (picker)' })
map('n', 'rs', run_specific, { desc = 'Run specific (under cursor)' })
map('n', 'rS', run_specific_picker, { desc = 'Run specific (picker)' })

-- Option+r in insert mode: exit insert and open wk's popup at the <M-r>
-- prefix directly. Avoid feedkeys('<M-r>') which would either re-fire this
-- mapping (with remap) or get inserted as literal `r` (without remap).
map('i', '<M-r>', function()
  _G._nvim_deliberate_exit = true
  vim.cmd('stopinsert')
  vim.schedule(function()
    pcall(function()
      require('which-key').show({ keys = '<M-r>', mode = 'n' })
    end)
  end)
end, { desc = 'Run menu (Option+r)' })

-- Ctrl+Enter: run the function/test under cursor (codelens nearest above)
local function run_under_cursor()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local best, best_row = nil, -1
  for _, lens in ipairs(vim.lsp.codelens.get(0)) do
    local lr = lens.range.start.line
    if lr <= row and lr > best_row and lens.command
        and lens.command.title:lower():match('run') then
      best, best_row = lens, lr
    end
  end
  if best then
    vim.lsp.commands[best.command.command](best.command, { bufnr = 0 })
    return
  end
  dispatch('run')
end
map({ 'n', 'i' }, '<C-CR>',    run_under_cursor, { desc = 'Run under cursor' })
map({ 'n', 'i' }, '<C-Enter>', run_under_cursor, { desc = 'Run under cursor' })

