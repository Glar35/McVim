# McVim

> **Disclaimer:** This repo is AI-generated (with [Opus 3.8](https://www.anthropic.com/claude)).

McVim is a Neovim configuration built on top of LazyVim that gives you the keybindings you already know from every other app on your Mac — Cmd+S to save, Cmd+C/V to copy/paste, Cmd+F to find, Cmd+Z to undo, arrow keys for selection with Shift, and so on. Vim's modal power is still there, just under Option (Alt): Option+letter triggers the equivalent Vim motion or prefix, and Option+\ is the leader. It starts you in insert mode and stays there, so typing feels like any normal editor while every Vim trick remains one Option-press away.

## Features

- **OS-standard shortcuts** — Cmd+S save, Cmd+C/V/X clipboard, Cmd+F find, Cmd+Z/Shift+Z undo/redo, Shift+arrows for selection, Cmd+A select all.
- **Always-insert mode** — McVim drops you into insert mode and keeps you there, so the editor behaves like TextEdit or VS Code by default.
- **Option as the modal key** — Option+\ is the leader. Option+letter sends the bare letter to Vim, so motions like `w`, `b`, `dd`, `yy`, `gg`, `G`, etc. work directly from insert mode without leaving it.
- **Snacks explorer side panel** — file tree mounted as a persistent left-side panel, integrated with the rest of LazyVim.
- **Language-aware run menu** — press `r` (or Option+r from insert mode) to get a popup with run / debug / test / build / check / clippy actions wired up per language. Supports Rust, C/C++, Python, Go, JavaScript/TypeScript, Lua, and shell. Includes an optional args prompt and a "run-specific-under-cursor" mode for the test/function near your cursor.
- **Fast Option+\ + letter leader sequences** — the usual LazyVim which-key menus, just under Option+\.

## Install

```sh
mv ~/.config/nvim ~/.config/nvim.bak  # back up your existing config
git clone https://github.com/Glar35/McVim ~/.config/nvim
nvim  # LazyVim will bootstrap on first launch
```

## Recommended terminal

The keybindings rely on [Kitty](https://sw.kovidgoyal.net/kitty/)'s keyboard protocol so Option+letter and Cmd-combos reach Neovim cleanly. McVim also needs one explicit Kitty mapping so Option+\ (the leader) is delivered as a literal backslash:

```conf
# ~/.config/kitty/kitty.conf
map alt+backslash send_text all \\
```

Other terminals may work but are untested. Ports to other terminals / Windows are planned.

## Credit / license

Built on top of [LazyVim](https://github.com/LazyVim/LazyVim) (MIT). McVim is also MIT-licensed — see [LICENSE](LICENSE).

Generated with [Claude Code](https://claude.com/claude-code) — see the note at the top of this README.
