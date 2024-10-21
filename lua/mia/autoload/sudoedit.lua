local util = require('mia.util')

local M = { }

M.exec = function(cmd, print_output)
  vim.fn.inputsave()
  local password = vim.fn.inputsecret('Password: ')
  vim.fn.inputrestore()
  if not password or #password == 0 then
    mia.warn('Invalid password, sudo aborted')
    return false
  end
  local out = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    print('\r\n')
    mia.err(out)
    return false
  end
  if print_output then
    print('\r\n', out)
  end
  return true
end

M.write = function(tmpf, path)
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  local cmd =
    string.format('dd if=%s of=%s bs=1048576', vim.fn.shellescape(tmpf), vim.fn.shellescape(path))
  -- no need to check error as this fails the entire function
  M.job:write({
'sudo',
'dd',
'if=%s',
'of=%s',
'bs=1048576'
  })

  if M.exec(cmd) then
    -- refreshes the buffer and prints the "written" message
    vim.cmd.checktime()
    -- exit command mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
  end
end

M.setup = function(opts)
  if M.job then
    M.job:kill(15)
    -- while :is_closing()
    -- wait then eventually kill 9 if its alive
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, '[sudoedit-terminal]')
  local id = vim.api.nvim_open_term(buf, {})




  -- local password = vim.fn.inputsecret('Password: ')
end

return M
