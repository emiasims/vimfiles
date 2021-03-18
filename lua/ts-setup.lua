require 'nvim-treesitter.configs'.setup {
  ensure_installed = {'bash', 'cpp', 'lua', 'python'}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages

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

local ts_utils = require'nvim-treesitter.ts_utils'
local parsers = require'nvim-treesitter.parsers'
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
