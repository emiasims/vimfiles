local mia = {}

function mia.P(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify(vim.inspect(v))
  return v
end
_G.P = mia.P

vim.api.nvim_create_user_command('CloseFloatingWindows', function()
  local closed = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
      closed[#closed+1] = win
    end
  end
  print('Windows closed: ', table.concat(closed, ' '))
end, {})

require 'mia.packer' -- plugin set up

require('mia.config.keymaps')
require('mia.config.treesitter')
require('mia.config.telescope')

-- list of 'v:lua.mia.THING' that I want to be able to reload via :so%
setmetatable(mia, { __index = function(_, k)
  if k == 'statusline' then
    return require('mia.tslib').statusline
  elseif k == 'foldexpr' then
    return require('mia.fold.expr').queryexpr
  end
  local success, ret = pcall(require, 'mia.' .. k)
  return success and ret
end })

if not package.loaded['gruvbox'] then
  -- colors get wonky if I redo this
  require 'lush'(require 'gruvbox')
end

require('mia.fold.text').enable()

return mia
