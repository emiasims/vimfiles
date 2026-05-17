stimpack.add({ 'folke/lazydev.nvim' })

require('lazydev').setup({
  library = {
    'lazy.nvim',
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    { path = '${3rd}/luassert/library', words = { 'assert' } },
    { path = '${3rd}/busted/library', words = { 'describe' } },
  },
})
