mia.keymap({
  { '<F9>', '<Cmd>Inspect<Cr>', desc = 'Inspect highlight groups' },
  { '<F10>', '<Cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<Cr>' },
})

mia.keymap({
  { 'gO', '<Cmd>lua mia.toc.show()<Cr>', silent = true },
  { '\\d', '<Cmd>lua vim.diagnostic.open_float({ focusable = false })<Cr>' },
  { '[d', '<Cmd>lua vim.diagnostic.jump({count=-vim.v.count1, float=true})<Cr>' },
  { ']d', '<Cmd>lua vim.diagnostic.jump({count=vim.v.count1, float=true})<Cr>' },
  { '<C-h>', '<Cmd>lua vim.lsp.buf.signature_help()<Cr>', mode = 'i' },
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
  {
    'dsf',
    desc = 'Delete surrounding function',
    dotrepeat = true,
    function()
      local query = vim.treesitter.query.get(vim.o.filetype, 'textobjects') --[[@as vim.treesitter.Query]]
      if not query then
        mia.warn('No textobjects query found for filetype ' .. vim.o.filetype)
      end

      -- local cursor_node = vim.treesitter.get_node()
      local root = vim.treesitter.get_parser():parse()[1]:root()
      local _, lnum, col = unpack(vim.fn.getcurpos())
      lnum, col = lnum - 1, col - 1

      -- Get all the calls and smallest param here
      local calls, param = {}, {}
      for id, node, _ in query:iter_captures(root, 0, lnum, lnum + 1) do
        if query.captures[id]:match('param') and vim.treesitter.is_in_node_range(node, lnum, col) then
          param = node
        elseif
          query.captures[id]:match('call.outer') and vim.treesitter.is_in_node_range(node, lnum, col)
        then
          calls[#calls + 1] = node
        end
      end

      -- Get the first call that isn't the parameter.  This can't necessarily be
      -- done in the query loop, because we might match calls first.
      local call
      for i = #calls, 1, -1 do
        if calls[i] ~= param then
          call = calls[i]
          break
        end
      end

      if param and call then
        require('nvim-treesitter.ts_utils').update_selection(0, param)
        vim.api.nvim_feedkeys('y', 'nx', true)
        require('nvim-treesitter.ts_utils').update_selection(0, call)
        vim.api.nvim_feedkeys('p', 'nx', true)
      else
        mia.warn('Parameter or call not found')
      end
    end,
  },
})
