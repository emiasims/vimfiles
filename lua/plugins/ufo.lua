return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  event = { 'BufReadPost', 'BufNewFile' },

  config = function()
    local nmap = require 'mapfun' 'n'
    local ufo = require 'ufo'
    nmap('zR', ufo.openAllFolds)
    nmap('zM', ufo.closeAllFolds)

    nmap('<Plug>(default-zO)', 'zO')  -- zO is mapped elsewhere
    nmap('zE', 'zM<Plug>(default-zO)', { remap = true })
    nmap('zV', 'zMzv', { remap = true })

    nmap('zj', ufo.goNextClosedFold)
    nmap('zk', ufo.goPreviousStartFold)

    ufo.setup {
      ---@diagnostic disable-next-line unused-local
      provider_selector = function(bufnr, filetype, buftype)
        -- see https://github.com/kevinhwang91/nvim-ufo/issues/125
        local lang = vim.treesitter.language.get_lang(filetype)
        local foldexpr = require 'mia.fold.expr'[filetype]

        if buftype == '' and lang and foldexpr then
          return function()
            return vim.list_extend(ufo.getFolds(bufnr, 'treesitter'), foldexpr(bufnr))
          end
        elseif lang then
          return { 'lsp', 'treesitter' }
        end
        return 'lsp'
      end,

      enable_get_fold_virt_text = true,
      fold_virt_text_handler = function(...) return require 'mia.fold.text'.default(...) end,
    }

    vim.api.nvim_create_augroup('mia-ufo', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = 'mia-ufo',
      desc = 'Set virt text handler',
      callback = function(ev)
        local foldtext = require 'mia.fold.text'[vim.bo[ev.buf].filetype]
        if foldtext then
          ufo.setFoldVirtTextHandler(ev.buf, foldtext)
        end
      end,
    })
  end,
}
