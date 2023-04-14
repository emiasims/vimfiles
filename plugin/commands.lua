local make_command = vim.api.nvim_create_user_command

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

make_command('Delview', function()
  local path = vim.fn.expand('%:p'):gsub('=', '==')
  path = path:gsub('^' .. os.getenv('HOME'), '~')
  path = path:gsub('/', '=+')
  local file = vim.o.viewdir .. path .. '='
  local success = vim.fn.delete(file) == 0
  if success then
    vim.api.nvim_echo({ { 'Deleted: ' .. file } }, true, {})
  else
    vim.api.nvim_echo({ { 'No view found: ' .. file, 'Error' } }, true, {})
  end
end, {})

-- from runtime, edited to have cursor positioning
make_command('InspectTree', function(cmd)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local original_win = vim.api.nvim_get_current_win()
  if cmd.mods ~= '' or cmd.count ~= 0 then
    local count = cmd.count ~= 0 and cmd.count or ''
    local new = cmd.mods ~= '' and 'new' or 'vnew'

    vim.treesitter.inspect_tree({
      command = ('%s %s%s'):format(cmd.mods, count, new),
    })
  else
    vim.treesitter.inspect_tree()
  end
  vim.keymap.set('n', 'q', '<cmd>q<cr>')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(original_win)
  vim.api.nvim_win_set_cursor(original_win, cursor)
  vim.api.nvim_set_current_win(new_win)
end, { desc = 'Inspect treesitter language tree for buffer', count = true })
