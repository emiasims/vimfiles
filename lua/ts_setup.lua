require 'nvim-treesitter.configs'.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {'bash', 'cpp', 'lua', 'python', 'c', 'javascript'},

  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- custom_captures = {
    --   -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
    --   ["foo.bar"] = "Identifier",

  },

  indent = {
    enable = true
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

local ts_utils = require('nvim-treesitter.ts_utils')
local parsers = require('nvim-treesitter.parsers')
local fold = require('nvim-treesitter.fold')
local identity = {}
function identity.__index(table, key)
  return key
end

function ts_namesatcursor()
  local shortnames = vim.g['ts#shortnames'][vim.bo.filetype] or {}
  setmetatable(shortnames, identity)
  local names = {}
  local node = ts_utils.get_node_at_cursor()
  while node do
    if shortnames[node:type()] ~= '' then
      table.insert(names, shortnames[node:type()])
    end
    node = node:parent()
  end
  return names
end

function ts_statusline(indicator_size, shortnames)
  if not parsers.has_parser() then return '' end
  -- local indicator_size = indicator_size or 50
  local indicator_size = vim.api.nvim_win_get_width(0) / 2 - 5

  local names = ts_namesatcursor()
  if #names == 0 then return '' end

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

-- parser = vim.treesitter.get_parser(0, 'python')
-- tstree = parser:parse()

local getline = function(lnum) return vim.api.nvim_buf_get_lines(0, lnum-1, lnum, 0)[1] end
local emptyline = function(lnum) return getline(lnum) == '' end
local function _nonblank(lnum, direction)
  if lnum > vim.api.nvim_buf_line_count(0) or lnum <= 0 then
    return 0
  elseif not emptyline(lnum) then
    return lnum
  else
    return _nonblank(lnum + direction, direction)
  end
end
local nextnonblank = function(lnum) return _nonblank(lnum, 1) end
local prevnonblank = function(lnum) return _nonblank(lnum, -1) end

local fl = fold.get_fold_indic
local function ftonumber(foldlevel)
  local n = tonumber(foldlevel)
  if n == nil then n = tonumber(string.sub(foldlevel, 2)) end
  return n
end

function py_fold(lnum)
  if emptyline(lnum) then
    local nl, pl = fl(nextnonblank(lnum)), fl(prevnonblank(lnum))
    if string.sub(nl, 1, 1) == '>' then
      nl, pl = ftonumber(nl), ftonumber(nl)
      return (nl < pl and nl or pl)
    end
  end
  return fl(lnum)
end
