---@type LazySpec
return {
  'nvim-mini/mini.cmdline',
  event = 'CmdlineEnter',
  init = function()
    vim.o.wildmode = 'noselect:lastused,full'
  end,
  config = true,
}
