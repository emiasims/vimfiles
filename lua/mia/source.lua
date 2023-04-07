local source = { re = [[\v%(^|/)%(lua/)\zs.{-}\ze%(/init)?\.lua$]] }

-- For use with SourceCmd autocmd event
function source.reload_lua_module(filename)
  local relative = vim.fn.matchstr(filename, [[\v%(^|/)%(lua/)\zs.{-}%(/init)?\.lua$]])
  local module = vim.fn.matchstr(relative, [[\v.{-}\ze%(/init)?\.lua$]])
  local parent = vim.split(module, '/')[1]
  module = module:gsub('/', '.')
  if module == '' then
    dofile(filename)
    return -- vim.notify(string.format('Reloaded %s', filename))
  end

  if parent == 'mia' then
    -- package.loaded[module]
    package.loaded[module] = dofile(filename)
    vim.notify(string.format('Reloaded %s', relative))
    return
  end

  if parent == 'plugins' and package.loaded['lazy'] then
    -- might be a bit hacky. But that's okay with me.
    package.loaded[module] = vim.tbl_extend('force', package.loaded[module], dofile(filename))
    require('lazy.core.loader').reload(package.loaded[module])
    vim.notify(string.format('Reloaded package %s', relative))
    return
  end

  _G._last_reloaded = source.unload(parent)
  table.sort(_G._last_reloaded)

  package.loaded[module] = dofile(filename) or true
  for _, name in ipairs(_G._last_reloaded) do
    if name ~= module then
      require(name)
    end
  end

  vim.notify(string.format('Reloaded %s and all "%s" submodules', relative, parent))
end

function source.unload(name)
  local _re = '^' .. name
  _G._last_reloaded = {}
  local unloaded = {}
  for submod, _ in pairs(package.loaded) do
    if submod:match(_re) then
      package.loaded[submod] = nil
      unloaded[#unloaded+1] = submod
    end
  end
  return unloaded
end

function source.set_query(filename, notify)
  -- Get query files
  -- re-source in order, simple now
  local match = vim.fn.matchlist(filename, [[\v%(^|/)queries/([^/]+)/([^/]+).scm$]])
  if #match == 0 then
    error 'what happened'
  end
  local lang, name = match[2], match[3]
  -- local files = vim.treesitter.query.get_files(lang, name)
  local f = io.open(filename)
  if f then
    local qstr = f:read("*all")
    f:close()
    vim.treesitter.query.set(lang, name, qstr)
  end
  if notify then
    local relative = vim.fn.matchstr(filename, [[\v%(^|/)\zsqueries/[^/]+/[^/]+.scm$]])
    vim.notify(('Set query "%s" for lang "%s" from %s'):format(name, lang, relative))
  end
end

return source
