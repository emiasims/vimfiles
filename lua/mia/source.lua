-- Not sure why this isn't working:
-- local source = { reg = vim.regex([[^\v%(lua/)?\zs.*\ze%(/init)?\.lua$]]) }
local source = { re = [[\v%(^|/)%(lua/)\zs.*\ze%(/init)?\.lua$]] }

-- For use with SourceCmd autocmd event
function source.fn(filename)
  local res = dofile(filename)

  local module = vim.fn.matchstr(filename, source.re)
  if module == '' then
    return
  end

  module = vim.fn.substitute(module, '/', '.', 'g')
  package.loaded[module] = res or true
end

return source
