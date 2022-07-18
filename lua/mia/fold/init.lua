
_G.foldtext = function() return require('mia.fold.text').optfunc() end
vim.o.foldtext = "v:lua.foldtext()"

return setmetatable({}, { __index = function(_, k)
  if k == 'expr' then
    return require('mia.fold.expr').queryexpr
  elseif k == 'text' then
    return  require('mia.fold.text').queryexpr
  end
end })
