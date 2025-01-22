---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',

  build = ':TSUpdate',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  config = function()
    if vim.fn.isdirectory(vim.env.HOME .. '/Projects/tree-sitter-org') > 0 then
      require('nvim-treesitter.parsers').get_parser_configs().org = {
        install_info = {
          url = '~/Projects/tree-sitter-org',
          files = { 'src/parser.c', 'src/scanner.c' },
        },
        filetype = 'org',
      }
    end

    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup({
      -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      ensure_installed = { 'bash', 'cpp', 'lua', 'python', 'c', 'javascript', 'org', 'regex', 'luap' },

      highlight = {
        enable = true, -- false will disable the whole extension
        custom_captures = {
          -- ['variable'] = 'Identifier',
          ['variable.builtin'] = 'Special',
          ['field'] = 'Field',
        },
      },

      indent = {
        enable = false,
        disable = { 'org' },
      },

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
          -- You can use the capture groups defined in textobjects.scm
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
          selection_modes = {
            ['@function.outer'] = 'V',
            ['@function.inner'] = 'V',
            ['@class.outer'] = 'V',
            ['@class.inner'] = 'V',
          },
        },
      },
    })
  end,
}
