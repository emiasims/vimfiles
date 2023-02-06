return function()
  local line = vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, false)[1]
  -- local line = require('foldhue').foldtext()
  local suffix = ('%s lines %s'):format(vim.v.foldend - vim.v.foldstart, string.rep('|', vim.v.foldlevel))
  local pad = vim.api.nvim_win_get_width(0)
    - vim.o.foldcolumn
    - (vim.o.number and 1 or 0) * vim.o.numberwidth
    - #line
    - #suffix
    - 5 -- ' ... ' and some other correction
  return ('%s %s %s '):format(line, string.rep(' ', pad), suffix)
end
