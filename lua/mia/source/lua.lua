local M = {
  std_config = vim.fn.resolve(vim.fn.stdpath('config')),
  vimruntime = vim.fn.resolve(vim.env.VIMRUNTIME),
  lazy_root = vim.fn.stdpath("data") .. "/lazy",  -- Lazy.config.options.root
  ---@type table<string, fun(spec: mia.reload_spec): string?>
  _helpers = {},
}
local H = M._helpers
local Lazy = {
  --
  config = mia.on.index('lazy.core.config'),
  plugin = mia.on.index('lazy.core.plugin'),
  loader = mia.on.index('lazy.core.loader'),
}

H.is_sso = function(_)
  return vim.b.source_alone or vim.g.source_alone
end

H.reload = function(spec)
  -- maybe inject require?
  package.loaded[spec.module] = dofile(spec.filename) or true
  return spec.module
end

H.dofile = function(spec)
  dofile(spec.filename)
  return spec.filename
end

H.reload_lazy_spec = function(spec)
  local lazy_spec = dofile(spec.filename)
  package.loaded[spec.module] = lazy_spec
  lazy_spec = Lazy.plugin.Spec.new(lazy_spec)

  -- deactivate all first, so dependencies load 'in order'
  for _, plugin in pairs(lazy_spec.plugins) do
    Lazy.loader.deactivate(plugin)
  end
  for _, plugin in pairs(lazy_spec.plugins) do
    Lazy.loader.reload(plugin.name)
  end

  return table.concat(vim.tbl_keys(lazy_spec.plugins), ', ')
end

H.reload_lazy_module = function(spec)
  error 'NYI'
  -- require('lazy.core.loader').reload(spec:lazy_name())
  -- return spec.package
end

H.reload_module = function(spec)
  -- Otherwise, just try to find packages to reload
  local unloaded = {}
  for submod, _ in pairs(package.loaded) do
    if vim.startswith(submod, spec.package) then
      package.loaded[submod] = nil
      table.insert(unloaded, submod)
    end
  end
  table.sort(unloaded)

  package.loaded[spec.module] = dofile(spec.filename) or true
  for _, name in ipairs(unloaded) do
    if name ~= spec.module then
      require(name)
    end
  end

  require(spec.module)
  return spec.relative_filename .. ' and all "' .. spec.package .. '" submodules'
end

local detect_mod = function(name, path)
  if name == nil then
    return function(spec)
      return spec.module
    end
  end
  if path == nil then
    return function(spec)
      -- return vim.startswith(spec.module, name)
      return spec.package == name
    end
  end
  return function(spec)
    return spec.package == name and vim.startswith(spec.path, path)
  end
end

-- save global state maybe?
local source_kinds = {
  { name = 'single source', detect = H.is_sso, source = H.reload }, -- g: or b:
  { name = 'mia-config', detect = detect_mod('mia'), source = H.reload },
  { name = 'vim-runtime', detect = detect_mod('vim', M.vimruntime), source = H.reload },
  { name = 'lazy-spec', detect = detect_mod('plugin', M.std_config), source = H.reload_lazy_spec },
  { name = 'lazy-module', detect = detect_mod(..., M.lazy_root), source = H.reload_lazy_module },
  { name = 'reload-module', detect = detect_mod(), source = H.reload_module },
}

function M.get_spec(filename, buf)
  local path, relative, name = filename:match('^(/.*)/lua/((..-).lua)$')
  if not path then
    return { filename = filename, buf = buf, source = H.dofile } --[[@as mia.reload_spec]]
  end
  if name:sub(-5) == '/init' then
    name = name:sub(1, -6)
  end

  ---@class mia.reload_spec
  local spec = {
    filename = filename,
    buf = buf,
    path = path,
    relative_filename = relative,
    module = name:gsub('/', '.'),
    package = name:sub(1, (name:find('/') or 1) - 1),
  }

  for _, kind in ipairs(source_kinds) do
    if kind.detect(spec) then
      spec.source = kind.source
      spec.kind = kind.name
      return spec
    end
  end

  spec.source = function(spec) dofile(spec.filename) end
  return spec
end

function M.reload_lua_module(filename, buf)
  local spec = M.get_spec(filename, buf)
  local msg = spec:source()
  if spec.kind and msg then
    mia.warn(("Reloaded %s via '%s'"):format(msg, spec.kind))
  end
end

return M.reload_lua_module
