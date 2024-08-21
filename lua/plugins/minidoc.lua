---@type LazySpec
return {
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
          if vim.fn.filereadable 'scripts/docgen.lua' == 1 then
            dofile 'scripts/docgen.lua'
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
}
