local ts = vim.treesitter
local Range = require('vim.treesitter._range')
local api = vim.api




local function compute_text_and_levels(bufnr, info, srow, erow, parse_injections)
  srow = srow or 0
  erow = erow or api.nvim_buf_line_count(bufnr)

  local parser = ts.get_parser(bufnr)
  mia.stash['fold.compute_folds_levels'](bufnr, info, srow, erow, parse_injections)
  parser:for_each_tree(function(tree, ltree)
    local query = ts.query.get(ltree:lang(), 'folds')
    if not query then
      return
    end
  end
end

M.setup = function()
  local fold = { expr = require('vim.treesitter._fold').foldexpr }
  local upvalues = mia.debug.get_upvalues(fold.expr)
  fold.on_bytes = upvalues.on_bytes
  fold.on_changedtree = upvalues.on_changedtree

mia.stash['fold.compute_folds_levels'] = mia.debug.get_upvalues(require('vim.treesitter._fold').foldexpr).compute_folds_levels
end
