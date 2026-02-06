---@type LazySpec
return {
  'carlos-algms/agentic.nvim',
  enabled = mia.ide.enabled,
  event = 'CmdlineEnter',

  opts = {
    provider = 'gemini-acp',
    keymaps = {
      prompt = {
        submit = { '<C-Cr>', { '<C-Cr>', mode = { 'i', 'n', 'v' } } },
      },
    },
  },

  keys = {
    { 'gat', "<Cmd>lua require('agentic').toggle()<Cr>" },
    { 'gan', "<Cmd>lua require('agentic').new_session()<Cr>" },
    { 'gaf', "<Cmd>lua require('agentic').add_file()<Cr>" },
    { 'gac', "<Cmd>lua require('agentic').add_selection()<Cr>", mode = 'x' },
    { '<C-c>', "<Cmd>lua require('agentic').stop_generation()<Cr>", ft = 'Agentic*' },
  },

  config = function(_, opts)
    require('agentic').setup(opts)

    mia.augroup('agentic', {
      FileType = {
        pattern = 'Agentic*',
        callback = function(ev)
          vim.b.update_bufinfo = {
            type = 'agentic',
            name = ev.match:sub(8),
            desc = '[Agentic]',
            tab_name = (
              (ev.match == 'AgenticChat' and 'Agentic:[Chat')
              or (ev.match == 'AgenticInput' and 'Input]')
              or ev.match:sub(8)
            ),
          }
          vim.b.bufinfo = mia.bufinfo.get()
          mia.keymap({
            mode = 'i',
            buffer = ev.buf,
            { '<C-h>', '<Cmd>stopinsert|normal <C-h><Cr>' },
            { '<C-l>', '<Cmd>stopinsert|normal <C-l><Cr>' },
            { '<C-j>', '<Cmd>stopinsert|normal <C-j><Cr>' },
            { '<C-k>', '<Cmd>stopinsert|normal <C-k><Cr>' },
          })
        end,
      },
    })
  end,
}
