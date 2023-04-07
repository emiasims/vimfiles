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
