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
  packages = {}, ---@type table<string, mia.pkg>
  paths = {}, ---@type table<mia.pkg.kinds, string>
}

M.setup = function()
  M.paths = {}

  local basename = vim.fn.stdpath('config') .. '/lua/mia'
  for kind, _ in pairs(M.kinds) do
    M.paths[kind] = vim.fs.joinpath(basename, kind)
  end
end

--- Use to disable previously set up mods or to have a 'reload guard'
---@param fn function|string
M.on_reload = function(fn)
  local info = debug.getinfo(2, 'S')
  local path = info.source:match('/lua/(mia/.*)$')
  local name = path:gsub('%.lua$', ''):gsub('%/init$', ''):gsub('/', '.')
  -- local name = path:gsub('/', '.')
  local mod = package.loaded[name]
  if type(mod) ~= "table" then
    return
  end
  if type(fn) == 'string' then
    mod[fn]()
  end
  fn(mod)
end

return M
