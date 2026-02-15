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
    desc = 'Move upwards to the START of the previous fold',
    function()
      local function start_of_fold(lnum)
        local closed = vim.fn.foldclosed(lnum)
        return closed ~= -1 and closed or lnum
      end

      local function start_of_prev_fold(lnum)
        lnum = start_of_fold(lnum)
        repeat
          lnum = start_of_fold(lnum - 1)
        until lnum <= 1 or vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1)
        return lnum
      end

      local lnum = vim.fn.line('.')
      for _ = 1, vim.v.count1 do
        lnum = start_of_prev_fold(lnum)
      end

      if lnum ~= vim.fn.line('.') then
        vim.cmd.normal('m`')
        vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      end
    end,
  },
})
