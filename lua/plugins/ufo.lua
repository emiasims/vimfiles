return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  event = { "BufReadPost", "BufNewFile" },

  config = function()
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

    require('ufo').setup {
      ---@diagnostic disable-next-line: unused-local
      provider_selector = function(bufnr, filetype, buftype)
        return { 'treesitter', 'indent' }
      end,
      enable_get_fold_virt_text = true,
      fold_virt_text_handler = function(...) return require('mia.foldtext').default(...) end
    }

    vim.api.nvim_create_augroup('mia-ufo', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = 'mia-ufo',
      desc = 'Set virt text handler',
      callback = function(ev)
        local foldtext = require('mia.foldtext')[vim.bo[ev.buf].filetype]
        -- P(ev, foldtext)
        if foldtext then
          require('ufo').setFoldVirtTextHandler(ev.buf, foldtext)
        end
      end,
    })
  end
}
