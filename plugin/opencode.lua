if not (vim.env.OPENCODE and vim.env.OPENCODE_PID) then
  return
end

local a1 = vim.fn.argv()[1]
-- somtimes I nest things. whatever don't judge me
if not (vim.fn.argc() == 1 and a1 and a1:find('^/tmp/.*%.md$')) then
  return
end

vim.b.update_bufinfo = {
  type = 'prompt',
  root = vim.fn.resolve('/proc/' .. vim.env.OPENCODE_PID .. '/cwd'),
}
vim.bo.filetype = 'markdown.prompt'

-- add completion: @filepath
