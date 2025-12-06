local M = {}

local ts = vim.treesitter
local api = vim.api

local Source = {}
M._sources = Source

--- @class mia.hl.region
--- @field source 'treesitter'|'lsp'|'syntax'
--- @field group string
--- @field open integer 0-based start column
--- @field close integer 0-based end column
--- @field priority integer
--- @field conceal? string character used for conceal

function M.exists(name)
  local hl = api.nvim_get_hl(0, { name = name, create = false })
  return not vim.tbl_isempty(hl)
end

--- @param bufnr integer
--- @param start_row integer 1-based
--- @param end_row integer 1-based
--- @return nil|fun(text: string, lnum: integer): mia.hl.region[]
function Source.ts(bufnr, start_row, end_row)
  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok or not parser then
    return
  end
  local tree = parser:parse({ start_row - 1, end_row })[1]
  local root = tree and tree:root()
  local query = ts.query.get(parser:lang(), 'highlights')

  if query and root then
    return function(text, lnum)
      local highlights = {}
      local cols = #text
      for id, node, metadata in query:iter_captures(root, bufnr, lnum - 1, lnum) do
        local name = '@' .. query.captures[id]
        if not M.exists(name) then
          local langname = name .. '.' .. parser:lang()
          if M.exists(langname) then
            name = langname
          end
        end
        local sr, sc, er, ec = ts.get_node_range(node)
        if sr <= lnum - 1 and er >= lnum - 1 then
          table.insert(highlights, {
            source = 'treesitter',
            group = name,
            open = (sr < lnum - 1) and 0 or sc,
            close = (er > lnum - 1) and cols or ec, -- FIXME
            priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter),
            conceal = metadata.conceal,
          })
        end
      end
      return highlights
    end
  end
end

--- @param bufnr integer
--- @return nil|fun(_, lnum: integer): mia.hl.region[]
function Source.lsp(bufnr)
  local ft = vim.bo[bufnr].filetype
  local priority = vim.highlight.priorities.semantic_tokens
  local typestr = '@lsp.type.%s.' .. ft
  local modstr = '@lsp.mod.%s.' .. ft
  local typemodstr = '@lsp.typemod.%s.' .. ft
  local lsp_hlr = require('vim.lsp.semantic_tokens').__STHighlighter
  local highlighter = lsp_hlr.active[bufnr]
  local client_states = highlighter and highlighter.client_state

  if client_states and #client_states > 0 then
    return function(_, line)
      local highlights = {}
      for _, client in pairs(client_states) do
        local tokens = vim
          .iter(client.current_result.highlights or {})
          :filter(function(hl)
            return hl.line == line - 1 and hl.marked
          end)
          :totable()
        for _, token in ipairs(tokens) do
          table.insert(highlights, {
            source = 'lsp',
            group = typestr:format(token.type),
            open = token.start_col,
            close = token.end_col,
            priority = priority,
          })

          for mod in pairs(token.modifiers or {}) do
            table.insert(highlights, {
              source = 'lsp',
              group = modstr:format(mod),
              open = token.start_col,
              close = token.end_col,
              priority = priority + 1,
            })

            table.insert(highlights, {
              source = 'lsp',
              group = typemodstr:format(token.type, mod),
              open = token.start_col,
              close = token.end_col,
              priority = priority + 2,
            })
          end
        end
      end
      return highlights
    end
  end
end

--- @param bufnr integer
--- @return nil|fun(_, lnum: integer): mia.hl.region[]
function Source.syntax(bufnr)
  if vim.bo[bufnr].syntax == '' then
    return
  end

  local priority = vim.highlight.priorities.syntax

  return function(_, lnum)
    local line = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1]
    local len = line and #line or 0
    local highlights = {}
    local current_group = nil
    local start_col = 0

    for col = 1, len do
      local syn_id = vim.fn.synID(lnum, col, 1)
      local group = vim.fn.synIDattr(vim.fn.synIDtrans(syn_id), 'name')

      if group ~= current_group then
        if current_group and current_group ~= '' then
          table.insert(highlights, {
            source = 'syntax',
            group = current_group,
            open = start_col,
            close = col - 1,
            priority = priority,
          })
        end
        current_group = group
        start_col = col - 1
      end
    end

    if current_group and current_group ~= '' then
      table.insert(highlights, {
        source = 'syntax',
        group = current_group,
        open = start_col,
        close = len,
        priority = priority,
      })
    end

    return highlights
  end
end

local function setup_collect(bufnr, start_row, end_row)
  local sources = {}
  table.insert(sources, Source.ts(bufnr, start_row, end_row) or nil)
  table.insert(sources, Source.lsp(bufnr) or nil)
  table.insert(sources, Source.syntax(bufnr) or nil)
  if #sources > 0 then
    return function(...)
      local highlights = {}
      for _, source in ipairs(sources) do
        table.insert(highlights, source(...))
      end
      return highlights
    end
  end
end

