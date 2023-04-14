return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  event = { "BufReadPost", "BufNewFile" },
  keys = { 'zR', 'zM' },

  config = function()
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

    require('ufo').setup({
      provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
      end,

      fold_virt_text_handler = function(...) return require('mia.foldtext')(...) end
    })

  end
}
