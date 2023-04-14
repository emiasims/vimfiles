local default = require('ufo.decorator').defaultVirtTextHandler
return function(virtText, lnum, endLnum, width, truncate, ctx)
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