-- Helper to chunk a line segment based on collected highlights
local function chunk_highlights(line_segment, segment_len, hls, open, close)
  local highlights = {} -- Renamed from highlights_for_segment
  local ids_per_char = {} -- Renamed from ids_per_char_for_segment
  for i = 1, segment_len do
    ids_per_char[i] = {}
  end

  for _, grp in ipairs(hls) do
    for _, hl in ipairs(grp) do
      local intersect_start = math.max(hl.open, open)
      local intersect_end = math.min(hl.close, close)

      if intersect_start < intersect_end then
        local rel_start_col = math.max(0, intersect_start - open)
        local rel_end_col = math.min(segment_len, intersect_end - open)

        if rel_start_col < rel_end_col then
          local hlid = #highlights + 1
          table.insert(highlights, {
            id = hlid,
            group = hl.group,
            priority = hl.priority,
            conceal = hl.conceal,
            range = { rel_start_col, rel_end_col },
          })
          for i = rel_start_col + 1, rel_end_col do
            if ids_per_char[i] then
              ids_per_char[i][hlid] = true
            end
          end
        end
      end
    end
  end

  local chunks_for_line = {}
  local chunks_generated = false

  if segment_len > 0 and ids_per_char[1] then
    ---@type { ids: table<integer, boolean>, range: { [1]: integer, [2]: integer } }[]
    local chunks = { { ids = ids_per_char[1], range = { 1, 1 } } }
    local current_chunk = chunks[1]

    for i = 2, segment_len do
      local char_ids = ids_per_char[i]
      local current_ids = current_chunk.ids
      local new_chunk_needed = #current_ids ~= #char_ids
      if not new_chunk_needed then -- Check ids match exactly
        for id, _ in pairs(char_ids) do
          if not current_ids[id] then
            new_chunk_needed = true
            break
          end
        end
        if not new_chunk_needed then
          for id, _ in pairs(current_ids) do
            if not char_ids[id] then
              new_chunk_needed = true
              break
            end
          end
        end
      end

      if new_chunk_needed then
        table.insert(chunks, { ids = char_ids, range = { i, i } })
        current_chunk = chunks[#chunks]
      else
        current_chunk.range[2] = i
      end
    end

    -- Process generated chunks
    for _, chunk in ipairs(chunks) do
      chunks_generated = true
      local hls_in_chunk = {}
      for id, _ in pairs(chunk.ids) do
        if highlights[id] then
          table.insert(hls_in_chunk, highlights[id])
        end
      end
      table.sort(hls_in_chunk, function(a, b)
        return a.priority < b.priority or (a.priority == b.priority and a.id <= b.id)
      end)

      local conceal_char, groups = nil, {}
      for _, hl in ipairs(hls_in_chunk) do
        conceal_char = conceal_char or hl.conceal
        table.insert(groups, hl.group)
      end

      local chunk_start_rel, chunk_end_rel = chunk.range[1], chunk.range[2]
      if chunk_start_rel > 0 and chunk_end_rel >= chunk_start_rel and chunk_end_rel <= segment_len then
        local text = conceal_char or line_segment:sub(chunk_start_rel, chunk_end_rel)
        if #groups == 1 then
          table.insert(chunks_for_line, { text, groups[1] })
        elseif #groups > 1 then
          table.insert(chunks_for_line, { text, groups })
        else
          table.insert(chunks_for_line, { text })
        end
      end
    end
  end

  if not chunks_generated and segment_len > 0 then
    table.insert(chunks_for_line, { line_segment })
  end
  return chunks_for_line
end

---@param bufnr integer|nil Buffer handle, defaults to current buffer if 0 or nil.
---@param start_row integer 1-based start row of the range.
---@param start_col integer 0-based start column of the range.
---@param end_row integer 1-based end row of the range.
---@param end_col integer 0-based end column of the range.
---@param block? boolean Use block selection
---@return { [1]: string, [2]?: string|string[] }[][] Table of lines, each containing text chunks and optional highlight groups.
function M.extract(bufnr, start_row, start_col, end_row, end_col, block)
  bufnr = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()

  if start_col == nil or end_row == nil then
    start_col, end_row, end_col = 0, start_row, math.huge --[[@as integer]]
  end

  -- FIXME oob error
  local lines = api.nvim_buf_get_lines(bufnr, start_row - 1, end_row, false)

  local collect_hls = setup_collect(bufnr, start_row, end_row)

  if not lines or not collect_hls then
    return {}
  end

  local highlights = {}

  for lnum = start_row, end_row do
    local line = lines[lnum - start_row + 1]
    local open = math.max(0, (lnum == start_row) and start_col or 0)
    local close = math.min(#line, (lnum == end_row) and end_col or #line)
    if block then
      open, close = start_col, end_col
    end

    if open >= close then
      table.insert(highlights, {})
    else
      local line_segment = line:sub(open + 1, close)
      local segment_len = #line_segment

      if segment_len > 0 then
        local hls = collect_hls(line_segment, lnum)
        local chunks = chunk_highlights(line_segment, segment_len, hls, open, close)
        table.insert(highlights, chunks)
      end
    end
  end

  if start_row < end_row and end_col == 0 then
    highlights[#highlights] = nil
  end

  return start_row == end_row and highlights[1] or highlights
end

--- @return { tressitter?: mia.hl.region[], lsp?: mia.hl.region[], syntax?: mia.hl.region[] }
function M.at_cursor()
  local bufnr = api.nvim_get_current_buf()
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
  local collect = assert(setup_collect(bufnr, row, row))
  local hls = collect(line, row)
  return vim
    .iter(hls)
    :flatten(1)
    :filter(function(hl)
      return hl.open <= col and hl.close >= col
    end)
    :fold({}, function(t, hl)
      t[hl.source] = t[hl.source] or {}
      table.insert(t[hl.source], hl)
      hl.source = nil
      return t
    end)
end

return M
