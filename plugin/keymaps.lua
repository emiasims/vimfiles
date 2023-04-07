-- STANDARD KEYMAPS
local cmap = function(...) vim.keymap.set('c', ...) end
local xmap = function(...) vim.keymap.set('x', ...) end
local nmap = function(...) vim.keymap.set('n', ...) end
local tmap = function(...) vim.keymap.set('t', ...) end
local omap = function(...) vim.keymap.set('o', ...) end
local imap = function(...) vim.keymap.set({ 'i', 's' }, ...) end
local map = function(...) vim.keymap.set({ 'n', 'x', 'o' }, ...) end

local remap = { remap = true }
local silent = { silent = true }
-- local cmd = function(a) end
local cmd = function(c) return ('<Cmd>%s<Cr>'):format(c) end

local dotrepeat = function(func, keymap)
  return function()
    vim.fn['repeat#set'](keymap)
    return func()
  end
end

nmap('<F5>', cmd('update|mkview|edit|TSBufEnable highlight'))
nmap('<F8>', cmd('w|so%'))
xmap('s', ':s//g<Left><Left>')
cmap('!', '<C-]>!')

tmap("<Plug>(termLeave)", "<C-\\><C-n>:let b:last_mode = 'n'<Cr>", silent)
tmap("<Plug>(term2nmode)", "<C-\\><C-n>:let b:last_mode = 't'<Cr>", silent)

tmap('<C-h>', '<Plug>(term2nmode)<C-w>h', remap)
tmap('<C-j>', '<Plug>(term2nmode)<C-w>j', remap)
tmap('<C-k>', '<Plug>(term2nmode)<C-w>k', remap)
tmap('<C-l>', '<Plug>(term2nmode)<C-w>l', remap)
tmap('<C-^>', '<Plug>(term2nmode)<C-^>', remap)
tmap('<C-\\>', '<Plug>(term2nmode)<C-w>p', remap)
tmap('<Esc>', '<Plug>(termLeave)', remap)
tmap('<M-n>', '<Plug>(termLeave)', remap)

tmap("<C-Space>", "<Space>")
tmap("<S-Space>", "<Space>")

nmap('<F3>', cmd('messages clear'))
nmap('<F4>', cmd('messages'))

local function open_float_after(func)
  return function()
    if func then func() end
    vim.diagnostic.open_float { focusable = false }
  end
end

nmap('\\d', open_float_after(nil))
nmap('[d', open_float_after(vim.diagnostic.goto_prev))
nmap(']d', open_float_after(vim.diagnostic.goto_next))

imap('<C-h>', function() vim.lsp.buf.signature_help { focusable = false } end)


-- lua/mia/repl.lua
nmap('gx', require('mia.repl').send_motion, { expr = true })
xmap('gx', require('mia.repl').send_visual)
nmap('gxl', dotrepeat(require('mia.repl').send_line, 'gxl'))

