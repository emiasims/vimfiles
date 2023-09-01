return {
  'echasnovski/mini.doc',
  lazy = true,

  config = function()
    nvim.create_augroup('mia-minidoc', { clear = true })
    local autocmd_id
    nvim.create_user_command('MinidocEnable', function()
      if autocmd_id then
        nvim.del_autocmd(autocmd_id)
      end
      autocmd_id = nvim.create_autocmd('BufWritePost', {
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
    nvim.create_user_command('MinidocDisable', function()
      if autocmd_id then
        nvim.del_autocmd(autocmd_id)
      end
      autocmd_id = nil
    end, {})
  end,
}
