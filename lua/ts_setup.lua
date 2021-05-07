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

function ts_statusline(indicator_size, shortnames)
  if not require('nvim-treesitter.parsers').has_parser() then return '' end
  local indicator_size = vim.api.nvim_win_get_width(0) / 2 - 10

  local names = {}
  local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()
  while node do
    table.insert(names, node:type())
    node = node:parent()
  end
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

local ts_foldlevel = require('nvim-treesitter.fold').get_fold_indic
local function ftonumber(foldlevel)
  local n = tonumber(foldlevel)
  if n == nil then n = tonumber(string.sub(foldlevel, 2)) end
  return n
end

function py_fold(lnum)
  if emptyline(lnum) then
    local nl, pl = ts_foldlevel(nextnonblank(lnum)), ts_foldlevel(prevnonblank(lnum))
    if string.sub(nl, 1, 1) == '>' then
      nl, pl = ftonumber(nl), ftonumber(nl)
      return (nl < pl and nl or pl)
    end
  end
  return ts_foldlevel(lnum)
end
