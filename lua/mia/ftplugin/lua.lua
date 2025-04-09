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
  ctxmap = {
    {
      '~',
      {
        { 'ts.is_node("false")', 'ciwtrue<Esc>`[' },
        { 'ts.is_node("true")', 'ciwfalse<Esc>`[' },
      },
      -- default = 'G[~]',
    },
    { 'as', { 'text.before("--as$")', '[[@as]]<Left><Left>' }, mode = 'ia' },
  },
}
