---@type LazySpec
return {
  'williamboman/mason.nvim',
  build = ':MasonUpdate',
  event = 'VeryLazy',
  config = true,
}
