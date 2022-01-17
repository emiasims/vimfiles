local tslib = {}

local ts = vim.treesitter

function tslib.print_query(query, bufnr, lang)
  local qo
  lang = lang or tslib.ft_to_lang[vim.o.filetype] or vim.o.filetype
  if vim.startswith(query, '*') then
    qo = vim.treesitter.get_query(lang, query:sub(2))
  else
    qo = vim.treesitter.parse_query(vim.bo.filetype, query)
  end
  local root = vim.treesitter.get_parser(bufnr or 0, lang):parse()[1]:root()
  local capture = {}
  P "Captures"
  for _, node, metadata in qo:iter_captures(root, 0, 0, -1) do
    P { node:type(), { node:range() }, metadata }
    table.insert(capture, node)
  end
  P ""
  P "Matches"
  for pat, match, metadata in qo:iter_matches(root, 0, 0, -1) do
    for id, node in pairs(match) do
      P { pat, id, qo.captures[id], { node:range() }, metadata[id] }
    end
  end
end

tslib.ft_to_lang = {
  py = 'python',
  sh = 'bash',
  js = 'javascript',
}

function tslib.has_parser(lang)
  lang = lang or tslib.ft_to_lang[vim.o.filetype] or vim.o.filetype
  return pcall(ts.inspect_language, lang)
end

function tslib.node_at_curpos()
  local root = vim.treesitter.get_parser(0):parse()[1]:root()
  local _, ln, col, _, _ = unpack(vim.fn.getcurpos())
  return root:named_descendant_for_range(ln - 1, col - 1, ln - 1, col)
end

function tslib.nodelist_atcurs()
  local node = tslib.node_at_curpos()
  local names = {}
  -- local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()
  while node do
    table.insert(names, node:type())
    node = node:parent()
  end
  return names
end

function tslib.statusline()
  if not tslib.has_parser() then
    return ''
  end
  local names = tslib.nodelist_atcurs()
  if #names == 0 then
    return ''
  end

  local indicator_size = vim.api.nvim_win_get_width(0) / 2 - 10
  local stl = names[1]
  for i = 2, #names do
    if (stl:len() + 2 * #names) >= indicator_size then
      stl = names[i]:sub(1, 1) .. '➜' .. stl
    else
      stl = names[i] .. '➔' .. stl
    end
  end
  return stl
end

return tslib
