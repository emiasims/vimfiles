-- bodgery opens the prompt with :split from the agent terminal, so the alternate buffer is that terminal
local alt = vim.fn.bufnr('#')
local info = alt ~= -1 and vim.bo[alt].buftype == 'terminal' and vim.b[alt].bufinfo or nil

-- opencode sets its own update_bufinfo (with root) before setting markdown.prompt
vim.b.update_bufinfo = vim.tbl_extend('keep', vim.b.update_bufinfo or {}, {
  type = 'prompt',
  tab_name = info and ('[prompt:(%s:%d)]'):format(info.type, info.bufnr) or '[prompt]',
})
