vim
  .iter({
    tabstop = 4,
    shiftwidth = 4,
    foldminlines = 2,
    colorcolumn = '100',
  })
  :each(function(k, v)
    vim.opt_local[k] = v
  end)

mia.keymap({
  mode = 'ia',
  { 'ipdb', "__import__('ipdb').set_trace()<Left><Esc>" },
  { 'pdb', "__import__('pdb').set_trace()<Left><Esc>" },
  { 'iem', "__import__('IPython').embed()<Left><Esc>" },
  { 'true', 'True' },
  { 'false', 'False' },
  { '&&', 'and' },
  { '||', 'or' },
  { '--', '#' },
  { 'nil', 'None' },
  { 'none', 'None' },
})
