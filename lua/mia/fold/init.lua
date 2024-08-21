local Context = require('mia.fold.Context')
local ts = vim.treesitter

local M = {
  ---@type table<string, table<string, Fold.Text.Processor>>
  filetypes = setmetatable({}, {
    ---@return table<string, Fold.Text.Processor>|nil
    __index = function(_, ft)
      local ok, ftprocessors = pcall(require, 'mia.fold.' .. ft)
      if ok then
        return ftprocessors
      end
    end,
  }),
}

---@class HlRange
---@field offset integer
---@field len integer

-- using intercepts, offset, add_bytes
local Range = require('vim.treesitter._range')

---@overload fun(ctx: Fold.Context): Fold.Text.Highlights
---@overload fun(lnum: integer, bufnr: integer): Fold.Text.Highlights
---@overload fun(node: TSNode, bufnr: integer): Fold.Text.Highlights
function M.ts_chunks(ctx, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local range, root

  if type(ctx) == 'userdata' then
    root = ctx
    range = vim.treesitter.get_range(root, bufnr)
  else
    local lnum = (type(ctx) == 'number' and ctx or ctx.foldstart) - 1
    range = { lnum, 0, lnum, #vim.fn.getbufoneline(bufnr, lnum + 1) }
    range = Range.add_bytes(bufnr, range)
  end

  local parser = ts.get_parser(bufnr)
  local query = ts.query.get(parser:lang(), 'highlights')
  assert(query)

  local offset = range[3] - 1
  local text = table.concat(vim.api.nvim_buf_get_text(bufnr, range[1], range[2], range[4], range[5], {}), '\n')

  if not root then
    root = parser:parse({ range[1] - 1, range[4] + 2 })[1]:root()
  end

  ---@type { id: integer, conceal: string?, group: string, priority: integer, range: { [1]: integer, [2]: integer } }
  local highlights = {}

  ---@type { integer: table<integer,boolean> }
  local ids_per_char = {}
  for i = 1, range[6] - range[3] + 1 do
    ids_per_char[i] = {}
  end

  for id, node, metadata in query:iter_captures(root, 0, range[1], range[4] + 1) do
    local node_range = vim.treesitter.get_range(node, bufnr, metadata)

    if Range.intercepts(range, node_range) then
      local start_byte = (node_range[3] < range[3] and range[3] or node_range[3]) - offset
      local end_byte = (node_range[6] > range[6] and range[6] or node_range[6]) - offset - 1

      local hlid = #highlights + 1
      table.insert(highlights, {
        id = hlid,  -- for stabilizing sort
        conceal = metadata.conceal,
        group = '@' .. query.captures[id],
        priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter),
        range = { start_byte, end_byte },
      })

      for i = start_byte, end_byte do
        ids_per_char[i][hlid] = true
      end
    end
  end

  -- split into chunks with uniform ranges for highlighting
  ---@type { ids: table<integer, boolean>, range: { [1]: integer, [2]: integer } }
  local chunks = { { ids = ids_per_char[1], range = { 1, 1 } } }
  local current = chunks[1]
  for i = 2, #text do
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
      return a.priority < b.priority or (a.priority == b.priority and a.id < b.id)
    end)

    local conceal
    for ix, hl in ipairs(hls) do
      conceal = conceal or hl.conceal
      hls[ix] = hl.group
    end
    table.insert(result, { conceal or text:sub(chunk.range[1], chunk.range[2]), hls })
  end

  return result
end

---Remove newlines from chunks
---@param chunks Fold.Text.Highlights
function M.trim(chunks, repl)
  vim.tbl_map(function(chunk)
    chunk[1] = chunk[1]:gsub('\n', repl or '')
  end, chunks)
end

---Adds lines folded & foldlevel indicator
---@type Fold.Text.Processor
function M.default_foldtext(ctx)
  local result = ctx.foldtext
  if not result then
    result = M.ts_chunks(ctx)
  end

  table.insert(result, { ' ⋯ ', 'Comment' })

  local suffix = ('%s lines %s'):format(vim.v.foldend - vim.v.foldstart, ('|'):rep(vim.v.foldlevel))
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local vtWidth = 0
  for _, chunk in ipairs(result) do
    vtWidth = vtWidth + vim.fn.strdisplaywidth(chunk[1])
  end

  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local target = wininfo.width - wininfo.textoff - sufWidth

  if vtWidth < target then
    suffix = (' '):rep(target - vtWidth) .. suffix
  end
  table.insert(result, { suffix, 'Comment' })
  return result
end

function M.default_expr(ctx)
  local lnum = ctx.foldstart
  return vim.api.nvim_buf_call(ctx.bufnr, function()
    return vim.treesitter.foldexpr(lnum)
  end)
end

---@param ctx Fold.Context
---@return Fold.Text.Processor
function M.get_processor(ctx)
  local ft = M.filetypes[ctx:filetype()]
  return ft and (ft[ctx.node:type()] or ft.default) or M.default_foldtext
end

---@param ctx Fold.Context
function M.get_expr(ctx)
  local ft = M.filetypes[ctx:filetype()]
  return ft and ft.expr or vim.treesitter.foldexpr
end

function M.foldtext(...)
    local ctx = Context.new(...)
    return M.get_processor(ctx)(ctx)
  end

function M.foldexpr(...)
  local ctx = Context.new(...)
  return M.get_expr(ctx)(ctx)
end

M.text = function()
  local text = require('mia.fold.text')
  local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
  if text[ft] then
    return text[ft]()
  end
  return text['default']()
end

M.expr = function()
  local expr = require('mia.fold.expr')
  local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
  if expr[ft] then
    return expr[ft]()
  end
  return expr['default']()
end

return M
