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

    local function lspCommentsThenTSFolds(bufnr)
      -- see https://github.com/kevinhwang91/nvim-ufo/issues/125
      return ufo.getFolds(bufnr, 'lsp'):thenCall(function(raw)
        return vim.list_extend(
          vim.iter(raw):filter(function(v) return v.kind == 'comment' end):totable(),
          ufo.getFolds(bufnr, 'treesitter'))
      end):catch(function(err)
        if type(err) == 'string' and err:match('UfoFallbackException') then
          return require('ufo').getFolds(bufnr, 'indent')
        else
          return require('promise').reject(err)
        end
      end)
    end

    ufo.setup {
      provider_selector = function() return lspCommentsThenTSFolds end,
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
