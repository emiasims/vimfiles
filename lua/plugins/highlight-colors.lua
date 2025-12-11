---@type LazySpec
return { -- Highlight color codes like #ca9ee6, rgb(202,158,230), etc.
  'brenoprata10/nvim-highlight-colors',
  event = 'VeryLazy',
  opts = {
    enable_named_colors = false,
    exclude_filetypes = { 'lazy', 'help' }
  },
}
