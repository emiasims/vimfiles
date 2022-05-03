local M = { yanks = {}, max = 10, _nsid = vim.api.nvim_create_namespace 'mia.yankring' }
local _count = {}
local _after = {}
local _change_buffer = {}

function M.put(after)
  local buf = vim.api.nvim_get_current_buf()
  _change_buffer[buf] = 2 -- 2 - 1 for the change about to happen
  vim.api.nvim_feedkeys(vim.v.count1 .. (after and 'p' or 'P'), 'nx', true)
  vim.o.eventignore = ''
  if vim.v.register ~= '"' then
    return
  end
  -- feedkeys triggers autocmd that clears this, so safe to set afterwards
  _count[vim.api.nvim_get_current_buf()] = 1
  _after[vim.api.nvim_get_current_buf()] = after
end

function M.cycle(cycle_count)
  local buf = vim.api.nvim_get_current_buf()
  _count[buf] = (_count[buf] + cycle_count) % #M.yanks
  while _count[buf] <= 0 do -- very large negative count
    _count[buf] = _count[buf] + #M.yanks
  end
  local yank = M.yanks[_count[buf]]
  vim.fn.setreg('', table.concat(yank.val, '\n'), yank.type)
  _change_buffer[buf] = 2
  vim.cmd('normal! u' .. (_after[buf] and 'p' or 'P'))
end

function M.clear()
  local buf = vim.api.nvim_get_current_buf()
  if _change_buffer[buf] then
    _change_buffer[buf] = _change_buffer[buf] - 1
    if _change_buffer[buf] <= 0 then
      _change_buffer[buf] = nil
      _count[buf] = nil
    end
  end
end

function M.yank()
  if vim.v.event.regname ~= '' or #table.concat(vim.v.event.regcontents, '') <= 3 then
    return
  end
  table.insert(M.yanks, 1, { val = vim.v.event.regcontents, type = vim.v.event.regtype })
  M.yanks[M.max] = nil
  for i, yank in ipairs(M.yanks) do
    vim.fn.setreg(i, table.concat(yank.val, '\n'), yank.type)
  end
end

function M.show_yanks()
  vim.api.nvim_echo({ { 'N\tType\tContent', 'Identifier' } }, false, {})
  local msg = '%s\t%s\t%s'
  for ix, yank in ipairs(M.yanks) do
    vim.api.nvim_echo({ { msg:format(ix, yank.type, table.concat(yank.val, '\\n')) } }, false, {})
  end
end

vim.api.nvim_create_augroup('mia-yankring', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = '*',
  group = 'mia-yankring',
  desc = 'Add yank to yankring',
  callback = M.yank,
})

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP' }, {
  pattern = '*',
  group = 'mia-yankring',
  desc = 'Clear put context',
  callback = M.clear,
})

vim.api.nvim_create_user_command('Yanks', M.show_yanks, {})

-- stylua: ignore start
vim.keymap.set('n', '<M-n>', function() M.cycle(vim.v.count1) end)
vim.keymap.set('n', '<M-p>', function() M.cycle(-vim.v.count1) end)
vim.keymap.set({ 'n', 'x' }, 'p', function() M.put(true) end)
vim.keymap.set({ 'n', 'x' }, 'P', function() M.put(false) end)
-- stylua: ignore end

return M
