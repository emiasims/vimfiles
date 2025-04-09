---@type LazySpec
return {
  {
    'folke/flash.nvim',
    opts = {
      search = { multi_window = false, wrap = false },
      label = { uppercase = false },
      modes = {
        search = { enabled = false },
        char = {
          highlight = { backdrop = false },
          char_actions = function()
            return { [';'] = 'right', [','] = 'left' }
          end,
          config = function(opts)
            opts.autohide = vim.api.nvim_get_mode().mode:find('no')
          end,
        },
      },
    },
    keys = { 'f', 'F', 't', 'T', ',', ';' },
  },
  {
    'milisims/flashy-sneakers.nvim',
    dev = true,
    opts = {
      jump = { autojump = true },
      again = { search = { wrap = true } }, -- fix wrap
    },
    keys = { 's', 'S' },
    dependencies = 'flash.nvim',
  },
}
