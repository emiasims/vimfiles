-- local contextualize = require('contextualize')
-- local ac = require('contextualize.fenv').around_cursor

-- contextualize.keymap({ 'i', 's' }, ':',
--   '<BS><BS><Del><C-o>:lua require("mia.zotero").cite()<Cr>',
--   -- function() require("mia.zotero").cite() end,
--   function() return ac(-2, 0) == '[c]' end,
--   { buffer = true, name = 'Previous word == "cite"' })

-- contextualize.keymap({ 'i', 's' }, ':',
--   '<BS><BS><Del><C-o>:',
--   -- function() require("mia.zotero").cite() end,
--   function() return ac(-2, 0) == '[c]' end,
--   { buffer = true, name = 'Previous word == "cite"' })



local q = vim.treesitter.query.parse('org',
  [[(directive name: (_) @name (#match? @name "^keymap\\[.?(nore)?(map|abbrev)\\]"))]])

local root = vim.treesitter.get_parser():parse()[1]:root()
local node, lnum, line, cmd, args, group, regex
for _, match, _ in q:iter_matches(root, 0, 0, -1) do
  _, node = next(match)
  lnum = node:start()
  line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1]
  cmd, args = line:gmatch '#%+keymap%[(%a+)%]: (.+)'()
  vim.cmd(('%s <buffer> %s'):format(cmd, args))
end

q = vim.treesitter.query.parse('org', [[(directive name: (_) @name (#lua-match? @name "^hlmatch%[(@?[.%a]+)%]"))]])

for _, match, _ in q:iter_matches(root, 0, 0, -1) do
  _, node = next(match)
  lnum = node:start()
  line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1]
  group, regex = line:gmatch '#%+hlmatch%[(@?[.%a]+)%]: (.+)'()
  vim.fn.matchadd(group, regex)
  -- vim.cmd(('%s <buffer> %s'):format(cmd, args))
end

-- (item . (_) @todo (#eq? @todo "TODO"))
-- (item . (_) @preproc (#eq? @preproc "DONE"))



-- org.directive_action(directive_pattern or function (applied to everything) or query, action (function(Directive)))
-- org.directive_action[^keymap]

vim.b.allow_zero_length_folds = true

local opts = { buffer = true }
local nmap, imap = require('mapfun')({'n', 'i'}, opts)

nmap('K', require 'mia.zotero'.zotero_open)
nmap('K', require 'mia.zotero'.zotero_select)

imap(';c', require 'mia.zotero'.cite)

local ctx = require 'ctx'
local in_query = ctx.treesitter.in_query

-- q.checkbox.status.eq("/")
-- q.checkbox.status.eq("/").set("X")
ctx.set('n', '~', {
    { rhs = '[%lr/', context = in_query('org', '(checkbox !status) @cursor'), remap = true },
    { rhs = 'rX', context = in_query('org', '(checkbox (status) @_s (#eq? @_s "/")) @cursor') },
    { rhs = 'r ', context = in_query('org', '(checkbox (status) @_s (#eq? @_s "X")) @cursor') },
  }, { default = ctx.global, buffer = true, repeat_count = true })

local function kwq(kw)
  return ([[(headline (stars) @cursor (item . (_) @_kw (#eq? @_kw "%s")))]]):format(kw)
end

-- ctx.set()
ctx.add('n', '~', {
  { rhs = '0f lciwDONE<Esc>0', context = in_query('org', kwq('TODO')) },
  { rhs = '0f lciwCANCELLED<Esc>0', context = in_query('org', kwq('DONE')) },
  { rhs = '0f ldaw0', context = in_query('org', kwq('CANCELLED')) },
  { rhs = '0f i TODO<Esc>0', context = in_query('org', '(headline (stars) @cursor)') },
}, { buffer = true })

ctx.set('n', '<A-`>', {
  { rhs = '0f ldaw0', context = in_query('org', kwq('TODO')) },
  { rhs = '0f lciwTODO<Esc>0', context = in_query('org', kwq('DONE')) },
  { rhs = '0f lciwDONE<Esc>0', context = in_query('org', kwq('CANCELLED')) },
  { rhs = '0f i CANCELLED<Esc>0', context = in_query('org', '(headline (stars) @cursor)') },
}, { buffer = true })

nmap('<C-`>', '<A-`>', { remap = true })
