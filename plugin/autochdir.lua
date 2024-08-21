vim.opt.autochdir = false

local special = {
  vim.env.VIMRUNTIME,
  vim.env.HOME .. '/.config/kitty',
  vim.env.HOME .. '/.config/fish',
  vim.env.HOME .. '/.config/zsh',
  vim.fn.stdpath('config') .. '/mia_plugins',
}

local function gitdir(path, bufnr)
  -- process special 'path's first
  if vim.b[bufnr].autochdir then
    return vim.b[bufnr].autochdir
  elseif path:match('^fugitive') then
    return path:match('fugitive://(.*)/%.git.*')
  elseif path:match('/lib/python3') and path:match('/site%-packages/[^/]') then
    -- looking at installed packages' code
    return path:match('.*/site%-packages/[^/]+')
  elseif path:match('/lib/python3') then
    -- python stdlib
    return path:match('.*/lib/python3[^/]+')
  end

  -- look for git dir, go if found
  local dir = vim.fn.finddir('.git', path .. ';')
  if dir ~= '' then
    return vim.fn.fnamemodify(dir, ':p'):match('(.*)/%.git/?')
  end

  -- fallbacks
  for _, dir in ipairs(special) do ---@diagnostic disable-line: redefined-local
    if vim.startswith(path, dir) then
      return dir
    end
  end

  -- file dir
  return vim.fn.fnamemodify(path, ':p:h')
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('mia-chdir', { clear = true }),
  desc = ':lcd into git dir',
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    if bo.modifiable and bo.buftype == '' then
      vim.cmd.lcd(gitdir(ev.match, ev.buf))
    end
  end,
})

vim.api.nvim_create_user_command('FixAutochdir', function()
  vim.b.autochdir = nil
  vim.cmd.lcd(gitdir(vim.fn.expand('%:p'), vim.fn.bufnr()))
end, {})
