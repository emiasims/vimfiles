local tslib = {}

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
    error 'What is that?'
  end
  opts.node = opts.node or vim.treesitter.get_parser(opts.bufnr, opts.lang):parse()[1]:root()
  return query, opts
end

function tslib.print_query(query, opts)
  tslib.print_captures(query, opts)
  print '\n'
  tslib.print_matches(query, opts)
end

function tslib.print_captures(query, opts)
  query, opts = get_query_and_opts(query, opts)
  P 'Captures'
  for id, node, metadata in query:iter_captures(opts.node, opts.bufnr, unpack(opts.range)) do
    P { id, node:type(), { node:range() }, metadata }
  end
end

function tslib.print_matches(query, opts)
  query, opts = get_query_and_opts(query, opts)
  local i = 0
  for pat, match, metadata in query:iter_matches(opts.node, opts.bufnr, unpack(opts.range)) do
    i = i + 1
    P(string.format('Match: %s', i))
    for id, node in pairs(match) do
      if opts.verbose or not vim.startswith(query.captures[id], '_') then
        P { pat, id, query.captures[id], { node:range() }, metadata[id] }
      end
    end
  end
end

function tslib.has_parser(lang)
  lang = lang or ts.language.get_lang(vim.o.filetype)
  return pcall(ts.language.inspect, lang)
end

function tslib.nodelist_atcurs()
  local node = ts.get_node { ignore_injections = false }
  local names = {}
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

  local indicator_size = nvim.win_get_width(0) / 2 - 10
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

local function range_between(start_node, end_node)
  if not end_node then
    return start_node:range()
  end

  local sr, sc = start_node:start()
  local er, ec = end_node:end_()
  return sr, sc, er, ec
end

local function text_between(start_node, end_node, bufnr)
  if not start_node then
    return ''
  end
  local start_row, start_col, end_row, end_col = range_between(start_node, end_node)

  local lines
  local eof_row = nvim.buf_line_count(bufnr)
  if start_row >= eof_row then
    return nil
  end

  if end_col == 0 then
    lines = nvim.buf_get_lines(bufnr, start_row, end_row, true)
    end_col = -1
  else
    lines = nvim.buf_get_lines(bufnr, start_row, end_row + 1, true)
  end

  if #lines > 0 then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col + 1, end_col)
    else
      lines[1] = string.sub(lines[1], start_col + 1)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
  end
  return table.concat(lines, '\n')
end

local magic_prefixes = { ['\\v'] = true, ['\\m'] = true, ['\\M'] = true, ['\\V'] = true }

local function check_magic(str)
  if string.len(str) < 2 or magic_prefixes[string.sub(str, 1, 2)] then
    return str
  end
  return '\\v' .. str
end

local compiled_vim_regexes = setmetatable({}, {
  __index = function(t, pattern)
    local res = vim.regex(check_magic(pattern))
    rawset(t, pattern, res)
    return res
  end,
})

local across = {
  match = function(match, _, bufnr, pred)
    if not match[pred[2]] then return true end
    local regex = compiled_vim_regexes[pred[4]]
    local text = text_between(match[pred[2]], match[pred[3]], bufnr)
    return regex:match_str(text)
  end,

  lua_match = function(match, _, bufnr, pred)
    if not match[pred[2]] then return true end
    local text = text_between(match[pred[2]], match[pred[3]], bufnr)
    return string.find(text, pred[4])
  end,

  eq = function(match, _, bufnr, pred)
    if not match[pred[2]] then return true end
    local text = text_between(match[pred[2]], match[pred[3]], bufnr)
    return string.find(text, pred[4], 1, true)
  end,

  contains = function(match, _, bufnr, pred)
    if not match[pred[2]] then return true end
    local text = text_between(match[pred[2]], match[pred[3]], bufnr)
    if text == '' then return false end

    for i = 4, #pred do
      if string.find(text, pred[i], 1, true) then
        return true
      end
    end
    return false
  end,

  any_of = function(match, _, bufnr, pred)
    if not match[pred[2]] then return true end
    local text = text_between(match[pred[2]], match[pred[3]], bufnr)
    if not pred.string_set then
      pred.string_set = {}
      for i = 3, #pred do
        pred.string_set[pred[i]] = true
      end
    end
    return pred.string_set[text]
  end,
}

