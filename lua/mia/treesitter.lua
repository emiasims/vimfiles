if not pcall(require, 'nvim-treesitter') then return end

local M = {}

local configs = require('nvim-treesitter.configs')
local parsers = require('nvim-treesitter.parsers')
local fold = require('nvim-treesitter.fold')

configs.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {'bash', 'cpp', 'lua', 'python', 'c', 'javascript'},

  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "org" },        -- list of language that will be disabled
    -- custom_captures = {
    --   -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
    --   ["foo.bar"] = "Identifier",

  },

  indent = {
    enable = true,
    disable = { "org" },
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}

local function node_at_curpos()
  local root = vim.treesitter.get_parser(0):parse()[1]:root()
  local _, ln, col, _, _ = unpack(vim.fn.getcurpos())
  return root:named_descendant_for_range(ln-1, col-1, ln-1, col)
end

local function atcurs()
  local node = node_at_curpos()
  local names = {}
  -- local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()
  while node do
    table.insert(names, node:type())
    node = node:parent()
  end
  return names
end

function M.statusline()
  if not parsers.has_parser() then return '' end
  local names = atcurs()
  if #names == 0 then return '' end

  local indicator_size = vim.api.nvim_win_get_width(0) / 2 - 10
  local stl = names[1]
  for i=2,#names do
    if (stl:len() + 2 * #names) >= indicator_size then
      stl = names[i]:sub(1,1) .. '➜' .. stl
    else
      stl = names[i] .. '➔' .. stl
    end
  end
  return stl
end

function M.py_fold(lnum)
  if vim.fn.getline(lnum) == '' then
    local nl = fold.get_fold_indic(vim.fn.nextnonblank(lnum))
    local pl = fold.get_fold_indic(vim.fn.prevnonblank(lnum))
    if string.sub(nl, 1, 1) == '>' then
      nl = tonumber(tonumber(nl) ~= nil and nl or string.sub(nl, 2))
      pl = tonumber(tonumber(pl) ~= nil and pl or string.sub(pl, 2))
      return (nl < pl and nl or pl)
    end
  end
  return fold.get_fold_indic(lnum)
end

-- simple query (section) @fold not working
function M.org_fold(lnum)
  return py_fold(lnum)
end

function M.query2list()
  local querystr = [[(section) @fold]]
  local root = vim.treesitter.get_parser(0):parse()[1]:root()
  local qo = vim.treesitter.parse_query(vim.bo.filetype, querystr)
  i = 0
  for id, node, metadata in qo:iter_captures(root, 0, 0, vim.fn.line('$')) do
    i = i + 1
  end
  return i
end

-- local foldquery = vim.treesitter.parse_query('org', '(section) @fold')
-- local folds = {}
-- setmetatable
-- function make_folds(lnum)
--   local cnode = c
--   for id, node, metadata in foldquery:iter_captures(cnode, 0, lnum, lnum+1) do
--   end
-- end

return M
