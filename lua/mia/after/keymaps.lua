local M = {}

function M.delete_surrounding_function()
  local query = vim.treesitter.query.get(vim.o.filetype, 'textobjects')
  if not query then
    mia.warn('No textobjects query found for filetype ' .. vim.o.filetype)
  end

  -- local cursor_node = vim.treesitter.get_node()
  local root = vim.treesitter.get_parser():parse()[1]:root()
  local _, lnum, col = unpack(vim.fn.getcurpos())
  lnum, col = lnum - 1, col - 1

  -- Get all the calls and smallest param here
  local calls, param = {}, {}
  for id, node, _ in query:iter_captures(root, 0, lnum, lnum + 1) do
    if query.captures[id]:match('param') and vim.treesitter.is_in_node_range(node, lnum, col) then
      param = node
    elseif query.captures[id]:match('call.outer') and vim.treesitter.is_in_node_range(node, lnum, col) then
      calls[#calls + 1] = node
    end
  end

  -- Get the first call that isn't the parameter.  This can't necessarily be
  -- done in the query loop, because we might match calls first.
  local call
  for i = #calls, 1, -1 do
    if calls[i] ~= param then
      call = calls[i]
      break
    end
  end

  if param and call then
    require('nvim-treesitter.ts_utils').update_selection(0, param)
    vim.api.nvim_feedkeys('y', 'nx', true)
    require('nvim-treesitter.ts_utils').update_selection(0, call)
    vim.api.nvim_feedkeys('p', 'nx', true)
  else
    mia.warn('Parameter or call not found')
  end
end

return M
