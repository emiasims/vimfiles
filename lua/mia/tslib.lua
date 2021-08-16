local M = {}

local api = vim.api
local ts = vim.treesitter

function M.query2list(query, bufnr, lang)
  local lang = lang or M.ft_to_lang[vim.o.filetype] or vim.o.filetype
  local root = vim.treesitter.get_parser(bufnr or 0, lang):parse()[1]:root()
  local qo = vim.treesitter.parse_query(vim.bo.filetype, query)
  local capture = {}
  for id, node, metadata in qo:iter_captures(root, 0, 0, -1) do
    P{ { node:range() }, metadata }
    table.insert(capture, node)
  end
  return capture
end

M.ft_to_lang = {
  py = 'python',
  sh = 'bash',
  js = 'javascript',
}

function M.has_parser(lang)
  local lang = lang or M.ft_to_lang[vim.o.filetype] or vim.o.filetype
  return pcall(ts.inspect_language, lang)
end

function M.node_at_curpos()
  local root = vim.treesitter.get_parser(0):parse()[1]:root()
  local _, ln, col, _, _ = unpack(vim.fn.getcurpos())
  return root:named_descendant_for_range(ln-1, col-1, ln-1, col)
end

function M.nodelist_atcurs()
  local node = M.node_at_curpos()
  local names = {}
  -- local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()
  while node do
    table.insert(names, node:type())
    node = node:parent()
  end
  return names
end

function M.statusline()
  if not M.has_parser() then return '' end
  local names = M.nodelist_atcurs()
  if #names == 0 then return '' end

  local indicator_size = vim.api.nvim_win_get_width(0) / 2 - 10
  local stl = names[1]
  for i=2,#names do
    if (stl:len() + 2 * #names) >= indicator_size then
      stl = names[i]:sub(1,1) .. '➜' .. stl
    else
      stl = names[i] .. '➔' .. stl
    end
  end
  return stl
end

return M
