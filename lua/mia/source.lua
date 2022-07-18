local source = { re = [[\v%(^|/)%(lua/)\zs.{-}\ze%(/init)?\.lua$]] }

-- For use with SourceCmd autocmd event
function source.reload_module(filename)
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
