if not pcall(require, 'nvim-treesitter') then
  return
end

require('nvim-treesitter.parsers').get_parser_configs().org = {
  install_info = {
    url = '~/Projects/tree-sitter-org',
    -- url = 'https://github.com/milisims/tree-sitter-org',
    -- branch = 'main',
    -- revision = 'v0.3.0',
    files = { 'src/parser.c', 'src/scanner.cc' },
  },
  filetype = 'org',
}

require('nvim-treesitter.configs').setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = { 'bash', 'cpp', 'lua', 'python', 'c', 'javascript' },

  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { 'help' }, -- list of language that will be disabled
    -- custom_captures = {
    --   -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
    --   ["foo.bar"] = "Identifier",
    -- }
  },

  indent = {
    enable = false,
    disable = { 'org' },
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<Tab>',
      node_incremental = '<Tab>',
      node_decremental = '<S-Tab>',
      scope_incremental = 'g<Tab>',
    },
  },
}

require('nvim-treesitter.configs').setup {
  textobjects = {
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',

      },
    },
  },
}
