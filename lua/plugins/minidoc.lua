return {
  'echasnovski/mini.doc',
  lazy=true,

  config = function()
    vim.api.nvim_create_augroup('mia-minidoc', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = "*.lua",
      group = 'mia-minidoc',
      desc = 'Write docs on save',
      callback = function()
        if vim.fn.filereadable('scripts/docgen.lua') == 1 then
          dofile('scripts/docgen.lua')
        end
      end,
    })
  end
}
