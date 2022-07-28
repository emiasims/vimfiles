local tslib = {}

local ts = vim.treesitter

function tslib.print_query(query, bufnr, lang, range)
  local qo
  bufnr = bufnr or 0
  lang = lang or tslib.ft_to_lang[vim.o.filetype] or vim.o.filetype
  range = range or {0, -1}
  if vim.startswith(query, '*') then
    qo = vim.treesitter.get_query(lang, query:sub(2))
  else
    qo = vim.treesitter.parse_query(vim.bo.filetype, query)
  end
  local root = vim.treesitter.get_parser(bufnr, lang):parse()[1]:root()
  local capture = {}
  P "Captures"
  for id, node, metadata in qo:iter_captures(root, bufnr, unpack(range)) do
    P { id, node:type(), { node:range() }, metadata }
    table.insert(capture, node)
  end
  P ""
  local i = 0
  for pat, match, metadata in qo:iter_matches(root, bufnr, unpack(range)) do
    i = i + 1
    P(string.format("Match: %s", i))
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
  -- local node = tslib.node_at_curpos()
  local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()
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

local function range_between(start_node, end_node)
  if not end_node then
    return start_node:range()
  end

  local sr, sc = start_node:start()
  local er, ec = end_node:end_()
  return sr, sc, er, ec
end

local function text_between(start_node, end_node, bufnr)
  local start_row, start_col, end_row, end_col = range_between(start_node, end_node)

  local lines
  local eof_row = vim.api.nvim_buf_line_count(bufnr)
  if start_row >= eof_row then
    return nil
  end

  if end_col == 0 then
    lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, true)
    end_col = -1
  else
    lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, true)
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

local function make_between(name)
  -- from neovim source, mostly
  if name == 'match' then
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
      local regex = compiled_vim_regexes[pred[4]]
      local text = text_between(match[pred[2]], match[pred[3]], bufnr)
      return regex:match_str(text)
    end
  elseif name == 'lua-match' then
    return function(match, _, bufnr, pred)
      local text = text_between(match[pred[2]], match[pred[3]], bufnr)
      return string.find(text, pred[4])
    end
  elseif name == 'eq' then
    return function(match, _, bufnr, pred)
      local text = text_between(match[pred[2]], match[pred[3]], bufnr)
      return pred[4] and text == pred[4]
    end
  elseif name == 'contains' then
    return function(match, _, bufnr, pred)
      local text = text_between(match[pred[2]], match[pred[3]], bufnr)

      for i = 4, #pred do
        if string.find(text, pred[i], 1, true) then
          return true
        end
      end
      return false
    end
  elseif name == 'any-of' then
    return function(match, _, bufnr, pred)
      local text = text_between(match[pred[2]], match[pred[3]], bufnr)
      local string_set = pred['string_set']
      if not string_set then
        string_set = {}
        for i = 3, #pred do
          string_set[pred[i]] = true
        end
        pred['string_set'] = string_set
      end

      return string_set[text]
    end
  end

end
vim.treesitter.add_predicate('match-across?', make_between('match'), true)
vim.treesitter.add_predicate('eq-across?', make_between('eq'), true)
vim.treesitter.add_predicate('contains-across?', make_between('contains'), true)
vim.treesitter.add_predicate('any-of-across?', make_between('any-of'), true)

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
  while vim.api.nvim_buf_get_lines(bufnr, end_line+1, end_line + 2, false)[1] == '' do
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

  while vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1] == '' do
    end_line = end_line - 1
  end

  metadata.range = { start_line, start_col, end_line, end_col }
  -- metadata[node:id()].content = {start_line, start_col, end_line, end_col}
end
vim.treesitter.query.add_directive('trim-nls!', trim_newlines, true)
vim.treesitter.query.add_directive('eat-nls!', eat_newlines, true)

local function merge(match, _, _, pred, metadata)
  local range = { range_between(match[pred[2]], match[pred[3]]) }
  if not pred[4] then
    metadata[pred[2]] = metadata[pred[2]] or {}
    metadata[pred[2]].range = range
  elseif type(pred[4]) == "number" then
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

function tslib.edit_query(opts)
  local lang, query = unpack(opts.fargs)
  if not query then
    query = lang
    lang = vim.o.filetype
  end
  local prefix = opts.bang and 'after/queries' or 'queries'
  local file = ('%s/%s/%s/%s.scm'):format(vim.fn.stdpath 'config', prefix, lang, query)
  vim.cmd('edit ' .. file)
end

local function query_complete(arglead, cmdline, _)
  -- local query_types = get a list of all query types?
  -- highlights, fold, spell
  local nwords = #vim.split(cmdline or '', ' ')
  if not cmdline or nwords == 2 then
    return vim.fn.getcompletion(arglead, 'filetype', 1)
  elseif nwords == 3 then
    return vim.tbl_filter(function(q)
      return q:find(arglead, 1, true)
    end, { 'folds', 'highlights', 'indents', 'injections', 'locals', 'spell' })
  end
  return {}
end

vim.api.nvim_create_user_command(
  'EditQuery',
  tslib.edit_query,
  { nargs = '+', complete = query_complete, bang = true, bar = true }
)

return tslib
