vim.env.GEMINI_API_KEY = mia.secrets.gemini()

---@type LazySpec
return {
  'olimorris/codecompanion.nvim',
  enabled = mia.ide.enabled,
  cmd = { 'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanionCmd' },
  ctxmap = {
    {
      mode = 'ca',
      ctx = 'cmd.start',
      { 'cc', 'CodeCompanion' },
      { 'cca', 'CodeCompanionActions' },
      { 'cch', 'CodeCompanionChat' },
      { 'ccc', 'CodeCompanionCmd' },
    },
  },
  keys = { { '<C-c>', '<Plug>(cc-stop)', ft = 'codecompanion' } },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/codecompanion-history.nvim',
    {
      'ravitemer/mcphub.nvim',
      enabled = mia.ide.enabled,
      event = 'VeryLazy',
      build = 'npm install -g mcp-hub@latest',
      opts = {
        port = 3000,
        config = vim.fn.stdpath('config') .. '/mcpservers.json',
        shutdown_delay = 0 * 1000,
      },
    },
  },
  opts = {
    adapters = {
      http = {
        copilot = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = { default = 'gpt-5-mini' },
            },
          })
        end,
      },
      acp = {
        gemini_cli = function()
          return require('codecompanion.adapters').extend('gemini_cli', {
            env = {
              api_key = mia.secrets.gemini(),
            },
          })
        end,
      },
    },
    display = {
      chat = { show_settings = true },
      action_palette = {
        opts = {
          show_default_actions = false,
          show_default_prompt_library = false,
        },
      },
    },
    strategies = {
      chat = {
        adapter = 'copilot',
        slash_commands = {
          file = { opts = { provider = 'snacks' } },
          symbols = { opts = { provider = 'snacks' } },
          buffer = { opts = { provider = 'snacks' } },
          help = { opts = { provider = 'snacks' } },
        },

        keymaps = {
          completion = { modes = { i = '<Plug>(disabled)' } },
          send = { modes = { n = '<C-g>', i = '<C-g><C-g>' } },
          close = { modes = { n = 'ZZ', i = '<Plug>(disabled)' } },
          next_chat = { modes = { n = ']c' } },
          previous_chat = { modes = { n = '[c' } },
          stop = { modes = { n = '<Plug>(cc-stop)' } },
          options = { modes = { n = 'g?' } },
        },
      },
    },
    tools = {
      mcp = {
        callback = function()
          return require('mcphub.extensions.codecompanion')
        end,
        description = 'Call tools and resources from the MCP Servers',
        opts = { user_approval = true },
      },
    },
    extensions = {
      history = {
        enabled = true,
      },
    },
  },
  config = function(_, opts)
    require('codecompanion').setup(opts)
    local requests = {}
    vim.api.nvim_create_autocmd({ 'User' }, {
      pattern = 'CodeCompanionRequest*',
      group = vim.api.nvim_create_augroup('mia-codecompanion-spin', { clear = true }),
      callback = function(ev)
        local eid = ev.data.id
        if ev.match == 'CodeCompanionRequestStarted' then
          requests[eid] = mia.spinner.add(function()
            return requests[eid] == nil
          end)
        elseif ev.match == 'CodeCompanionRequestFinished' then
          requests[eid] = nil
        end
      end,
    })
  end,
}
