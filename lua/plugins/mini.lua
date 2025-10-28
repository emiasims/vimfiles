---@type LazySpec
return {
  { 'nvim-mini/mini.test', event = 'VeryLazy' },
  { 'nvim-mini/mini.cursorword', event = 'VeryLazy', config = true },
  {
    'nvim-mini/mini.doc',
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
    'nvim-mini/mini.starter',
    enabled = true,
    lazy = vim.fn.argc() > 0,
    event = 'CmdlineEnter',
    config = function()
      local Starter = require('mini.starter')
      local cfgdir = vim.fn.stdpath('config')
      local items = {
        mia.session.mini_starter_items(3),
        Starter.sections.recent_files(3, true),
        Starter.sections.recent_files(3, false, true),
        { section = 'Pick', name = 'Files', action = 'Pick files' },
        { section = 'Pick', name = 'Help tags', action = 'Pick help' },
        { section = 'Pick', name = 'Recent files', action = 'Pick recent' },
        { section = 'Pick', name = 'Vim files', action = 'Pick files cwd=' .. cfgdir },
        { section = 'Pick', name = 'Shell config files', action = 'Pick config_files' },
        { section = 'Plugin', name = 'Pick', action = 'Pick files cwd=' .. cfgdir .. '/lua/plugins' },
        { section = 'Plugin', name = 'Lazy', action = 'Lazy' },
      }
      if mia.ide.enabled() then
        vim.list_extend(items, {
          { section = 'Plugin', name = 'Add new', action = 'echo NYI' },
          { section = 'Plugin', name = 'Develop new', action = 'echo NYI' },
          { section = 'Plugin', name = 'Mason', action = 'Mason' },
        })
      end
      table.insert(items, Starter.sections.builtin_actions())
      Starter.setup({ items = items, header = '', footer = '' })
    end,
  },
}
