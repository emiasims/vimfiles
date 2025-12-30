---@type LazySpec
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        'lazy.nvim',
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}
