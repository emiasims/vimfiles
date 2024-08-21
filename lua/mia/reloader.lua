local M = {
  std_config = vim.fn.resolve(vim.fn.stdpath('config')),
  vimruntime = vim.fn.resolve(vim.env.VIMRUNTIME),
}

---@class Info
local Info = {
  is_config = function(info, name)
    return info.path == M.std_config and info.package == name
  end,

  is_runtime = function(info)
    return info.package == 'vim' and info.path == M.vimruntime
  end,

  lazy_name = function(info)
    info.name = info.name
      or vim.iter(require('lazy.core.config').plugins):find(function(_, plugin)
        return vim.fn.resolve(plugin.dir .. '//') == info.path
      end)
    return info.name
  end,
}
Info.__index = Info

function M.info(filename, buf)
  filename = vim.fn.resolve(vim.fn.fnamemodify(filename, ':p'))
  local path, relative, name = filename:match('^(/.*)/lua/((..-).lua)$')
  if not path then
    return
  end
  if name:sub(-5) == '/init' then
    name = name:sub(1, -6)
  end

  return setmetatable({
    filename = filename,
    path = path,
    relative_filename = relative,
    module = name:gsub('/', '.'),
    package = name:sub(1, (name:find('/') or 1) - 1),
    buf = buf or vim.fn.bufnr(filename),
  }, Info)

end

function M.reload_lua_module2(filename, buf)
  local source_file_info = M.info(filename, buf)

  -- Not in rtp
  if not source_file_info then
    dofile(filename)
    vim.notify(('Executed %s'):format(filename))
    return
  end

  source_file_info:source()
end

-- For use with SourceCmd autocmd event
function M.reload_lua_module(filename, buf)
  local info = M.info(filename, buf)

  -- Not a file from my config or vim runtime, just execute it.
  if not info then
    dofile(filename)
    -- vim.notify(('Executed %s'):format(filename))
    return
  end

  -- Config file or vim runtime file, try to reload just that file
  if info:is_config('mia') or info:is_runtime() or vim.b[info.buf].sso then
    package.loaded[info.module] = dofile(filename) or true
    vim.notify(('Reloaded %s'):format(info.relative_filename))
    return
  end

  -- Package is a lazy spec
  if info:is_config('plugins') then
    local spec = dofile(filename)
    package.loaded[info.module] = spec
    spec = require('lazy.core.plugin').Spec.new(spec)
    local names = vim.tbl_keys(spec.plugins)

    -- deactivate all first, so dependencies load 'in order'
    for _, plugin in pairs(spec.plugins) do
      require('lazy.core.loader').deactivate(plugin)
    end
    for _, plugin in pairs(spec.plugins) do
      require('lazy.core.loader').reload(plugin.name)
    end

    if #names == 0 then
      vim.api.nvim_err_writeln(('No plugins loaded from spec at %s'):format(info.relative_filename))
    else
      local s = #names == 1 and '' or 's'
      vim.notify(
        string.format(
          "Reloaded '%s' plugin%s and config%s from '%s'",
          table.concat(names, "', '"),
          s,
          s,
          info.relative_filename
        )
      )
    end
    return
  end

  -- when editing a plugin, check if it has a lazy spec first
  if info:lazy_name() then
    require('lazy.core.loader').reload(info:lazy_name())
    vim.notify(("Reloaded '%s' plugin and lazy config"):format(info.package))
    return
  end

  -- Otherwise, just try to find packages to reload
  local reload = M.unload(info.package)
  table.sort(reload)

  package.loaded[info.module] = dofile(filename) or true
  for _, name in ipairs(reload) do
    if name ~= info.module then
      require(name)
    end
  end

  vim.notify(('Reloaded %s and all "%s" submodules'):format(info.relative_filename, info.package))
end

function M.unload(name)
  local unloaded = {}
  for submod, _ in pairs(package.loaded) do
    if submod:sub(1, #name) == name then
      package.loaded[submod] = nil
      unloaded[#unloaded + 1] = submod
    end
  end
  return unloaded
end

return M
