---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',
  branch = 'main',
  build = ':TSUpdate',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    {
      'nvim-treesitter/nvim-treesitter-context',
      lazy = true,
      opts = { enable = false, mode = 'topline' }, -- used in winbar
    },
  },
  config = function()
    local ts = require('nvim-treesitter')

    ---@param ev aucmd.callback.arg
    local ts_start = function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
      if vim.tbl_contains(ts.get_available(), lang) then
        local ok = pcall(vim.treesitter.start, ev.buf, lang)
        if not ok then
          ts.install(lang):await(function()
            vim.treesitter.start(ev.buf, lang)
          end)
        end
      end
    end

    local group = vim.api.nvim_create_augroup('mia.treesitter', { clear = true })
    mia.augroup(group, { FileType = ts_start })

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if not vim.treesitter.highlighter.active[buf] then
        vim.schedule(function()
          ---@diagnostic disable-next-line: missing-fields
          ts_start({ buf = buf, match = vim.bo[buf].filetype })
        end)
      end
    end
  end,
}
