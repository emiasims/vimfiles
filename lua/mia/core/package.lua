local uv = vim.uv
local Config = require('mia.core.config')

local UpdateTrackers

---@type table<string, mia.pkg>
local Packages

local M = {
  loaded = {},
  changed = {},
  tracking = false,
}

---@class mia.pkg
---@field path string
---@field kind string
---@field name string
---@field alias? string
---@field loaded boolean
---@field mianame string
---@field modname string
---@field mtime integer
---@field ismod boolean is a directory module or a file
---@field up_to_date boolean?
local Spec = {}
Spec.__index = Spec

---@param path string
---@return mia.pkg
function Spec.new(path)
  local kind, name = path:match('/([^/]+)/([^/]+)%.lua$')
  local file_type = 'file'
  if not kind then
    kind, name = path:match('/([^/]+)/([^/]+)$')
    file_type = 'directory'
  end
  local pkg = setmetatable({
    path = path,
    kind = kind,
    name = name,
    alias = Config.aliases[name],
    mianame = 'mia.' .. name,
    modname = ('mia.%s.%s'):format(kind, name),
    ismod = file_type == 'directory',
  }, Spec)
  pkg.mtime = pkg:get_mtime()
  pkg.loaded = package.loaded[pkg.modname] and true or false
  return pkg
end

function Spec:load()
  local mod = require(self.modname)
  if type(mod) == 'table' then
    local setup = rawget(mod, 'setup')
    if setup and vim.is_callable(setup) then
      setup()
    end
  end
  return mod
end

function Spec:reload(force)
  if force or self.loaded then
    local save = package.loaded[self.modname]
    package.loaded[self.mianame] = nil
    package.loaded[self.modname] = nil
    mia[self.name] = nil
    M.changed[self.name] = nil

    local ok, mod = pcall(Spec.load, self)
    if not ok then
      mia.err('Error loading package: %s\n%s', self.mianame, mod)
      package.loaded[self.modname] = save
      return
    end
    return mod
  end
end

local function fs_stat(path)
  return uv.fs_stat(path).mtime.sec
end

function Spec:get_mtime()
  if not self.ismod then
    return fs_stat(self.path)
  end

  local mtime = 0
  for filename, type in vim.fs.dir(self.path, { depth = math.huge }) do
    if type == 'file' and filename:sub(-4) == '.lua' then
      local cmp = fs_stat(self.path .. '/' .. filename)
      mtime = math.max(cmp, mtime)
    end
  end

  return mtime
end

function M.get(name)
  if Packages[name] then
    return Packages[name]
  end
  if name:match('/') then
    return Spec.new(name)
  end
  error(('No module found at "%s"'):format(name))
end

local function get_paths(kinds)
  if not kinds then
    return Config.paths
  elseif type(kinds) == 'string' then
    kinds = { kinds }
  end
  local paths = {}
  for _, kind in ipairs(kinds) do
    paths[kind] = Config.paths[kind]
    if not paths[kind] then
      error(('No path for "%s". Is it setup?'):format(kind))
    end
  end
  return paths
end

function M.names()
  return vim.tbl_keys(Packages)
end

function M.list(kinds)
  if kinds == true then
    return Packages
  end
  local kind_paths = get_paths(kinds)

  local mods = {}
  for _, path in pairs(kind_paths) do
    for filename, _ in vim.fs.dir(path) do
      local name = filename:match('(.+)%.lua$')
      -- TODO why is this here?
      if mods[name] then
        error(('Duplicate module name: %s'):format(name))
      end
      local mod = Spec.new(vim.fs.joinpath(path, filename))
      mods[name] = mod
    end
  end
  return mods
end

---@param kinds? string|string[]
---@return mia.pkg[] updated The packages that have been changed or added
function M.get_updates(kinds)
  local updated = {}
  for name, mod in pairs(M.list(kinds)) do
    if not Packages[name] or mod.mtime ~= Packages[name].mtime then
      table.insert(updated, mod)
    end
  end
  return updated
end

--- Use to disable previously set up mods or to have a 'reload guard'
---@param fn string
function M.on_reload(fn)
  local info = debug.getinfo(2, 'S')
  local path = info.source:match('/lua/(mia/.*)$')
  local name = path:gsub('%.lua$', ''):gsub('%/init$', ''):gsub('/', '.')

  -- local name = path:gsub('/', '.')
  local mod = package.loaded[name]
  if type(mod) ~= 'table' then
    return
  end
  if type[fn] == 'function' then
    fn(mod)
  else
    mod[fn]()
  end
end

function M.enable_tracking()
  UpdateTrackers = {}
  for kind, path in pairs(Config.paths) do
    UpdateTrackers[kind] = uv.new_fs_poll()

    UpdateTrackers[kind]:start(path, 2000, function(_, _)
      for _, mod in ipairs(M.get_updates(kind)) do
        Packages[mod.name] = mod
        M.changed[mod.name] = true
        if mod.loaded then
          Packages[mod.name].up_to_date = false
        end
      end
    end)
  end
  M.tracking = true
end

function M.disable_tracking()
  if UpdateTrackers then
    for _, tracker in pairs(UpdateTrackers) do
      tracker:stop()
    end
    UpdateTrackers = nil
  end
  M.tracking = false
end
M.on_reload('disable_tracking')

function M.load(kind, force)
  for _, spec in pairs(Packages) do
    if spec.kind == kind then
      if force then
        spec:reload(force)
      else
        spec:load()
      end
    end
  end
end

function M.require(modname)
  local spec = M.get(modname)
  if not spec then
    error('Plugin not found: ' .. modname)
  end

  return package.loaded[spec.modname] or spec:load()
end

function M.setup()
  M.packages = setmetatable(M.list(), {
    __index = function(t, name)
      return rawget(t, Config.aliases[name])
    end,
  })
  Packages = M.packages
  M.enable_tracking()
end

return M
