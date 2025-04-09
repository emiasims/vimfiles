---@type LazySpec
return {
  'folke/noice.nvim',
  enabled = false,
  event = 'VeryLazy',
  keys = { { '<F4>', '<Cmd>Noice<Cr>' } },
  ctxmap = { { 'no', { 'builtin.cmd_start', 'Noice' }, mode = 'ca' } },
  ---@type NoiceConfig
  opts = {

    cmdline = {
      -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
      -- view: (default is cmdline view)
      -- opts: any options passed to the view
      -- icon_hl_group: optional hl_group for the icon
      -- title: set to anything or empty string to hide
      format = {
        cmdline = { icon_hl_group = '@function', conceal = false },
        search_down = { icon_hl_group = '@operator', conceal = false },
        search_up = { icon_hl_group = '@operator', conceal = false },
        filter = { icon_hl_group = '@delimiter', conceal = false }, -- bash
        lua = { icon_hl_group = '@keyword', conceal = false },
        help = { icon_hl_group = '@label', conceal = false },
        calculator = { icon_hl_group = '@operator', conceal = false },
        input = { icon_hl_group = '@identifier', title = '' },
        -- task = { kind = 'input', pattern = '^task: ', icon_hl_group = '@identifier' }, -- Used by input()
        -- lua = false, -- to disable a format, set to `false`
      },
    },

    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
      },
    },

    presets = { bottom_search = true, lsp_doc_border = true },

    views = {
      cmdline_popup = {
        border = false,
        win_options = { winhighlight = { Normal = 'NormalFloat' } },
      },
    },
  },

  config = function(cfg)
    require('noice').setup(cfg.opts --[[@as NoiceConfig]])

    -- hide virtual text when hlsearch is disabled.
    -- Not sure if this is suppsed to happen automatically, but it doesn't for me
    mia.autocmd('OptionSet', {
      pattern = 'hlsearch',
      callback = function()
        if not vim.v.option_new then
          require('noice.view').get_view('virtualtext', {}):hide()
        end
      end,
    })

    -- mia.augroup({
    --   OptionSet = {
    --     hlsearch = function()
    --       if not vim.v.option_new then
    --         require('noice.view').get_view('virtualtext', {}):hide()
    --       end
    --     end,
    --   },
    -- })

  end,

  dependencies = { 'MunifTanjim/nui.nvim', 'stevearc/dressing.nvim' },
}
