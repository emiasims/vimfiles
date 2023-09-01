local M = {}

local default = require 'ufo.decorator'.defaultVirtTextHandler

function M.default(virtText, lnum, endLnum, width, truncate, ctx)
  local newVirtText = default(virtText, lnum, endLnum, width, truncate, ctx)
  local suffix = ('%s lines %s'):format(endLnum - lnum, ('|'):rep(vim.fn.foldlevel(lnum)))
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local vtWidth = 0
  for _, chunk in ipairs(virtText) do
    vtWidth = vtWidth + vim.fn.strdisplaywidth(chunk[1])
  end
  local target = width - sufWidth - ((vim.o.number and 1 or 0) * vim.o.numberwidth)
  if vtWidth < target then
    suffix = (' '):rep(target - vtWidth) .. suffix
    table.insert(newVirtText, { suffix, 'UfoFoldedEllipsis' })
  end
  return newVirtText
end

function M.org(virtText, lnum, endLnum, width, truncate, ctx)
  local newVirtText = M.default(virtText, lnum, endLnum, width, truncate, ctx)

  for _, chunk in ipairs(newVirtText) do
    if chunk[1] == '❤' then
      chunk[1] = '❥'  -- U+2765
    end
  end

  return newVirtText
end

function M.python(virtText, lnum, endLnum, width, truncate, ctx)
  if ctx.text:match '^%s*@' then
    local pos = { lnum - 1, #vim.fn.getbufline(ctx.bufnr, lnum)[1] - 1 }
    local decorator = vim.treesitter.get_node { bufnr = ctx.bufnr, pos = pos }
    while decorator:type() ~= 'decorated_definition' do
      decorator = decorator:parent()
    end
    local line = decorator:field 'definition'[1]:start()
    local newVirtText = ctx.get_fold_virt_text(line + 1)
    while #newVirtText > 0 and newVirtText[1][1]:match '^%s+$' do
      table.remove(newVirtText, 1)
    end
    newVirtText[1][1] = ' ' .. newVirtText[1][1]
    vim.list_extend(virtText, newVirtText)
  end
  return M.default(virtText, lnum, endLnum, width, truncate, ctx)
end

return M
