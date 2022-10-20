vim.api.nvim_create_user_command('CloseFloatingWindows', function()
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
