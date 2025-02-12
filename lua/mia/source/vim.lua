return function(filename)
  vim.cmd.source(vim.fn.fnameescape(filename))
end
