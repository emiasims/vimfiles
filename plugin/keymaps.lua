local cmap, xmap, nmap, tmap, imap = require('mapfun')({ 'c', 'x', 'n', 't', 'i' })

local remap = { remap = true }
local silent = { silent = true }
local cmd = function(c)
  return ('<Cmd>%s<Cr>'):format(c)
end

nmap('<F1>', function()
  vim.api.nvim_echo({ { require('mia.tslib').statusline(math.huge) } }, false, {})
end)
-- if not mia.og.gx then
--   mia.og.gx = vim.fn.maparg('gx', 'n', false, true).callback
--   mia.og.vgx = vim.fn.maparg('gx', 'x', false, true).callback
-- end
-- nmap('<F2>', mia.og.gx)
-- xmap('<F2>', mia.og.vgx)

nmap('<F3>', cmd('messages clear|echohl Type|echo "Messages cleared."|echohl None'))
nmap('<F4>', cmd('messages'))

nmap('<F5>', cmd('update|mkview|edit|TSBufEnable highlight'))
nmap('<F6>', '<cmd>UndotreeToggle<Cr>')

nmap('<F7>', function()
  if vim.bo.fo:match('a') then
    vim.opt_local.formatoptions:remove('a')
  else
    vim.opt_local.formatoptions:append('a')
  end
end, { desc = 'Toggle paragraph autoformat' })

nmap('<F8>', cmd('w|so%'))

nmap('<F9>', function()
  if #vim.treesitter.get_captures_at_cursor() > 0 then
    P(vim.treesitter.get_captures_at_cursor())
  else
    vim.fn.SynStack()
  end
end, { desc = 'Print highlight group list at cursor' })

nmap('<F10>', function()
  vim.lsp.inlay_hint(0)
end, { desc = 'Toggle inlay hints' })

xmap('gs', ':s//g<Left><Left>')
cmap('!', '<C-]>!')

-- associated with autocmds in lua/mia/autocmds.lua
tmap('<Plug>(termLeave)', "<C-\\><C-n>" .. "<cmd>let b:last_mode = 'n'<Cr>", silent)
tmap('<Plug>(term2nmode)', "<C-\\><C-n><cmd>let b:last_mode = 't'<Cr>", silent)

tmap('<C-h>', '<Plug>(term2nmode)<C-h>', remap)
tmap('<C-j>', '<Plug>(term2nmode)<C-j>', remap)
tmap('<C-k>', '<Plug>(term2nmode)<C-k>', remap)
tmap('<C-l>', '<Plug>(term2nmode)<C-l>', remap)
tmap('<C-^>', '<Plug>(term2nmode)<C-^>', remap)
tmap('<C-\\>', '<Plug>(term2nmode)<C-w>p', remap)
tmap('<Esc>', '<Plug>(termLeave)', remap)
tmap('<C-[>', '<C-[>')
tmap('<M-n>', '<Plug>(termLeave)', remap)

tmap('<C-Space>', '<Space>')
tmap('<S-Space>', '<Space>')

nmap('gO', function()
  local parser = vim.treesitter.get_parser()
  local _, query = pcall(vim.treesitter.query.get, parser:lang(), 'toc')

  if parser and query then
    mia.toc.show()
  elseif parser then
    util.warn("No toc query found for '" .. parser:lang() .. "'")
  else
    util.warn("No parser found for filetype " .. vim.treesitter.language.get_lang(vim.bo.filetype))
  end
end, { silent = true })

local function open_float_after(func)
  return function()
    if func then
      for _ = 1, vim.v.count1 do
        func()
      end
    end
    vim.diagnostic.open_float({ focusable = false })
  end
end

nmap('\\d', open_float_after(nil))
nmap('[d', open_float_after(vim.diagnostic.goto_prev))
nmap(']d', open_float_after(vim.diagnostic.goto_next))
imap('<C-h>', vim.lsp.buf.signature_help)

-- lua/mia/repl.lua
nmap('gxl', require('mia.repl').send_line, { dotrepeat = true })
nmap('gx', require('mia.repl').send_motion, { expr = true, dotrepeat = true })
xmap('gx', require('mia.repl').send_visual)

-- tab moves
local function make_tab_move(forward)
  return function()
    vim.cmd.tabmove((forward and '+' or '-') .. vim.v.count1)
  end
end
nmap('\\t', make_tab_move(true))
nmap('\\T', make_tab_move(false))

-- Delete surrounding function, retains arg the cursor is on.
nmap('dsf', function()
  local query = vim.treesitter.query.get(vim.o.filetype, 'textobjects')
  -- local cursor_node = vim.treesitter.get_node()
  local root = vim.treesitter.get_parser():parse()[1]:root()
  local _, lnum, col = unpack(vim.fn.getcurpos())
  lnum, col = lnum - 1, col - 1

  -- Get all the calls and smallest param here
  local calls, param = {}, {}
  for id, node, _ in query:iter_captures(root, 0, lnum, lnum + 1) do
    if query.captures[id]:match('param') and vim.treesitter.is_in_node_range(node, lnum, col) then
      param = node
    elseif query.captures[id]:match('call.outer') and vim.treesitter.is_in_node_range(node, lnum, col) then
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
    vim.api.nvim_echo({ { 'param or call not found', 'WarningMsg' } }, true, {})
  end
end, { dotrepeat = true })

-- <Tab> is mapped in nvim-treesitter config, so to maintain original behavior
-- for <C-i> (using terminals that support it), this is required
--
-- omap('<Tab>', function() require'nvim-treesitter.incremental_selection'.init_selection() end)
nmap('<C-i>', '<C-i>')

nmap('<C-;>', 'g;')
nmap('<C-,>', 'g,')

nmap('zk', function()
  -- move to the TOP of the prev. fold
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
end)

vim.keymap.set({ 'ca', 'ia' }, 'nvim.', 'vim.api.nvim_')
imap('.', '.<C-]>')
cmap('.', '.<C-]>')
nmap('<MiddleMouse>', '"*p')
xmap('<MiddleMouse>', '"*p')

nmap('<BS>', '"*')
xmap('<BS>', '"*')
