vim.o.wildmode = 'noselect:lastused,full'
vim.pack.add({'https://github.com/nvim-mini/mini.cmdline' }, { load = true })

require('mini.cmdline').setup({
  autocomplete = {
    predicate = function()
      return not require('blink.cmp').is_visible()
        and not (vim.env.WSL_DISTRO_NAME and vim.fn.getcmdcompltype() == 'shellcmd')
    end,
  },
})
