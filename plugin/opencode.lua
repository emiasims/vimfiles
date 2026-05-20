if not (vim.env.OPENCODE and vim.env.OPENCODE_PID and mia.is_tmpf(1)) then
  return
end

local pid = vim.env.OPENCODE_PID
local cwd = vim.fn.has('mac') == 1
  and vim.fn.system({'lsof', '-a', '-p', pid, '-d', 'cwd', '-Fn'}):match('\nn([^\n]+)')
  or vim.fn.resolve('/proc/' .. pid .. '/cwd')

vim.b.update_bufinfo = { type = 'prompt', root = cwd }
vim.bo.filetype = 'markdown.prompt'

vim.keymap.set('i', '@', '@<C-x><C-f>', { buffer = true })

local pmfile = vim
  .iter(vim.fs.dir('.'))
  :filter(function(_, type) return type == 'file' end)
  :filter(function(name) return name:match('^PM%..*%.md') end)
  :next()

if pmfile then
  vim.cmd.vsplit(pmfile)
end
