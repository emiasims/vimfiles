local uv = vim.uv
local Config = require('mia.core.config')

local M = {
  packages = {},
  not_updated = {},
}

---@class mia.pkg
---@field path string
---@field kind string
---@field name string
---@field loaded boolean
---@field mianame string
---@field modname string
---@field mtime number
---@field ismod boolean is a directory module or a file
local Package = {}
Package.__index = Package

---@param path string
---@return mia.pkg
Package.get = function(path)
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
    mianame = 'mia.' .. name,
    modname = ('mia.%s.%s'):format(kind, name),
    ismod = file_type == 'directory',
  }, Package)
  pkg.mtime = pkg:get_mtime()
  pkg.loaded = package.loaded[pkg.modname] and true
  return pkg
end

function Package:reload()
  if self.loaded then
    package.loaded[self.mianame] = nil
    package.loaded[self.modname] = nil
    local mod = require(self.mianame)
    if mod.setup then
      mod.setup()
    end
  end
end

local fs_stat = function(path)
  return uv.fs_stat(path).mtime.sec
end

function Package:get_mtime()
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

M.get = function(str)
  str = Config.aliases[str] or str
  if M.packages[str] then
    return M.packages[str]
  end
  if str:match('/') then
    return Package.get(str)
  end
  error(('No module found at "%s"'):format(str))
end

local get_paths = function(kinds)
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

M.list = function(kinds)
  local kind_paths = get_paths(kinds)

  local mods = {}
  for _, path in pairs(kind_paths) do
    for filename, _ in vim.fs.dir(path) do
      local name = filename:match('(.+)%.lua$')
      if mods[name] then
        error(('Duplicate module name: %s'):format(name))
      end
      mods[name] = Package.get(vim.fs.joinpath(path, filename))
    end
  end
  return mods
end

---@param kinds? string|string[]
---@return mia.pkg[] updated The packages that have been changed or added
M.get_updates = function(kinds)
  local updated = {}
  for name, mod in pairs(M.list(kinds)) do
    if not M.packages[name] or mod.mtime ~= M.packages[name].mtime then
      table.insert(updated, mod)
      -- M.packages[name] = mod
    end
  end
  return updated
end

M.enable_tracking = function()
  local trackers = {}
  for kind, path in pairs(Config.paths) do
    trackers[kind] = uv.new_fs_poll()
    -- local _kind = kind
    trackers[kind]:start(path, 2000, function(_, _)
      for name, mod in pairs(M.list(kind)) do
        if not M.packages[name] or mod.mtime ~= M.packages[name].mtime then
          M.packages[mod.name] = mod
          if mod.loaded then
            M.not_updated[mod.name] = mod
          else
          end
        end
      end
    end)
  end
  M.trackers = trackers
end

M.disable_tracking = function()
  if M.trackers then
    for _, tracker in pairs(M.trackers) do
      tracker:stop()
    end
    M.tracker = nil
  end
end
Config.on_reload('disable_tracking')

M.reload_all = function(force)
  if force then
    for _, mod in pairs(M.packages) do
      if mod.loaded then
        mod:reload()
      end
    end
    M.not_updated = {}
    return
  end
end

M.reload = function(kind)
  for name, mod in pairs(M.not_updated) do
    local ok, err = pcall(mod.reload, mod)
    if ok then
      M.not_updated[name] = nil
    else
      mia.err(('Error reloading %s: %s'):format(name, err))
    end
  end
end

M.load = function(kind)
  for _, spec in pairs(M.packages) do
    if spec.kind == kind then
      local ok, res = pcall(require, spec.modname)
      if not ok then
        M.err('Error loading plugin:' .. spec.modname .. '\n' .. res)
      end
    end
  end
end

M.require = function(modname)
  local spec = M.get(modname)
  if not spec then
    error('Plugin not found: ' .. modname)
  end

  return require(spec.modname)
end

M.setup = function()
  M.packages = M.list()
  Config.packages = M.packages
  M.enable_tracking()
end

return M
