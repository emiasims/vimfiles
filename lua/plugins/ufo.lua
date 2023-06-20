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

    local function ts_custom(bufnr)
      -- see https://github.com/kevinhwang91/nvim-ufo/issues/125
      return vim.list_extend(
        ufo.getFolds(bufnr, 'treesitter'),
        require 'mia.fold.expr'[vim.bo[bufnr].filetype](bufnr))
    end

    ufo.setup {
      ---@diagnostic disable-next-line unused-local
      provider_selector = function(bufnr, filetype, buftype)
        if buftype == '' and vim.treesitter.language.get_lang(filetype) then
          return ts_custom
        end
        return { 'lsp', 'treesitter' }
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
