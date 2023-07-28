vim.opt.autochdir = false

local function gitdir(path, bufnr)
  if vim.b[bufnr].autochdir then
    return vim.b[bufnr].autochdir
  end
  local dir = vim.fn.finddir('.git', path .. ';')
  if dir ~= '' then
    return vim.fn.fnamemodify(dir, ':p'):match '(.*)/%.git/?'
  end
  return vim.fn.fnamemodify(path, ':p:h')
end

local gid = nvim.create_augroup('mia-chdir', { clear = true })
nvim.create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = gid,
  desc = ':lcd into git dir',
  callback = function(ev) vim.cmd.lcd(gitdir(ev.match, ev.buf)) end,
})

nvim.create_autocmd('DirChanged', {
  group = gid,
  desc = 'manually set autochdir',
  callback = function(ev) vim.b[ev.buf].autochdir = vim.fn.getcwd() end,
})
