vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
}, { load = true })

mia.augroup('treesitter-pack', {
  PackChanged = function(ev)
    if ev.data and ev.data.name == 'nvim-treesitter' then
      vim.cmd.TSUpdate()
    end
  end,
})

require('treesitter-context').setup({ enable = true, multiwindow = true, mode = 'topline' })

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
