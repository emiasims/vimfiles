local M = {}

local ts = vim.treesitter
local api = vim.api

local Source = {}

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
        local name = query.captures[id]
        local sr, sc, er, ec = ts.get_node_range(node)
        if sr <= lnum - 1 and er >= lnum - 1 then
          table.insert(highlights, {
            group = '@' .. name,
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
            group = typestr:format(token.type),
            open = token.start_col,
            close = token.end_col,
            priority = priority,
          })

          for mod in pairs(token.modifiers or {}) do
            table.insert(highlights, {
              group = modstr:format(mod),
              open = token.start_col,
              close = token.end_col,
              priority = priority + 1,
            })

            table.insert(highlights, {
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

function Source.syntax(bufnr, _, _)
end

local function setup_collect(bufnr, start_row, end_row)
  local sources = {}
  table.insert(sources, Source.ts(bufnr, start_row, end_row) or nil)
  table.insert(sources, Source.lsp(bufnr, start_row, end_row) or nil)
  table.insert(sources, Source.syntax(bufnr, start_row, end_row) or nil)
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

---@param bufnr number|nil Buffer handle, defaults to current buffer if 0 or nil.
---@param start_row number 1-based start row of the range.
---@param start_col number 0-based start column of the range.
---@param end_row number 1-based end row of the range.
---@param end_col number 0-based end column of the range.
---@return { [1]: string, [2]?: string|string[] }[][] Table of lines, each containing text chunks and optional highlight groups.
function M.extract(bufnr, start_row, start_col, end_row, end_col, block)
  bufnr = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()

  if start_col == nil or end_row == nil then
    start_col, end_row, end_col = 0, start_row, math.huge
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

-- P(M.extract(2, 3, 0, 4, 4, true))
-- P(M.extract(2, 3, 0, 4, math.huge))
-- P(M.extract(2, 3, 0, 3, math.huge))
-- P(M.extract(2, 251, 0, 251, 61))

return M
