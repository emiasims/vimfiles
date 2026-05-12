vim.pack.add({
  'https://github.com/quarto-dev/quarto-nvim',
  'https://github.com/jmbuhr/otter.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
}, { load = true })

require('quarto').setup({})
