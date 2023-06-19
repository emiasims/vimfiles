return {
  'brenoprata10/nvim-highlight-colors',
  event = 'VeryLazy',
  config = function()
    require 'nvim-highlight-colors'.setup {
      render = 'background',  -- foreground?
      enable_named_colors = false,
    }
    require 'nvim-highlight-colors'.turnOn()
  end,
}
