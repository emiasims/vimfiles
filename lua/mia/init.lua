require 'mia.utils' -- reload, vim_module, and module_to_vim_module, P
require 'mia.packer' -- plugin set up
require 'mia.plugin' -- plugin settings
require 'mia.keymaps' -- plugin settings

-- vim_module allows lazy loading of submodules:
-- setlocal foldexpr=v:lua.mia.tslib.fold.queryexpr(v:lnum)
-- Without all that ugly 'require' and luaeval nonsense
return module_to_vim_module({}, 'mia')
