---@type LazySpec
return {
  { 'echasnovski/mini.test', event = 'VeryLazy' },
  { 'echasnovski/mini.cursorword', event = 'VeryLazy', config = true },
  {
    'echasnovski/mini.doc',
    lazy = true,

    config = function()
      vim.api.nvim_create_augroup('mia-minidoc', { clear = true })
      local autocmd_id
      vim.api.nvim_create_user_command('MinidocEnable', function()
        if autocmd_id then
          vim.api.nvim_del_autocmd(autocmd_id)
        end
        autocmd_id = vim.api.nvim_create_autocmd('BufWritePost', {
          pattern = '*.lua',
          group = 'mia-minidoc',
          desc = 'Write docs on save',
          callback = function()
            if vim.fn.filereadable('scripts/docgen.lua') == 1 then
              dofile('scripts/docgen.lua')
            end
          end,
        })
      end, {})
      vim.api.nvim_create_user_command('MinidocDisable', function()
        if autocmd_id then
          vim.api.nvim_del_autocmd(autocmd_id)
        end
        autocmd_id = nil
      end, {})
    end,
  },
  {
    'echasnovski/mini.starter',
    enabled = true,
    lazy = vim.fn.argc() > 0,
    event = 'CmdlineEnter',
    config = function()
      local Starter = require('mini.starter')
      local Pick = function(name, cmd)
        cmd = 'Pick ' .. cmd
        return { action = cmd, name = name, section = 'Pick' }
      end
      Starter.setup({
        items = {
          mia.session.mini_starter_items(3),
          Starter.sections.recent_files(3, true),
          Starter.sections.recent_files(3, false, true),
          Pick('Files', 'files'),
          Pick('Help tags', 'help'),
          Pick('Recent files', 'recent'),
          Pick('Vim files', 'files cwd=' .. vim.fn.stdpath('config')),
          Pick('Shell config files', 'config_files'),
          Starter.sections.builtin_actions(),
        },
        header = '',
        footer = '',
      })
    end,
  },
}
