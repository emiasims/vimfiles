local M = {
  ---@enum mia.pkg.kinds
  kinds = {
    core = 'core',
    plugin = 'plugin',
    autoload = 'autoload',
    ftplugin = 'ftplugin',
    after = 'after', -- vimenter
  },

  aliases = {
    F = 'functional',
    ts = 'treesitter',
  },
  paths = {}, ---@type table<mia.pkg.kinds, string>
}

function M.setup()
  M.paths = {}

  local basename = vim.fn.stdpath('config') .. '/lua/mia'
  for kind, _ in pairs(M.kinds) do
    M.paths[kind] = vim.fs.joinpath(basename, kind)
  end

  for alias, mod in pairs(M.aliases) do
    M.aliases[mod] = alias
  end
end

return M
