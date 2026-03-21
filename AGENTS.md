Neovim config in Lua. Plugin manager: lazy.nvim. Personal utility library: `lua/mia/`.

## Commands

- `stylua .` — format all Lua files (config: `.stylua.toml`)

## Code conventions

Use `mia` wrappers, not raw vim APIs:

```lua
-- keymaps (mode via __index: .n, .nx, .t, etc.)
mia.keymap({ { '<key>', action, desc = '...' }, mode = 'n' })
mia.keymap.n({ '<key>', action, desc = '...' })

-- autocmds
mia.augroup('GroupName', {
  BufEnter = function(ev) end,
  FileType = { { 'lua', 'python' }, callback = fn },
})

-- user commands: table DSL in plugin/commands.lua
mia.command('Name', { callback = fn, nargs = 0 })
```

Plugin specs require the type annotation and prefer lazy loading:

```lua
---@type LazySpec
return { 'author/plugin', event = 'VeryLazy', opts = {} }
```

Context-sensitive keymaps use the `ctxmap` field in LazySpecs (not `keys`).
See `lua/plugins/ctxmap.lua` for examples and the handler definition.

`P(...)` and `N(...)` are global debug helpers (inspect+print, inspect+notify).

## Architecture pointers

- `mia` library entry + deferred submodule loading: `lua/mia.lua`
- `lua/mia/` is part stable utilities (`keymap`, `augroup`, `command`, `tbl`, `F`, `cache`, `line`), part organic experimentation. Use its APIs; refactoring internals requires understanding what's settled vs in-flux — ask first.
- Statusline/tabline/winbar rendering via `mia.line`: `lua/statusline.lua`, `lua/tabline.lua`, `lua/winbar.lua`
- Treesitter fold customization: `lua/fold.lua`, `fold/`, `queries/`

## Boundaries

- **Always**: use `mia.keymap` / `mia.augroup` / `mia.command` for new keymaps, autocmds, commands
- **Ask first**: adding new plugin dependencies (new files in `lua/plugins/`), refactoring `lua/mia/` internals
- **Never** edit `mia_plugins/` as config — those are standalone plugin repos; open them directly instead
- **Never** edit `lazy-lock.json` by hand — use `:Lazy update` instead
