local M = {}

-- Cache on ts changes
-- Add elements with priority to a list : remove lowest prio on too smol

local ts = vim.treesitter
local api = vim.api
local lsp_hlr = require('vim.lsp.semantic_tokens').__STHighlighter

---@return { [1]: string, [2]: string[] }[]
function M.tsfoldtext(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  bufnr = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()

  ---@type boolean, vim.treesitter.LanguageTree
  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  local query = ts.query.get(parser:lang(), 'highlights')
  if not query then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  local tree = parser:parse({ lnum - 1, lnum })[1]

  local line = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if not line or line:match('^%s*$') then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  ---@type { id: integer, conceal: string?, group: string, priority: integer, range: { [1]: integer, [2]: integer } }
  local highlights = {}
  ---@type { integer: table<integer,boolean> }
  local ids_per_char = {}
  for i = 1, #line do
    ids_per_char[i] = {}
  end

  local add = function(hl, sc, ec, prio, conceal)
    local hlid = #highlights + 1
    table.insert(highlights, {
      id = hlid, -- for stabilizing sort
      conceal = conceal,
      group = hl,
      priority = prio,
      range = { sc, ec },
    })

    for i = sc + 1, ec do
      ids_per_char[i][hlid] = true
    end
  end

  for id, node, metadata in query:iter_captures(tree:root(), 0, lnum - 1, lnum) do
    local name = query.captures[id]
    local start_row, start_col, _, end_row, end_col =
      unpack(vim.treesitter.get_range(node, bufnr, metadata))
    local priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter)

    if start_row <= lnum - 1 and end_row >= lnum - 1 then
      start_col = start_row < lnum - 1 and 0 or start_col
      end_col = end_row > lnum - 1 and #line or end_col
      add('@' .. name, start_col, end_col, priority, metadata.conceal)
    end
  end

  -- split into chunks with uniform ranges for highlighting
  ---@type { ids: table<integer, boolean>, range: { [1]: integer, [2]: integer } }
  local chunks = { { ids = ids_per_char[1], range = { 1, 1 } } }
  local current = chunks[1]
  for i = 2, #line do
    -- if the # of hls is different, obviously a different chunk
    local new_chunk = #current.ids ~= #ids_per_char[i]
    -- otherwise, make sure the ids are the same
    for id, _ in pairs(ids_per_char[i]) do
      if new_chunk then
        break
      end
      new_chunk = new_chunk or not current.ids[id]
    end

    if new_chunk then
      -- start a new chunk when we need to
      table.insert(chunks, { ids = ids_per_char[i], range = { i, i } })
      current = chunks[#chunks]
    else
      -- after verifying, just increase the range of the chunk
      current.range[2] = i
    end
  end

  ---@type { [1]: string, [2]: string[] }[]
  local result = {}

  -- sort chunk hls by priority and apply conceal or get chunk text
  for _, chunk in ipairs(chunks) do
    local hls = {}
    for id, _ in pairs(chunk.ids) do
      table.insert(hls, highlights[id])
    end

    table.sort(hls, function(a, b)
      -- id keeps the insertion order stable - table.sort is not a stable sort
      return a.priority < b.priority or (a.priority == b.priority and a.id <= b.id)
    end)

    local conceal
    for ix, hl in ipairs(hls) do
      conceal = conceal or hl.conceal
      hls[ix] = hl.group
    end
    local text = conceal or line:sub(chunk.range[1], chunk.range[2])
    table.insert(result, { text, hls })
  end

  return result
end

function M.ts_lsp_chunks(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  bufnr = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()

  ---@type boolean, vim.treesitter.LanguageTree
  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  local query = ts.query.get(parser:lang(), 'highlights')
  if not query then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  local tree = parser:parse({ lnum - 1, lnum })[1]

  local line = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if not line or line:match('^%s*$') then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  ---@type { id: integer, conceal: string?, group: string, priority: integer, range: { [1]: integer, [2]: integer } }
  local highlights = {}
  ---@type { integer: table<integer,boolean> }
  local ids_per_char = {}
  for i = 1, #line do
    ids_per_char[i] = {}
  end

  local add = function(hl, sc, ec, prio, conceal)
    local hlid = #highlights + 1
    table.insert(highlights, {
      id = hlid, -- for stabilizing sort
      conceal = conceal,
      group = hl,
      priority = prio,
      range = { sc, ec },
    })

    for i = sc + 1, ec do
      ids_per_char[i][hlid] = true
    end
  end

  for id, node, metadata in query:iter_captures(tree:root(), 0, lnum - 1, lnum) do
    local name = query.captures[id]
    local start_row, start_col, _, end_row, end_col =
      unpack(vim.treesitter.get_range(node, bufnr, metadata))
    local priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter)

    if start_row <= lnum - 1 and end_row >= lnum - 1 then
      start_col = start_row < lnum - 1 and 0 or start_col
      end_col = end_row > lnum - 1 and #line or end_col
      add('@' .. name, start_col, end_col, priority, metadata.conceal)
    end
  end

  -- semantic tokens
  local ft = vim.bo[bufnr].filetype
  local p = vim.highlight.priorities.semantic_tokens

  local Formatter = function(string)
    string = string .. '.' .. ft
    return function(...)
      return string:format(...)
    end
  end

  local tfmt = Formatter('@lsp.type.%s')
  local mfmt = Formatter('@lsp.mod.%s')
  local tmfmt = Formatter('@lsp.typemod.%s.%s')

  local highlighter = lsp_hlr.active[bufnr]
  if highlighter and highlighter.client_state then
    for _, client in pairs(highlighter.client_state) do
      local tokens = vim
        .iter(client.current_result.highlights or {})
        :filter(function(hl)
          return hl.line == lnum - 1 and hl.marked
        end)
        :totable()

      if highlights then
        for _, token in ipairs(tokens) do
          -- see vim/lsp/semantic_tokens.lua  :on_win func
          add(tfmt(token.type), token.start_col, token.end_col, p)
          for mod in pairs(token.modifiers or {}) do
            add(mfmt(mod), token.start_col, token.end_col, p + 1)
            add(tmfmt(token.type, mod), token.start_col, token.end_col, p + 2)
          end
        end
      end
    end
  end

  -- split into chunks with uniform ranges for highlighting
  ---@type { ids: table<integer, boolean>, range: { [1]: integer, [2]: integer } }
  local chunks = { { ids = ids_per_char[1], range = { 1, 1 } } }
  local current = chunks[1]
  for i = 2, #line do
    -- if the # of hls is different, obviously a different chunk
    local new_chunk = #current.ids ~= #ids_per_char[i]
    -- otherwise, make sure the ids are the same
    for id, _ in pairs(ids_per_char[i]) do
      if new_chunk then
        break
      end
      new_chunk = new_chunk or not current.ids[id]
    end

    if new_chunk then
      -- start a new chunk when we need to
      table.insert(chunks, { ids = ids_per_char[i], range = { i, i } })
      current = chunks[#chunks]
    else
      -- after verifying, just increase the range of the chunk
      current.range[2] = i
    end
  end

  ---@type { [1]: string, [2]: string[] }[]
  local result = {}

  -- sort chunk hls by priority and apply conceal or get chunk text
  for _, chunk in ipairs(chunks) do
    local hls = {}
    for id, _ in pairs(chunk.ids) do
      table.insert(hls, highlights[id])
    end

    table.sort(hls, function(a, b)
      -- id keeps the insertion order stable - table.sort is not a stable sort
      return a.priority < b.priority or (a.priority == b.priority and a.id <= b.id)
    end)

    local conceal
    for ix, hl in ipairs(hls) do
      conceal = conceal or hl.conceal
      hls[ix] = hl.group
    end
    local text = conceal or line:sub(chunk.range[1], chunk.range[2])
    table.insert(result, { text, hls })
  end

  return result
end

function M.default(foldtext, bufnr)
  if type(foldtext) ~= 'table' then
    foldtext = M.ts_lsp_chunks(foldtext, bufnr)
  end

  if type(foldtext) == 'string' then
    foldtext = { { foldtext, 'Folded' } }
  end
  table.insert(foldtext, { ' ⋯ ', 'Comment' })

  local suffix = ('%s lines %s'):format(vim.v.foldend - vim.v.foldstart, ('|'):rep(vim.v.foldlevel))
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local vtWidth = 0
  for _, chunk in ipairs(foldtext) do
    vtWidth = vtWidth + vim.fn.strdisplaywidth(chunk[1])
  end

  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local target = wininfo.width - wininfo.textoff - sufWidth

  if vtWidth < target then
    suffix = (' '):rep(target - vtWidth) .. suffix
  end
  table.insert(foldtext, { suffix, 'Comment' })
  return foldtext
end

function M.org()
  local foldtext
  if vim.v.foldstart == 1 and vim.fn.getline(1):match('^%s*#%+[tT][iI][tT][lL][eE]:') then
    foldtext = M.ts_lsp_chunks(1)
    foldtext = { foldtext[#foldtext] }
  end

  foldtext = M.default(foldtext)

  local heart = vim.iter(foldtext):find(function(t)
    return t[1] == '❤'
  end)
  if heart then
    heart[1] = '❥'
  end

  return foldtext
end

function M.help(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  if lnum > 1 then
    lnum = lnum + 1
  end
  return M.default(M.ts_lsp_chunks(lnum, bufnr))
end

function M.python(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  bufnr = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()
  local foldtext = M.ts_lsp_chunks()
  local text = vim.fn.getbufoneline(bufnr, lnum) --[[@as string]]

  -- Process decorated functions
  if text:match('^%s*@') then
    local pos = { lnum - 1, #vim.fn.getbufline(bufnr, lnum)[1] - 1 }
    local decorator = vim.treesitter.get_node({ bufnr = bufnr, pos = pos })
    while decorator and decorator:type() ~= 'decorated_definition' do
      decorator = decorator:parent()
    end
    if not decorator then
      return M.default(foldtext)
    end

    local line = decorator:field('definition')[1]:start()
    local new_foldtext = M.ts_lsp_chunks(line + 1)
    while #new_foldtext > 0 and new_foldtext[1][1]:match('^%s+$') do
      table.remove(new_foldtext, 1)
    end
    new_foldtext[1][1] = ' ' .. new_foldtext[1][1]
    vim.list_extend(foldtext, new_foldtext)

    -- Process decorated functions
  elseif text:match('^%s*class') then
    local pos = { lnum - 1, #vim.fn.getbufline(bufnr, lnum)[1] - 1 }
    local class = vim.treesitter.get_node({ bufnr = bufnr, pos = pos })
    while class and class:type() ~= 'class_definition' do
      class = class:parent()
    end
    if not class then
      return M.default(foldtext)
    end

    local params
    for node in class:field('body')[1]:iter_children() do
      if
        node:type() == 'function_definition'
        and vim.treesitter.get_node_text(node:field('name')[1], bufnr):match('__init__')
      then
        params = node:field('parameters')[1]
        break
      end
    end
    if not params then
      return M.default(foldtext)
    end
    local matcher = function(char)
      return function(chunk)
        return chunk[1] == char
      end
    end

    -- local it_ft = vim.iter(require('mia.fold').ts_chunks(params, bufnr))
    -- local it_ft = vim.iter(P(require('mia.fold').ts_chunks(params:start() + 1, bufnr)))
    local it_ft = vim.iter(M.ts_lsp_chunks(params:start() + 1, bufnr))
    local open = it_ft:find(matcher('('))
    local close = it_ft:rfind(matcher(')'))
    if not (open and close) then
      return M.default(foldtext)
    end

    if it_ft:peek() and it_ft:peek()[1] == 'self' then
      it_ft:next()
      while it_ft:peek() and (it_ft:peek()[1]:match('^%s*,%s*$') or it_ft:peek()[1]:match('^%s$')) do
        it_ft:next()
      end
    end
    local args = it_ft:totable()

    local semi = table.remove(foldtext)
    table.insert(foldtext, open)
    vim.list_extend(foldtext, args)
    table.insert(foldtext, close)
    table.insert(foldtext, semi)
  elseif text:match('^%s*"""%s*$') then
    local nb = vim.api.nvim_buf_call(bufnr, function()
      return vim.fn.nextnonblank(lnum + 1)
    end)
    local docline = vim.fn.getbufline(bufnr, nb)[1]:match('^%s*(%S.*)')
    local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
    local target = wininfo.width - wininfo.textoff - 11 - 15
    docline = table.concat(
      vim.iter(docline:gmatch('%S*')):fold({ len = 0, text = {} }, function(t, s)
        if s == '' then
        elseif t.len + #s > target then
          t.len = 9000
        else
          t.len = t.len + #s
          table.insert(t.text, s)
        end
        return t
      end).text,
      ' '
    )
    table.insert(foldtext, { ' ' })
    table.insert(foldtext, { docline, 'String' })
  end

  return M.default(foldtext)
end

return M
