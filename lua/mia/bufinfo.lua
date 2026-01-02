local M = {}

---@type string[]
local special_roots = {
  vim.env.VIMRUNTIME,
  vim.env.HOME .. '/.config/kitty',
  vim.env.HOME .. '/.config/fish',
  vim.env.HOME .. '/.config/zsh',
  vim.fn.stdpath('config') .. '/mia_plugins',
}

--- @return string
local function check_root(bufname)
  for _, root in ipairs(special_roots) do
    if vim.fs.relpath(root, bufname) then
      return root
    end
  end
end

-- TODO hook for session saving / loading
local function shorten_home(path)
  local rel_path = vim.fs.relpath('~', path)
  return rel_path and ('~/' .. rel_path) or path
end

-- saved in b: vars
local git_cache = setmetatable({}, { __mode = 'v' })

--- @param gitdir string
--- @return { gitdir: string, head: string, path: string, short: string }
local function git_info(gitdir)
  if not git_cache[gitdir] then
    local path = vim.fn.FugitiveWorkTree(gitdir)
    git_cache[gitdir] = {
      gitdir = gitdir,
      head = vim.fn.FugitiveHead(1, gitdir),
      path = path,
      short = shorten_home(path) or path,
    }
  end
  return git_cache[gitdir]
end

--- @return string?
local function lookup_git_dir(bufnr)
  local git_dir = vim.b[bufnr].git_dir or vim.fn.FugitiveGitDir(bufnr)
  return git_dir ~= '' and git_dir or nil
end

local BT = {

  file = function(bufname, bufnr)
    local git
    local git_dir = lookup_git_dir(bufnr)
    if git_dir then
      git = git_info(git_dir)
    end

    local root = git and git.path or check_root(bufname)
    local path = bufname
    root = root or (git and git.path or vim.fs.dirname(path))

    return {
      type = 'file',
      name = vim.fs.basename(path),
      root = root,
      dir = vim.fs.dirname(vim.fs.relpath(root, path)),
      git = git,
    }
  end,

  terminal = function(bufname, bufnr)
    local dir, pid, cmd = bufname:match('^term://(.*)/(%d+):(.*)$')
    local title = vim.b[bufnr].term_title or ''
    return {
      type = cmd,
      name = title,
      tab_name = ('[%s:%s]'):format(cmd, title:sub(1, 20)),
      pid = pid,
      dir = dir,
    }
  end,

  quickfix = function()
    local title = vim.fn.getqflist({ title = true }).title or ''
    return { type = 'quickfix', name = title }
  end,

  nofile = function(_, bufnr)
    local git_dir = lookup_git_dir(bufnr)
    local dir = git_dir and git_info(git_dir).short or shorten_home(vim.fn.getcwd())
    return { type = 'scratch', dir = dir }
  end,
}

--- @return { name: string, type: 'file'|'nofile'|'quickfix'|'scratch'|string, [string]: any? }
function M.get(bufnr_)
  local function _get(bufnr)
    if bufnr == 0 then
      bufnr = vim.api.nvim_get_current_buf()
    end
    local buftype = vim.bo[bufnr].buftype
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    local git_dir = vim.b[bufnr].git_dir or vim.fn.FugitiveGitDir(bufnr)
    if git_dir == '' then
      git_dir = nil
    end

    local bufinfo
    if bufname == '' then
      bufinfo = BT.nofile(bufname, bufnr)
    elseif buftype == '' then
      bufinfo = BT.file(bufname, bufnr)
    elseif BT[buftype] then
      bufinfo = BT[buftype](bufname, bufnr)
    else
      local name = vim.fs.basename(bufname)
      bufinfo = { type = buftype, name = name or bufname }
    end

    bufinfo.bufname = bufname
    bufinfo.bufnr = bufnr
    bufinfo.listed = vim.bo[bufnr].buflisted

    local update = vim.b[bufnr].update_bufinfo
    if update then
      if type(update) == 'function' then
        update = update(vim.deepcopy(bufinfo))
      end
      bufinfo = vim.tbl_extend('force', bufinfo, update or {})
    end

    return bufinfo
  end

  local ok, info = pcall(_get, tonumber(bufnr_ or 0))
  if not ok then
    return { type = 'error', name = 'bufinfo', error = info }
  end
  return info
end

local function update_bufinfo(ev)
  local old = vim.b[ev.buf].bufinfo
  local new = M.get(ev.buf)
  if not vim.deep_equal(old, new) then
    vim.b[ev.buf].bufinfo = new
    vim.api.nvim_exec_autocmds('User', { pattern = 'BufInfo', data = new, modeline = false })
  end
end

mia.augroup('bufinfo', {
  BufEnter = update_bufinfo,
  BufFilePost = update_bufinfo,
  TermEnter = update_bufinfo,
  TermRequest = update_bufinfo,
  OptionSet = { pattern = 'buftype', callback = update_bufinfo },
})

return setmetatable(M, {
  __call = function(_, bufnr)
    bufnr = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
    return vim.b[bufnr].bufinfo or M.get(bufnr)
  end,
})
