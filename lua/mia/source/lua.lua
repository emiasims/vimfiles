local M = {
  std_config = vim.fn.resolve(vim.fn.stdpath('config') --[[@as string]]),
  vimruntime = vim.fn.resolve(vim.env.VIMRUNTIME),
  lazy_root = vim.fn.stdpath('data') .. '/lazy', -- Lazy.config.options.root
  kinds = {},
  _check = {},
  _srcfn = {},
}

local C = M._check
local R = M._srcfn

local Lazy = {
  config = mia.on.index('lazy.core.config'),
  plugin = mia.on.index('lazy.core.plugin'),
  loader = mia.on.index('lazy.core.loader'),
}

function C.source_alone(_)
  return vim.b.source_alone or vim.g.source_alone
end

function C.is_mia_pkg(spec)
  if spec.package == 'mia' then
    local ok, _ = pcall(mia.package.get, spec.module:match('[^.]+$'))
    return ok
  end
end

function C.is_rtp(spec)
  return #vim.fn.globpath(vim.o.rtp, spec.path) > 0
end

function R.module(spec)
  package.loaded[spec.module] = dofile(spec.filename) or true
  return spec.module
end

function R.mia(spec)
  local pkg = mia.package.get(spec.module:match('[^.]+$'))
  pkg:reload(true)
  mia[pkg.name] = package.loaded[pkg.modname]
  return pkg.modname
end

function R.dofile(spec)
  dofile(spec.filename)
  return spec.filename
end

function R.lazy_spec(spec)
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

---@diagnostic disable-next-line: unused-local
function R.lazy_module(spec)
  error('NYI')
  -- require('lazy.core.loader').reload(spec:lazy_name())
  -- return spec.package
end

function R.package(spec)
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

-- memoize?
local function build_check(kind)
  local module, pkg, path = kind.module, kind.pkg, kind.path
  ---@param spec mia.reload_spec
  kind.check = function(spec)
    local m = type(module) == 'function' and module() or module
    local pk = type(pkg) == 'function' and pkg() or pkg
    local pa = type(path) == 'function' and path() or path
    return (m and spec.module == m)
      or (pk and spec.package == pk)
      -- or (path and vim.startswith(spec.path, path))
      or (pa and #vim.fn.globpath(pa, spec.path) > 0)
  end
  return kind.check
end

-- save global state maybe?
M.kinds = {
  { name = 'source_alone', check = C.source_alone, source = 'module' }, -- g: or b:
  { name = 'mia-pkg', check = C.is_mia_pkg, source = 'mia' },
  { name = 'mia-config', pkg = 'mia', source = 'module' },
  { name = 'vim-runtime', pkg = 'vim', path = mia.F.index(vim.env, 'VIMRUNTIME'), source = 'module' },
  { name = 'lazy-spec', pkg = 'plugins', path = vim.fn.stdpath('config'), source = 'lazy_spec' },
  { name = 'lazy-module', path = mia.F.index(Lazy.config, 'options', 'root'), source = 'lazy_module' },
  { name = 'reload-module', path = mia.F.index(vim.o, 'rtp'), source = 'package' },
}

function M.get_spec(filename, buf)
  local path, relative, name = filename:match('^(/.*)/lua/((..-).lua)$')
  if not path then
    return { filename = filename, buf = buf, source = R.dofile } --[[@as mia.reload_spec]]
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

  for _, kind in ipairs(M.kinds) do
    if not kind.check then
      kind.check = build_check(kind)
    end

    if kind.check(spec) then
      spec.source = R[kind.source]
      spec.kind = kind.name
      return spec
    end
  end

  spec.source = function(sp)
    dofile(sp.filename)
  end
  return spec
end

function M.reload_lua_module(filename, buf)
  local spec = M.get_spec(filename, buf)
  local msg = spec:source()
  if spec.kind and msg then
    mia.warn("Reloaded %s via '%s'", msg, spec.kind)
  end
end

function M.undo() end

return setmetatable(M, {
  __call = function(_, ...)
    return M.reload_lua_module(...)
  end,
})
