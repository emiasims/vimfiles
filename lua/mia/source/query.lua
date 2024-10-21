return function(ev)
  local ft, kind = ev.file:match('(%w+)/(%w+)%.scm')
  local n = 0
  local action, msg
  if kind == 'highlights' then
    action = function()
      vim.cmd.TSBufDisable('highlight')
      vim.cmd.TSBufEnable('highlight')
    end
    msg = 'Reloaded %s "%s" buffer%s highlights'
  else
    action = function()
      vim.cmd.mkview()
      vim.cmd.update()
      vim.cmd.edit()
      vim.cmd.loadview()
    end
    msg = 'Reloaded %s "%s" buffer%s'
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == ft then
      n = n + 1
      vim.api.nvim_buf_call(buf, action)
    end
  end
  mia.notify(msg:format(n, ft, n == 1 and '' or 's'))
end
