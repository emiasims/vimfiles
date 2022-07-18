vim.keymap.set('n', '<F5>', '<Cmd>update|mkview|edit|TSBufEnable highlight<Cr>')
vim.keymap.set('x', 's', ':s//g<Left><Left>')


local contextualize = require('contextualize')
-- local c = require('contextualize.contexts')
local fenv = require('contextualize.fenv')

local function cmdline_is(str, type)
  type = type or ':'
  return {
    function()
      return vim.fn.getcmdtype() == type and vim.fn.getcmdline() == str
    end,
    name = ('Cmdline = "%s%s"'):format(type, str),
  }
end

contextualize.keymap('c', ' ', {
  { rhs = 'lua ', context = cmdline_is '' },
  { rhs = '<C-]>', context = cmdline_is 'eh' },
  { rhs = '<C-]>', context = cmdline_is 'vga' },
}, { default = '<C-]> ' })


-- Many keymaps in a specific context
-- Result will be cnoreabbrev <expr> lhs <Plug>(map)
contextualize.abbrev(
  'c',
  {
    he = 'help',
    eft = 'EditFtplugin',
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
    l = 'Telescope buffers',
    t = 'Telescope tags',
    mr = 'Telescope oldfiles',
    A = 'Telescope live_grep',
    h = 'Telescope help_tags',
    ev = 'Telescope fd cwd=' .. vim.fn.stdpath 'config',
    evr = 'Telescope fd cwd=' .. os.getenv 'VIMRUNTIME',
  },
  fenv(function()
    return vim.fn.getcmdtype() == ':' and lhs == vim.fn.getcmdline()
  end, 'Start of cmdline')
)
-- internally, the above is done like
-- context = function() lhs = tbl.lhs return cmd_start() end
-- Note: this only done for context.set

-- Context for when a pair is allowed. Here, there is no next character
-- (in other words the cursor is at the end of the line) or the next character
-- is a non word character.
local pair_allowed = fenv(function()
  return not nc() or nc():match '%W'
end)

-- Double quotes have an additional requirement: the previous character
-- must not be a word character. So we'll still be able to use single quotes
-- in comments, for example.
local quote_allowed = fenv(function ()
  return (not pc() or pc():match('%W')) and pair_allowed()
end)

-- 'lhs' is provided in the environment of the function, makes reusing
-- contexts based on the keymap straightforward
local completing_pair = {
  fenv(function()
    P(nc())
    return nc() == lhs -- if using fenv, lhs instead of context.lhs is fine.
  end),
  name = function() -- lhs can also be used in names
    return ('Nextchar == "%s"'):format(lhs)
  end,
}

-- context for when the two surrounding characters are one of the pairs
local re = vim.regex [[^\%(\V()\|{}\|[]\|''\|""\)]]
local within_pair = fenv(function()
  return re:match_str(around_cursor(-1, 0) or '')
end, 'Inside pair')

-- Set up undo-preserving <Left> and <Right>
local left, right = '<C-g>U<Left>', '<C-g>U<Right>'

-- Set the keybinds to insert the pairs
contextualize.keymap({ 'i', 's' }, {
  ['('] = '()' .. left,
  ['['] = '[]' .. left,
  ['{'] = '{}' .. left,
}, { pair_allowed, name = 'Nextchar != word char' })

-- Completing a pair is just tapping the <Right> key.
contextualize.keymap({ 'i', 's' }, {
  [')'] = right,
  [']'] = right,
  ['}'] = right,
}, completing_pair)

local contexts = { completing_pair, quote_allowed }
contextualize.keymap({ 'i', 's' }, "'",   { right, "''" .. left }, contexts)
contextualize.keymap({ 'i', 's' }, '"', { right, '""' .. left }, contexts)

-- If we're inside a pair, <BS> to delete both, <Cr> to insert an
-- additional newline, and <Space> to insert two spaces.
contextualize.keymap({ 'i', 's' }, {
  ['<BS>'] = { '<BS><Del>', desc = "Delete pair" },
  ['<Space>'] = '  ' .. left,
}, within_pair)

local pumvisible = { function() return vim.fn.pumvisible() ~= 0 end, name = 'pumvisible' }
-- see completion.lua for <Plug>(miaConfirmCmp) definition
contextualize.keymap('i', '<Cr>', {
  { rhs = '<Plug>(miaConfirmCmp)', context = require('cmp').visible },
  { rhs = '<C-y>', context = pumvisible},
  { rhs = '<Cr><C-c>O', context = within_pair },
})

local ls = require('luasnip')

-- stylua: ignore
contextualize.keymap({ 'i', 's' }, {
  ['<Tab>'] = { function() ls.jump(1) end, desc = 'Jump to next node', },
  ['<S-Tab>'] = { function() ls.jump(-1) end, desc = 'Jump to previous node', },
}, ls.in_snippet, { name = 'in luasnip' })

contextualize.keymap('i', '<Esc>', '<C-e>', pumvisible)
