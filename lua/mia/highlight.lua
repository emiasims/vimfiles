local ts = vim.treesitter
local api = vim.api

local function resolve_hl(name)
  if name then
    local hlid = api.nvim_get_hl_id_by_name(name)
    return vim.fn.synIDattr(vim.fn.synIDtrans(hlid), 'name')
  end
end

-- gives complete highlight info in the range for a single row
---@return {hl_groups:{hl_group:string,hl_group_link?:string,ns_id?:integer,source:string,priority:integer,conceal?:string}[],buffer:integer,col:integer,row:integer,text:string}[]
local function inspect_range(bufnr, lnum, start_col, end_col)
  lnum = lnum - 1
  bufnr = vim._resolve_bufnr(bufnr)
  local line = api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, true)[1]
  start_col = start_col or 0
  end_col = end_col or #line

  local items = {}
  local function add(sr, sc, er, ec, hl, source, priority, conceal)
    table.insert(items, {
      sc = math.max(start_col, sr < lnum and 0 or sc),
      ec = math.min(end_col, er > lnum and #line or ec),
      data = {
        hl_group = hl,
        hl_group_link = resolve_hl(hl),
        source = source,
        priority = priority or vim.highlight.priorities[source],
        conceal = conceal,
      },
    })
  end

  -- treesitter
  local ok, parser = pcall(ts.get_parser, bufnr)
  if ok and parser then
    parser:for_each_tree(function(_, tree)
      local query = ts.query.get(tree:lang(), 'highlights')
      if not query then
        return
      end
      local root = tree:parse()[1]:root()
      for id, node, metadata in query:iter_captures(root, bufnr, lnum, lnum + 1) do
        local sr, sc, er, ec = node:range()
        local name = '@' .. query.captures[id] .. '.' .. tree:lang()
        add(sr, sc, er, ec, name, 'treesitter', metadata.priority, metadata.conceal)
      end
    end)
  end

  -- extmarks & lsp
  local ns_map = {}
  for name, id in pairs(api.nvim_get_namespaces()) do
    ns_map[id] = name
  end

  local extmarks = api.nvim_buf_get_extmarks(
    bufnr,
    -1,
    { lnum, start_col },
    { lnum, end_col },
    { details = true }
  )
  for _, item in ipairs(extmarks) do
    local _, sr, sc, details = unpack(item)
    if details.hl_group then
      local ns_name = ns_map[details.ns_id] or ''
      local source = ns_name:find('nvim.lsp.semantic_tokens') == 1 and 'semantic_token' or 'extmark'
      local ec, er = details.end_col or sc, details.end_row or sr
      add(sr, sc, er, ec, details.hl_group, source, details.priority, details.conceal)
    end
  end

  -- syntax
  if vim.bo[bufnr].syntax ~= '' then
    if vim.bo[bufnr].syntax ~= '' then
      local current
      local sc = start_col
      for ec = start_col, end_col - 1 do
        local syn_id = vim.fn.synID(lnum + 1, ec + 1, 1)
        local name = vim.fn.synIDattr(vim.fn.synIDtrans(syn_id), 'name')
        if name ~= current then
          if current then
            add(lnum, sc, lnum, ec, current, 'syntax')
          end
          current = name
          sc = ec
        end
      end
      if current then
        add(lnum, sc, lnum, end_col, current, 'syntax')
      end
    end
  end

  -- flatten segments
  local boundaries = { [start_col] = true, [end_col] = true }
  for _, item in ipairs(items) do
    if item.sc >= start_col and item.sc <= end_col then
      boundaries[item.sc] = true
    end
    if item.ec >= start_col and item.ec <= end_col then
      boundaries[item.ec] = true
    end
  end

  local points = vim.tbl_keys(boundaries)
  table.sort(points)

  local results = {}
  for i = 1, #points - 1 do
    local p_start, p_end = points[i], points[i + 1]
    local text = line:sub(p_start + 1, p_end)

    if #text > 0 then
      local hl_groups = {}
      for _, item in ipairs(items) do
        -- Check if the item fully covers this segment
        if item.sc <= p_start and item.ec >= p_end then
          table.insert(hl_groups, item.data)
        end
      end

      table.insert(results, {
        buffer = bufnr,
        col = p_start,
        row = lnum,
        text = text,
        hl_groups = hl_groups,
      })
    end
  end

  return results
end

-- gives the visible highlights in the range in chunks
--- @return { [1]: string, [2]?: string|string[] }[][] Table of lines, each containing text chunks and optional highlight groups.
local function extract_range(bufnr, lnum, start_col, end_col)
  local segments = inspect_range(bufnr, lnum, start_col, end_col)
  local chunks = {}
  for _, segment in ipairs(segments) do
    local chunk = { segment.text, {} }
    local hl_groups = segment.hl_groups
    table.sort(hl_groups, function(a, b)
      return a.priority < b.priority
    end)
    for _, hl in ipairs(hl_groups) do
      table.insert(chunk[2], hl.hl_group_link or hl.hl_group)
    end
    table.insert(chunks, chunk)
  end
  return chunks
end

return {
  extract = extract_range,
  inspect = inspect_range,
}
