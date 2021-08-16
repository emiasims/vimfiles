vim.api.nvim_command "packadd nvim-compe"
local has_compe, compe = pcall(require, "compe")
if has_compe then
  compe.setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = "enable",
    throttle_time = 80, -- 200,
    source_timeout = 200,
    incomplete_delay = 400,
    -- allow_prefix_unmatch = false,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,

    source = {
      path = true,
      buffer = true,
      calc = false,
      vsnip = true,
      nvim_lsp = true,
      nvim_lua = true,
      spell = false,
      tags = false,
      treesitter = false,
      ultisnips = true,
    },
  }

--   vim.api.nvim_set_keymap("i", "<c-y>", 'compe#confirm("<c-y>")', { silent = true, noremap = true, expr = true })
--   vim.api.nvim_set_keymap("i", "<c-e>", 'compe#close("<c-e>")', { silent = true, noremap = true, expr = true })
  -- vim.api.nvim_set_keymap("i", "<c-space>", "compe#complete()", { silent = true, noremap = true, expr = true })
end
