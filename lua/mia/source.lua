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

  mia.last_reloaded = source.unload(parent)
  table.sort(mia.last_reloaded)

  package.loaded[module] = dofile(filename) or true
  for _, name in ipairs(mia.last_reloaded) do
    if name ~= module then
      require(name)
    end
  end

  vim.notify(string.format('Reloaded %s and all "%s" submodules', relative, parent))
end

function source.set_query(filename, notify)
  local match = vim.fn.matchlist(filename, [[\v%(^|/)queries/([^/]+)/([^/]+).scm$]])
  if #match == 0 then
    error 'what happened'
  end
  local lang, name = match[2], match[3]
  local f = io.open(filename)
  if f then
    local qstr = f:read("*all")
    f:close()
    vim.treesitter.set_query(lang, name, qstr)
  end
  if notify then
    local relative = vim.fn.matchstr(filename, [[\v%(^|/)\zsqueries/[^/]+/[^/]+.scm$]])
    vim.notify(('Set query "%s" for lang "%s" from %s'):format(name, lang, relative))
  end
end

function source.unload(name)
  local _re = '^' .. name
  mia.last_reloaded = {}
  local unloaded = {}
  for submod, _ in pairs(package.loaded) do
    if submod:match(_re) then
      package.loaded[submod] = nil
      unloaded[#unloaded+1] = submod
    end
  end
  return unloaded
end

return source
