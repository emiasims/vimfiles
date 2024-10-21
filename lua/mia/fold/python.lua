
---@type table<string, Fold.Text.Processor>
local M = {}

local Fold = require 'mia.fold'

---@type Fold.Text.Processor
function M.decorated_definition(ctx)
  -- local chunks = {}
  local decorators = vim.iter(ctx.node:iter_children()) -- node and name/type
  decorators:filter(function(node, type)
    return type == 'decorator'
  end)
  decorators:map(function(node)  -- ignoring name
    return Fold.ts_chunks(node, ctx.bufnr)
  end)

  ctx = ctx:update({ node = ctx.node:field('definition')[1] })
  local definition = vim.iter(M[ctx.node:type()](ctx))

  local first = definition:find(function(c)
    return not c[1]:match('^%s$')
  end)
  local chunks = decorators:totable()
  table.insert(chunks, {' '})
  table.insert(chunks, first)

  return vim.list_extend(chunks, definition:totable())
end

function M.function_definition(ctx)
  local parameters = ctx.node:field('parameters')[1]
  Fold.ts_chunks(parameters, ctx.bufnr)
  if parameters:start() == parameters:end_() then
    return Fold.ts_chunks(ctx)
  end
  local line = vim.api.nvim_buf_get_lines(ctx.bufnr, ctx.range[1], ctx.range[1] + 1, false)[1]
  ctx:update({ range = { end_line = ctx:start(), end_col = line:find('%(') - 1 } })
  return ctx:chunks() + ctx:chunks({ node = parameters })
end

return M
