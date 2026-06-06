-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Leader key: backslash. Both plain `\` and Option+\ (Kitty sends `\`) work.
vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

-- Absolute line numbers (disable LazyVim's relativenumber default)
vim.opt.number = true
vim.opt.relativenumber = false

-- Right-click shows context menu (Inspect / Go to definition / etc.)
vim.opt.mousemodel = 'popup_setpos'

-- Allow backspace to delete across indent, line breaks, and beyond insert start
vim.opt.backspace = 'indent,eol,start,nostop'

-- Mac-style selection: Shift+arrow extends selection, typing replaces it
vim.opt.keymodel   = 'startsel,stopsel'
vim.opt.selectmode = 'mouse,key'
vim.opt.virtualedit = 'onemore'
-- Arrows wrap at line boundaries (Mac-style: Left at col 0 → end of previous line)
vim.opt.whichwrap:append('<,>,[,],h,l,b,s')
