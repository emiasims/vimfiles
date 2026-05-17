vim.o.wildmode = 'noselect:lastused,full'
stimpack.add({'nvim-mini/mini.cmdline' })

require('mini.cmdline').setup({
  autocomplete = {
    predicate = function()
      return not require('blink.cmp').is_visible()
        and not (vim.env.WSL_DISTRO_NAME and vim.fn.getcmdcompltype() == 'shellcmd')
    end,
  },
})
