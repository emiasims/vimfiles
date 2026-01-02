---@type LazySpec
return {
  'folke/lazydev.nvim',
  ft = 'lua', -- only load on lua files
  opts = {
    library = {
      'lazy.nvim',
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = '${3rd}/luassert/library', words = { 'assert' } },
      { path = '${3rd}/busted/library', words = { 'describe' } },
    },
  },
}
