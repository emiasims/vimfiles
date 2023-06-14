return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  event = { "BufReadPost", "BufNewFile" },

  config = function()
    local nmap = require 'mapfun' 'n'
    local ufo = require('ufo')
    nmap('zR', ufo.openAllFolds)
    nmap('zM', ufo.closeAllFolds)

    nmap('<Plug>(default-zO)', 'zO') -- zO is mapped elsewhere
    nmap('zE', 'zM<Plug>(default-zO)', { remap = true })
    nmap('zV', 'zMzv', { remap = true })

    nmap('zj', ufo.goNextClosedFold)
    nmap('zk', ufo.goPreviousStartFold)

    require('ufo').setup {
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
