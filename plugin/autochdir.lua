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

mia.augroup('autochdir', {
  BufEnter = function(ev)
    local bo = vim.bo[ev.buf]
    if bo.modifiable and bo.buftype == '' then
      local ok, err = pcall(vim.cmd.lcd, gitdir(ev.match, ev.buf))
      if not ok then
        mia.err('autochdir lcd failed: ' .. err)
      end
    end
  end,
  VimLeavePre = "autocmd VimLeavePre * exec 'silent! lcd ' .. getcwd(-1, -1)",
})

mia.command('FixAutochdir', function()
  vim.b.autochdir = nil
  vim.cmd.lcd(gitdir(vim.fn.expand('%:p'), vim.fn.bufnr()))
end)