-- Delete surrounding function, retains arg the cursor is on.
nmap("dsf", function()
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
      calls[#calls+1] = node
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
end)

-- <Tab> is mapped in nvim-treesitter config, so to maintain original behavior
-- for <C-i> (using terminals that support it), this is required
--
-- omap('<Tab>', function() require'nvim-treesitter.incremental_selection'.init_selection() end)
nmap('<C-i>', '<C-i>')

nmap('<F9>', function()
  if #vim.treesitter.get_captures_at_cursor() > 0 then
    P(vim.treesitter.get_captures_at_cursor())
  else
    vim.fn.SynStack()
  end
end, { desc = 'Print highlight group list at cursor' })

-- ===========================================================================
-- Contextualize keymaps

local ctx = require 'contextualize'
local keymap = ctx.keymap
local abbrev = ctx.abbrev
-- local c = require('contextualize.contexts')
local text = require 'contextualize.text'

keymap.list({ 'n', 'x', 'o' }, '0', {
  {
    rhs = '0',
    context = function() return (text.around_cursor('^', -1) or ''):match('^%s+$') end,
    name = 'Only whitespace before cursor',
    -- desc = 'Go to col 0', -- doesn't work correctly
  },
  {
    rhs = 'g^',
    context = function() return vim.o.wrap end,
    name = "'wrap' is set",
    desc = 'Go to start of wrapped line',
  },
}, { default = '0^' }) -- '0' scrolls to the far left, '^' goes to the first bit of text.
map('g0', '0')

keymap.set({ 'n', 'o' }, '$', 'g$', function() return vim.o.wrap end)
keymap.set('x', '$', 'g$h', function() return vim.o.wrap end, { default = "$h" })
map('g$', '$')

-- Many keymaps in a specific context
-- Result will be cnoreabbrev <expr> lhs <Plug>(map)
abbrev.multi(
  'c',
  {
    he = 'help',
    eft = 'EditFtplugin',
    eq = 'EditQuery',  -- mia.tslib
    ['e!'] = 'mkview | edit!',
    use = 'UltiSnipsEdit',
    ase = 'AutoSourceEnable',
    asd = 'AutoSourceDisable',
    sr = 'SetRepl',
    tr = 'TermRepl',
    vga = 'vimgrep // **/*.<C-r>=expand("%:e")<Cr><C-Left><Left><Left>',
    cqf = 'Clearqflist',
    w2 = 'w',
    dws = 'mkview | silent! %s/\\s\\+$// | loadview | update',
    eh = "edit <C-r>=expand('%:h')<Cr>/",
    T = "execute 'term fish'|startinsert<C-left><Right><Right><Right><Right>",
    term = 'term fish',
    f = 'Telescope fd',
    o = 'Telescope fd cwd=~/org',
    u = 'Telescope undo',
    l = 'Telescope buffers',
    t = 'Telescope tags',
    mr = 'Telescope oldfiles',
    A = 'Telescope live_grep',
    h = 'Telescope help_tags',
    ev = 'Telescope fd cwd=' .. vim.fn.stdpath 'config',
    evr = 'Telescope fd cwd=' .. os.getenv 'VIMRUNTIME',
    evs = 'Telescope fd cwd=' .. vim.fn.stdpath('data') .. '/site/pack/packer',
    zo = 'lua require("mia.zotfun").pick()',
    zc = 'lua require("mia.zotfun").cite()',
  },
  -- Basically, when a command can be completed, I want the above expansions
  function() return vim.fn.getcmdcompltype() == 'command' end
)

local function cmdline_is(str)
  return {
    function()
      local cmdline = vim.split(vim.fn.getcmdline(), ' ')
      -- Use getcmdpos() to get where we are instead of #cmdline
      return vim.fn.getcmdcompltype() == 'command' and cmdline[#cmdline] == str
    end,
    name = ('command = "%s"'):format(str),
  }
end

-- I want <Space> to expand an empty command line to 'lua ',
-- ':eh' to ':edit (here)/' (no space!) and similar for 'vga'.
-- mapping <Space> removes its ability to properly expand abbreviations, so add
-- it back in by defaulting to '<C-]> ', forcing the expansion if one exists.
keymap.list('c', ' ', {
  { rhs = 'lua ', context = cmdline_is '' },
  { rhs = '<C-]>', context = cmdline_is 'eh' },
  { rhs = '<C-]>', context = cmdline_is 'vga' },
}, { default = '<C-]> ' })


-- ===========================================================================
-- Custom autopairs

-- Context for when a pair is allowed. Here, there is no next character
-- (in other words the cursor is at the end of the line) or the next character
-- is a non word character.
local pair_allowed = function()
  return (text.next() or ' '):match '%W'
end

-- Double quotes have an additional requirement: the previous character
-- must not be a word character. So we'll still be able to use single quotes
-- in comments, for example.
local quote_allowed = function ()
  return (text.prev() or ' '):match '%W' and pair_allowed()
end

-- 'lhs' is provided in the environment of the function, makes reusing
-- contexts based on the keymap straightforward
local completing_pair = {
  function()
    return text.next() == ctx.lhs -- if using fenv, lhs instead of context.lhs is fine.
  end,
  name = function() -- lhs can also be used in names
    return ('Nextchar == "%s"'):format(ctx.lhs)
  end,
}

-- context for when the two surrounding characters are one of the pairs
local re = vim.regex [[^\%(\V()\|{}\|[]\|''\|""\)]]
local within_pair = {
  function()
    return re:match_str(text.around_cursor(-1, 0) or '')
  end,
  name = 'Inside pair'
}

-- Set up undo-preserving <Left> and <Right>
local left, right = '<C-g>U<Left>', '<C-g>U<Right>'

-- Set the keybinds to insert the pairs
keymap.multi({ 'i', 's' }, {
  ['('] = '()' .. left,
  ['['] = '[]' .. left,
  ['{'] = '{}' .. left,
}, { pair_allowed, name = 'Nextchar != word char' })

-- Completing a pair is just tapping the <Right> key.
keymap.multi({ 'i', 's' }, {
  [')'] = right,
  [']'] = right,
  ['}'] = right,
  -- ['"'] = right,
  -- ["'"] = right,
}, completing_pair)

keymap.list({ 'i', 's' }, "'", {
  { right, completing_pair },
  { "''" .. left, quote_allowed }
})

keymap.list({ 'i', 's' }, '"', {
  { rhs = right, context = completing_pair },
  { rhs = '""' .. left, context = quote_allowed },
})

-- If we're inside a pair, <BS> to delete both, <Cr> to insert an
-- additional newline, and <Space> to insert two spaces.
keymap.set({ 'i', 's' }, '<BS>', { '<BS><Del>', desc = "Delete pair" }, within_pair)
keymap.set({ 'i', 's' }, '<BS>', { '<BS><Del>', desc = "Delete pair" }, within_pair)
keymap.set({ 'i', 's' }, '<Space>', '  ' .. left, within_pair, { default = '<C-]> ' })

local pumvisible = { function() return vim.fn.pumvisible() ~= 0 end, name = 'pumvisible' }
-- I don't want cmp.nvim to modify my keybinds, so use a plug mapping and then
-- do it myself. see completion.lua for <Plug>(miaConfirmCmp) definition
keymap.list('i', '<Cr>', {
  { rhs = '<Plug>(miaConfirmCmp)', context = require('cmp').visible },
  { rhs = '<C-y>', context = pumvisible},
  { rhs = '<Cr><C-c>O', context = within_pair },
})

local ls = require('luasnip')

-- stylua: ignore
keymap.multi({ 'i', 's' }, {
  ['<Tab>'] = { function() ls.jump(1) end, desc = 'Jump to next node', },
  ['<S-Tab>'] = { function() ls.jump(-1) end, desc = 'Jump to previous node', },
}, ls.in_snippet, { name = 'in luasnip' })

keymap.set('i', '<Esc>', '<C-e>', pumvisible)
