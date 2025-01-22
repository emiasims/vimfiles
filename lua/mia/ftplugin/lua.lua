-- nnoremap <silent> <expr> <buffer> K ':help ' . expand('<cword>') . ((expand('<cWORD>') =~# expand('<cword>') . '(') ? "(\<Cr>" : "\<Cr>")

H = {}
function H.is_spec(buf, filename)
  return filename:match('_spec.lua$')
end

return {
  opts = {
    tagfunc = 'v:lua.vim.lsp.tagfunc',
    comments = ':---,:--',
    shiftwidth = 2,
  },
  var = { refactor_prefix = 'local' },
  keys = {
    -- { '\\t', '<Plug>PlenaryTestFile', cond = H.is_spec },
    {
      mode = 'i',
      { '<C-v><Esc>', '<lt>Esc>' },
      { '<C-v><Tab>', '<lt>Tab>' },
      { '<C-v><Cr>', '<lt>Cr>' },
      vim
        .iter(vim.fn.range(97, 122))
        :map(vim.fn.nr2char)
        :map(function(c)
          return { ('<C-v><C-%s>'):format(c), ('<lt>C-%s>'):format(c) }
        end)
        :totable(),
    },
  },
  ctx = {
    {
      '~',
      { { 'ciwTrue<Esc>`[', node = 'false' }, { 'ciwFalse<Esc>`[', node = 'true' } },
      default = '<ctx:global>',
    },
    { 'as', { '[[@as]]<Left><Left>', '<Ctx:prefix>--as' } },
  },
}
