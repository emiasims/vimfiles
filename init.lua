require 'mia.utils' -- Sets up globals: reload, P, nmodule

vim.env.CFGDIR = (vim.env.XDG_CONFIG_HOME or vim.env.HOME)..'/.config/nvim'
vim.env.DATADIR = (vim.env.XDG_DATA_HOME or vim.env.HOME)..'/.local/share/nvim'
vim.cmd('runtime settings.vim')

require 'mia.plugin'

-- nmodule allows lazy loading of submodules:
-- setlocal foldexpr=v:lua.mia.tslib.fold.queryexpr(v:lnum)
-- Without all that ugly 'require' and luaeval nonsense
mia = nmodule('mia')
