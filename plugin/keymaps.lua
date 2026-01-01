mia.keymap.remap({ '<F2>', 'gx' }) -- get gx from defaults and map to <F2>

mia.keymap({
  { '<F9>', '<Cmd>Inspect<Cr>', desc = 'Inspect highlight groups' },
  { '<F10>', '<Cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<Cr>' },
})

mia.keymap({
  { 'gO', '<Cmd>lua mia.toc.show()<Cr>', silent = true },
  { '\\d', '<Cmd>lua vim.diagnostic.open_float({ focusable = false })<Cr>' },
  { '[d', '<Cmd>lua vim.diagnostic.jump({count=-vim.v.count1, float=true})<Cr>' },
  { ']d', '<Cmd>lua vim.diagnostic.jump({count=vim.v.count1, float=true})<Cr>' },
  { 'gxl', '<Cmd>lua mia.repl.send_line()<Cr>', dotrepeat = true },
  { 'gx', '<Cmd>lua mia.repl.send_motion()<Cr>', expr = true, dotrepeat = true },
  { 'gx', '<Cmd>lua mia.repl.send_visual()<Cr>', mode = 'x' },
})

-- big funcs
mia.keymap({
  {
    'zk',
    desc = 'Move to the TOP of the previous fold',
    function()
      local start = vim.fn.line('.')
      if vim.v.count1 > 1 then
        vim.cmd.normal({ (vim.v.count1 - 1) .. 'zk', bang = true })
      else
        vim.cmd.normal('m`')
        vim.cmd.normal({ '[z', bang = true, mods = { keepjumps = true } })
        if start == vim.fn.line('.') then
          vim.cmd.normal({ 'zk[z', bang = true, mods = { keepjumps = true } })
        end
      end
    end,
  },
})
