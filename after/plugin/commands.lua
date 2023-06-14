local make_command = vim.api.nvim_create_user_command
local echo = function(...) vim.api.nvim_echo({ ... }, true, {}) end

make_command('CloseFloatingWindows', function()
  local closed = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
      closed[#closed + 1] = win
    end
  end
  print('Windows closed: ', table.concat(closed, ' '))
end, {})

make_command('Move', function(t)
  local filename = t.args
  local force = t.bang

  local f = io.open(filename, "r")
  if f ~= nil and io.close(f) and not force then
    echo { "E13: File exists (add ! to override)", "Error" }
    return
  end

  local path = vim.fn.expand('%:p')
  -- vim.cmd.file { vim.fn.fnameescape(filename), silent = true, keepalt = true }
  vim.cmd("silent keepalt file " .. vim.fn.fnameescape(filename))
  vim.cmd.write { bang = true }
  vim.cmd.filetype("detect")
  vim.fn.delete(path)

end, { nargs = 1, bang = true, complete = "file" })


make_command('Delview', function()
  local path = vim.fn.expand('%:p'):gsub('=', '==')
  path = path:gsub('^' .. os.getenv('HOME'), '~')
  path = path:gsub('/', '=+')
  local file = vim.o.viewdir .. path .. '='
  local success = vim.fn.delete(file) == 0
  if success then
    echo { 'Deleted: ' .. file }
  else
    echo { 'No view found: ' .. file, 'Error' }
  end
end, {})

-- from runtime, edited to have cursor positioning
make_command('InspectTree', function(cmd)
  local src_win = vim.api.nvim_get_current_win()
  -- directly from $VIMRUNTIME/plugin/nvim.lua
  if cmd.mods ~= '' or cmd.count ~= 0 then
    local count = cmd.count ~= 0 and cmd.count or ''
    local new = cmd.mods ~= '' and 'new' or 'vnew'

    vim.treesitter.inspect_tree({
      command = ('%s %s%s'):format(cmd.mods, count, new),
    })
  else
    vim.treesitter.inspect_tree()
  end
  -- end
  vim.keymap.set('n', 'q', '<cmd>q<cr>')
  vim.api.nvim_set_current_win(src_win)
end, { desc = 'Inspect treesitter language tree for buffer', count = true })
