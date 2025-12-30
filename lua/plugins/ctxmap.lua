---@type LazySpec
return {
  'milisims/ctxmap.nvim',
  -- FIXME: reloading doesn't reload keys defined like this
  dev = true,
  event = 'VeryLazy',
  keys = {
    { '<F1>', '<Plug>(ctxmap-debug)', mode = { '', 't', '!' } },
    { 'g0', '0', mode = { 'n', 'x', 'o' } },
    { 'g$', '$', mode = { 'n', 'x', 'o' } },
  },
  ---@module "ctxmap"
  ---@type ctxmap.config
  opts = {
    extensions = { lazy_handler = true },
    fix_abbr_expansion = true, -- 'default_only' ? 'all', false
    contexts = {
      ws_precursor = 'text.before("^%s*$")',
      blink_visible = 'require("blink.cmp").is_visible()',
      cmd_start_sp = 'cmd.start(lhs, map) and abbr.trigger(" ")',
      autopair = {
        allowed = 'text.after("%W") or text.eol()',
        quote_allowed = '(text.before("%W") or text.sol()) and autopair.allowed()',
        complete = 'text.after(vim.pesc(lhs))',

        pares = { '()', '[]', '{}', "''", '""' },
        pat = function(pair)
          local l, r = pair:sub(1, 1), pair:sub(2, 2)
          return vim.pesc(l) .. '(%s*)%#%1' .. vim.pesc(r)
        end,
        nlpat = function(pair)
          local l, r = pair:sub(1, 1), pair:sub(2, 2)
          return vim.pesc(l) .. '%s*\n%s*%#%s*\n%s*' .. vim.pesc(r)
        end, --
        in_pair = 'vim.iter(autopair.pares):map(autopair.pat):any(text.line)',
        in_nlpair = 'vim.iter(autopair.pares):map(autopair.nlpat):any(lines.surround(1))',
      },
    },
  },
  ctxmap = {
    -- '{':
    -- if (ws_precusor) and after is empty or ws, normal '{'
    -- if not on @local.scope, go up to @local.scope
    -- if on @local.scope and theres a sibling, go to sibling
    -- if on @local.scope and no sibling, go to parent
    {
      '0',
      { { 'text.before("^%s+$")', '0' }, { 'opt.wrap', 'g^' } },
      default = '0^',
      mode = { 'n', 'x', 'o' },
    },
    { '$', { 'opt.wrap', 'g$' }, mode = { 'n', 'o' } },
    { '$', { 'opt.wrap', 'g$h' }, mode = 'x', default = '$h' },

    { '<C-h>', { 'win.left', 'gT9<C-w>l' }, default = '<C-w>h' },
    { '<C-l>', { 'win.right', 'gt9<C-w>h' }, default = '<C-w>l' },
    {
      mode = 'i',
      { '<Esc>', { { 'fn.pumvisible()', '<C-e>' }, { 'blink_visible', '<C-e>', remap = true } } },
      {
        '<Cr>',
        {
          { 'blink_visible', '<Plug>(miaCmpConfirm)' },
          { 'fn.pumvisible()', '<C-y>' },
          { 'autopair.in_pair', '<Cr><C-c>O' },
        },
      },
    },
    { -- autopairs
      mode = { 'i', 's' },
      {
        ctx = 'autopair.allowed',
        { '(', '()<C-]><C-g>U<Left>' },
        { '[', '[]<C-]><C-g>U<Left>' },
        { '{', '{}<C-]><C-g>U<Left>' },
      },

      {
        ctx = 'autopair.complete',
        { ')', '<C-]><C-g>U<Right>' },
        { ']', '<C-]><C-g>U<Right>' },
        { '}', '<C-]><C-g>U<Right>' },
        { '"', '<C-]><C-g>U<Right>' },
        { "'", '<C-]><C-g>U<Right>' },
      },

      { '"', { 'autopair.quote_allowed', '""<C-]><C-g>U<Left>' }, clear = false },
      { "'", { 'autopair.quote_allowed', "''<C-]><C-g>U<Left>" }, clear = false },

      { ' ', { 'autopair.in_pair', '  <C-g>U<Left>' } },
      { '<BS>', { 'autopair.in_pair', '<BS><Del>' } },
      { '<BS>', { 'autopair.in_nlpair', '<C-o>vwhobld' }, clear = false },
    },
    {
      ' ',
      {
        { 'cmd.start', 'lua ' },
        { 'require("blink.cmp").is_visible()', '<Cmd>lua require("blink.cmp").hide()<CR> ' },
      },
      mode = 'c',
    },
    { -- cmdline start abbreviations, space special
      mode = 'ca',
      ctx = 'cmd.start(lhs, map) and abbr.trigger(" ")',
      { 'eq', 'vsp|TSEditQuery' },
      { 'eqa', 'vsp|TSEditQueryUserAfter' },
      { 'T', 'execute "term"<Left>' },
    },
    { -- cmdline start abbreviations
      mode = 'ca',
      ctx = 'cmd.start',
      { 'sq', 'Session quit' },
      { 'qq', 'Session quit' },

      { 'he', 'help' },
      { 'eft', 'EditFtplugin' },
      { 'eq', 'vsp|TSEditQuery highlights' },
      { 'eqa', 'vsp|TSEditQueryUserAfter highlights' },
      { 'es', 'vertical EditSnippets' },
      { 'e!', 'mkview | edit!' },
      { 'use', 'UltiSnipsEdit' },
      { 'ase', 'AutoSourceEnable' },
      { 'asd', 'AutoSourceDisable' },
      { 'vga', 'vimgrep // **/*.<C-r>=expand("%:e")<Cr><C-Left><Left><Left>', eat = '%s' },
      { 'ccle', 'Cclearquickfix' },
      { 'cclear', 'Cclearquickfix' },
      { 'lcle', 'Lclearloclist' },
      { 'lclear', 'Lclearloclist' },
      { 'lf', 'luafile%' },
      { 'w2', 'w' },
      { 'dws', 'mkview | silent! %s/\\s\\+$// | loadview | update' },
      { 'eh', 'edit <C-r>=expand("%:h")<Cr>/', eat = ' ' },
      { 'mh', 'Move <C-r>=expand("%:h")<Cr>/', eat = '%s' },
      { 'mf', 'edit ~/.config/nvim/lua/mia/<C-z>', eat = ' ' },
      { 'T', 'execute "term fish"|startinsert' },
      { 'term', 'term fish' },
      { 'res', 'restart Session load last' },

      { 'tc', 'TabCopy' },
      { 'tsl', 'TabSlice' },
      { 'tsp', 'tab split' },
    },
  },
}
