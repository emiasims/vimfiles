-- nvim-compe
require 'plugin.completion'

-- nvim-treesitter
if not pcall(require, 'nvim-treesitter') then return end
require('nvim-treesitter.configs').setup {
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

