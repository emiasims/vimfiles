local source = { re = [[\v%(^|/)%(lua/)\zs.{-}\ze%(/init)?\.lua$]] }

-- For use with SourceCmd autocmd event
function source.reload_module(filename)
  local module = vim.fn.matchstr(filename, source.re)
  if module == '' then
    dofile(filename)
    return
  end

  local parent = vim.split(module, '/')[1]
  local parent_re = '^' .. parent
  mia.last_reloaded = source.unload(parent)
  table.sort(mia.last_reloaded)
  module = module:gsub('/', '.')

  package.loaded[module] = dofile(filename) or true
  for _, name in ipairs(mia.last_reloaded) do
    if name ~= module then
      require(name)
    end
  end

  vim.notify(string.format('Reloaded %s.lua and all "%s" submodules', module, parent))
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
