-- extracts defaults and remaps
mia.keymap.remap({ { '<F2>', 'gx' } })

mia.keymap({
  { '<F3>', '<Cmd>messages clear|echohl Type|echo "Messages cleared."|echohl None<Cr>' },
  { '<F4>', '<Cmd>messages<Cr>' },
  { '<F5>', '<Cmd>update|mkview|edit|TSBufEnable highlight<Cr>' },
  { '<F6>', '<Cmd>UndotreeToggle<Cr>' },
  { '\\gt', '<Cmd>exe "tabmove +" .. v:count1<Cr>' },
  { '\\gT', '<Cmd>exe "tabmove -" .. v:count1<Cr>' },
  { '<F8>', '<Cmd>update|so%<Cr>' },
  {
    '<F9>',
    desc = 'Print highlight group list at cursor',
    function()
      local highlights = mia.highlight.at_cursor()
      for src, hls in pairs(highlights) do
        local groups = vim.iter(hls):map(mia.tbl.index('group')):join(', ')
        mia.info(src .. ': ' .. groups)
      end
    end,
  },
  {
    desc = 'Toggle inlay hints',
    '<F10>',
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end,
  },
})

mia.keymap({
  mode = 't',
  { '<Plug>(termLeave)', '<C-\\><C-n>' .. "<cmd>let b:last_mode = 'n'<Cr>", silent = true },
  { '<Plug>(term2nmode)', "<C-\\><C-n><cmd>let b:last_mode = 't'<Cr>", silent = true },
  { '<C-[>', '<C-[>' },
  { '<C-Space>', '<Space>' },
  { '<S-Space>', '<Space>' },
})

mia.keymap({
  mode = 't',
  remap = true,
  { '<C-h>', '<Plug>(term2nmode)<C-h>' },
  { '<C-j>', '<Plug>(term2nmode)<C-j>' },
  { '<C-k>', '<Plug>(term2nmode)<C-k>' },
  { '<C-l>', '<Plug>(term2nmode)<C-l>' },
  { '<C-^>', '<Plug>(term2nmode)<C-^>' },
  { '<C-\\>', '<Plug>(term2nmode)<C-w>p' },
  { '<Esc>', '<Plug>(termLeave)' },
  { '<M-n>', '<Plug>(termLeave)' },
})

local diagnostic_jump = function(forward)
  if forward then
    vim.diagnostic.jump({ count = vim.v.count1, float = true })
  else
    vim.diagnostic.jump({ count = -vim.v.count1, float = true })
  end
end

mia.keymap({
  { 'gO', mia.toc.show, silent = true, desc = 'Show table of contents' },
  { '\\d', mia.partial(vim.diagnostic.open_float, { focusable = false }), desc = 'Open diagnostic float' },
  { '[d', mia.partial(diagnostic_jump, false), desc = 'Prev. diagnostic jump' },
  { ']d', mia.partial(diagnostic_jump, true), desc = 'Prev. diagnostic jump' },
  { '<C-h>', mia.on.call('vim.lsp.buf').signature_help, mode = 'i', desc = 'Show signature help' },
  { 'gxl', mia.repl.send_line, dotrepeat = true, desc = 'Send line to REPL' },
  { 'gx', mia.repl.send_motion, expr = true, dotrepeat = true, desc = 'Send motion to REPL' },
  { 'gx', mia.repl.send_visual, mode = 'x', desc = 'Send visual selection to REPL' },
})

-- misc
mia.keymap({
  { 'gs', ':s//g<Left><Left>', mode = 'x' },
  { '!', '<C-]>!', mode = 'c' },
  { '<C-i>', '<C-i>' },
  { '<C-;>', 'g;' },
  { '<C-,>', 'g,' },
  { '.', '.<C-]>', mode = 'i' },
  { '.', '.<C-]>', mode = 'c' },
  { '<C-t>', '<Home>tab split|<End>', mode = 'c' },
  { { '<MiddleMouse>', '"*p' }, { '<BS>', '"*' }, mode = { 'n', 'x' } },

  { 'nvim.', 'vim.api.nvim_', mode = { 'ia', 'ca' } },
  { '=nvim.', '=vim.api.nvim_', mode = 'ca' },

  { 'Y', '"+y', mode = 'x' },
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
