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
  buffer = true,
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

local bufname = vim.api.nvim_buf_get_name(0)
if bufname:match('/lib/python3') and bufname:match('/site%-packages/[^/]') then
  -- looking at installed packages' code
  local root = bufname:match('.*/site%-packages/[^/]+')
  local pkg = vim.fs.basename(root)
  vim.b.update_bufinfo = {
    type = 'site-pkg:' .. pkg,
    root = root,
    dir = vim.fs.dirname(vim.fs.relpath(root, bufname)),
  }
elseif bufname:match('/lib/python3') then
  -- python stdlib
  local root = bufname:match('.*/lib/python3[^/]+')
  vim.b.update_bufinfo = {
    type = 'stdlib',
    root = root,
    dir = vim.fs.dirname(vim.fs.relpath(root, bufname)),
  }
end
