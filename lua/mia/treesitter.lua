local M = {}

local ts = vim.treesitter

local function get_query_and_opts(query, opts)
  opts = vim.deepcopy(opts) or {}
  -- local verbose = opts.verbose
  opts.bufnr = opts.bufnr or 0
  opts.lang = opts.lang or ts.language.get_lang(vim.bo[opts.bufnr].filetype) or vim.bo[opts.bufnr].filetype
  opts.range = opts.range or { 0, -1 }
  if type(query) == 'string' and vim.startswith(query, '*') then
    query = vim.treesitter.query.get(opts.lang, query:sub(2))
  elseif type(query) == 'string' then
    query = vim.treesitter.query.parse(opts.lang, query)
  elseif not (type(query) == 'table' and query.captures and query.info) then
    error('What is that?')
  end
  opts.node = opts.node or vim.treesitter.get_parser(opts.bufnr, opts.lang):parse()[1]:root()
  return query, opts
end

function M.print_query(query, opts)
  M.print_captures(query, opts)
  print('\n')
  M.print_matches(query, opts)
end

function M.print_captures(query, opts)
  query, opts = get_query_and_opts(query, opts)
  P('Captures')
  for id, node, metadata in query:iter_captures(opts.node, opts.bufnr, unpack(opts.range)) do
    P({ query.captures[id], node:type(), { node:range() }, metadata })
  end
end

function M.print_matches(query, opts)
  query, opts = get_query_and_opts(query, opts)
  local i = 0
  for pat, match, md in query:iter_matches(opts.node, opts.bufnr, opts.range[1], opts.range[2], { all = true }) do
    i = i + 1
    P(string.format('Match: %s, id: %s', i, pat))
    for mid, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        P(mid, query.captures[mid], node:type(), { node:range() }, md[mid])
      end
    end
  end
end

function M.has_parser(lang)
  lang = lang or ts.language.get_lang(vim.o.filetype)
  return pcall(ts.language.inspect, lang)
end

function M.nodelist_atcurs()
  local node = ts.get_node({ ignore_injections = false })
  local names = {}
  while node do
    table.insert(names, node:type())
    node = node:parent()
  end
  return names
end

return M
