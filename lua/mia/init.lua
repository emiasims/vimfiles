-- set up for v:lua.mia[thing]
_G.mia = setmetatable({}, {
  __index = function(self, name)
    if name == 'statusline' then
      return require('mia.tslib').statusline
    elseif name == 'foldtext' then
      return require('mia.fold.text')
    elseif name == 'foldexpr' then
      return require('mia.fold.expr').queryexpr
    elseif name == 'source' then
      return require 'mia.source'
    end
  end,
})

return _G.mia
