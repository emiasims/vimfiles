local M = {}

local function _find(kind, glob, one)
  glob = vim.fs.joinpath('*', M._fprefix, kind, glob or '*')
  local files = vim.api.nvim_get_runtime_file(glob, not one)

  local plugs = {}
  for _, file in ipairs(files) do
    local name = file:match('/([^/]+)%.lua$')
    plugs[name] = ('%s.%s.%s'):format(M._prefix, kind, name)
  end

  if one and #files > 1 then
    local msg = "Multiple plugins found for '%s':\n%s"
    error(msg:format(glob, table.concat(vim.tbl_keys(files), '\n')))
  end
  return plugs
end

function M.setup(kinds)
  local name = debug.getinfo(1, 'S').source:sub(2):match('nvim/lua/(.+)/init%.lua$')

  M._prefix = name
  M._fprefix = M._prefix:gsub('%.', '/')

  local plugins = {}
  for _, kind in ipairs(kinds) do
    table.insert(plugins, _find(kind))
  end
  M.plugin = vim.tbl_extend('force', unpack(plugins))

  return M
end

function M.load(kind, glob)
  local imods
  if glob then
    imods = vim.iter(vim.tbl_values(_find(kind, '*')))
  else
    local pat = ('^%s%%.%s%%..+$'):format(vim.pesc(M._prefix), vim.pesc(kind))
    imods = vim.iter(M.plugin):map(function(_, modname)
      return modname:match(pat)
    end)
  end
  imods:each(require)
end

function M.require(modname)
  if not M.plugin[modname] then
    M.plugin[modname] = _find('*', modname, true)[1]
    if not M.plugin[modname] then
      error('Plugin not found: ' .. modname)
    end
  end

  return require(M.plugin[modname])
end

return setmetatable(M, {
  __index = function(_, name)
    return M.require(name)
  end,
})
