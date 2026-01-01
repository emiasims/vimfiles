---@type LazySpec
return {
  'nvim-mini/mini.cmdline',
  event = 'CmdlineEnter',
  init = function()
    vim.o.wildmode = 'noselect:lastused,full'
  end,
  opts = {
    autocomplete = {
      predicate = function()
        return not require('blink.cmp').is_visible()
          and not (vim.env.WSL_DISTRO_NAME and vim.fn.getcmdcompltype() == 'shellcmd')
      end,
    },
  },
}