vim.treesitter.query.add_predicate('match-across?', across.match, true)
vim.treesitter.query.add_predicate('lua-match-across?', across.lua_match, true)
vim.treesitter.query.add_predicate('eq-across?', across.eq, true)
vim.treesitter.query.add_predicate('contains-across?', across.contains, true)
vim.treesitter.query.add_predicate('any-of-across?', across.any_of, true)
vim.treesitter.query.add_directive('print!', P, true)

local function eat_newlines(match, _, bufnr, pred, metadata)
  -- handler(match, pattern, bufnr, predicate, metadata)
  local capture_id = pred[2]
  local max = pred[3] and tonumber(pred[3])
  local node = match[capture_id]
  local start_line, start_col, end_line, end_col = node:range()

  if not metadata[capture_id] then
    metadata[capture_id] = {}
  end
  metadata = metadata[capture_id]

  if metadata.range then
    start_line, start_col, end_line, end_col = unpack(metadata.range)
  end

  local eaten = 0
  while nvim.buf_get_lines(bufnr, end_line + 1, end_line + 2, false)[1] == '' do
    eaten = eaten + 1
    if max and eaten > max then
      break
    end
    end_line = end_line + 1
  end

  metadata.range = { start_line, start_col, end_line, end_col }
  -- metadata[node:id()].content = {start_line, start_col, end_line, end_col}
end

local function trim_newlines(match, _, bufnr, pred, metadata)
  -- handler(match, pattern, bufnr, predicate, metadata)
  local capture_id = pred[2]
  local node = match[capture_id]
  local start_line, start_col, end_line, end_col = node:range()

  if not metadata[capture_id] then
    metadata[capture_id] = {}
  end
  metadata = metadata[capture_id]

  if metadata.range then
    start_line, start_col, end_line, end_col = unpack(metadata.range)
  end

  while nvim.buf_get_lines(bufnr, end_line, end_line + 1, false)[1] == '' do
    end_line = end_line - 1
  end

  metadata.range = { start_line, start_col, end_line, end_col }
  -- metadata[node:id()].content = {start_line, start_col, end_line, end_col}
end
vim.treesitter.query.add_directive('trim-nls!', trim_newlines, true)
vim.treesitter.query.add_directive('eat-nls!', eat_newlines, true)

local function merge(match, _, _, pred, metadata)
  if not match[pred[2]] then
    return
  end
  local range = { range_between(match[pred[2]], match[pred[3]]) }
  if not pred[4] then
    metadata[pred[2]] = metadata[pred[2]] or {}
    metadata[pred[2]].range = range
  elseif type(pred[4]) == 'number' then
    if pred[4] ~= pred[2] and pred[4] ~= pred[3] then
      error 'last arg needs to one of the preivous nodes or a matadata name'
    end
    metadata[pred[4]] = metadata[pred[4]] or {}
    metadata[pred[4]].range = range
  else
    metadata[pred[4]] = range
  end
end
vim.treesitter.query.add_directive('merge-across!', merge, true)

local function predicate(pre)
  local magic_prefixes = { ['\\v'] = true, ['\\m'] = true, ['\\M'] = true, ['\\V'] = true }
  local function check_magic(str)
    if string.len(str) < 2 or magic_prefixes[string.sub(str, 1, 2)] then
      return str
    end
    return '\\v' .. str
  end

  local compiled_vim_regexes = setmetatable({}, {
    __index = function(t, pattern)
      local res = vim.regex(check_magic(pattern))
      rawset(t, pattern, res)
      return res
    end,
  })
  return function(match, _, bufnr, pred)
    local node = match[pred[2]]
    local char
    if pre then
      local lnum, col = node:range()
      if col == 0 then
        return true
      end
      char = nvim.buf_get_lines(bufnr, lnum, lnum + 1, true)[1]
      char = string.sub(char, col, col)
    else
      local _, _, lnum, col = node:range()
      char = nvim.buf_get_lines(bufnr, lnum, lnum + 1, true)[1]
      if col == #char then
        return true
      end
      char = string.sub(char, col + 1, col + 1)
    end
    local regex = compiled_vim_regexes[pred[3]]
    return regex:match_str(char)
  end
end
vim.treesitter.query.add_predicate('prev-char-match?', predicate(true), true)
vim.treesitter.query.add_predicate('next-char-match?', predicate(false), true)

return tslib
