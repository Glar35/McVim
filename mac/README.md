# McVim — macOS terminal helpers

McVim is just the Neovim config. To get the *full* experience on macOS —
matching colors, transparency, and the Cmd/Option key behaviour the
keybindings rely on — you also need to set up **Kitty** and (optionally)
**Karabiner-Elements**. Those configs live here.

> macOS only. Karabiner-Elements does not exist on Windows/Linux; a port
> would use AutoHotkey or Kanata instead.

## 1. Kitty (required)

McVim's keybindings depend on Kitty's keyboard protocol plus several explicit
mappings (Cmd+C forwarding, Cmd+Left/Right → Home/End, the Option+\ leader,
`macos_option_as_alt yes`, etc.). The colorscheme also assumes Kitty's
background is `#241B36`, the same base McVim sets in Neovim — that's what makes
the editor blend seamlessly into the terminal.

```sh
# back up any existing kitty config first
mv ~/.config/kitty ~/.config/kitty.bak 2>/dev/null

mkdir -p ~/.config/kitty
cp mac/kitty/kitty.conf    ~/.config/kitty/kitty.conf
cp mac/kitty/session.conf  ~/.config/kitty/session.conf   # optional
```

`session.conf` is optional (it just opens one window in `~`). Edit its `cd`
line, or delete the `startup_session` line in `kitty.conf` to skip it.

Install the font if you don't have it:

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

## 2. Karabiner-Elements (optional)

`mac/karabiner/kitty-tab-nav.json` is a Karabiner *complex modification* that
makes **Cmd+Shift+Left/Right switch Kitty tabs** — but only while Kitty is the
frontmost app (it uses a `frontmost_application_if` condition, so it
auto-activates with Kitty and stays out of the way everywhere else).

```sh
mkdir -p ~/.config/karabiner/assets/complex_modifications
cp mac/karabiner/kitty-tab-nav.json \
   ~/.config/karabiner/assets/complex_modifications/
```

Then open **Karabiner-Elements → Complex Modifications → Add rule** and enable
"Kitty: Cmd+Shift+Arrow → tab switching".

### ⚠️ Heads up: Cmd+Shift+Arrow is contested

Three layers can all want this chord, so pick **one**:

- `kitty.conf` already binds `cmd+shift+right/left` → `next_tab`/`previous_tab`
  directly inside Kitty. **If you use this, you don't need the Karabiner rule
  at all** — it's only here for people who prefer to drive tab-nav from the OS
  layer.
- The Karabiner rule above remaps the same chord to `Cmd+] / Cmd+[`.

If tab navigation behaves oddly, that's two layers fighting over the same keys —
disable the Karabiner rule **or** remove the `cmd+shift+right/left` lines from
`kitty.conf`, not both.
