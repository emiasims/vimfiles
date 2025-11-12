local M = {}

-- see
-- :h 'bt'
-- :h special-buffers
-- :h win_gettype()

local shorten_home = function(path)
  local rel_path = vim.fs.relpath('~', path)
  return rel_path and ('~/' .. rel_path) or path
end

local git_cache = setmetatable({}, {
  __mode = 'v',
  __index = function(t, path)
    local rel_path = shorten_home(path)
    t[path] = { path = path, short = rel_path or path }
    return t[path]
  end,
})

local git_info = function(gitroot, bufnr)
  local t = git_cache[gitroot]
  if not bufnr then
    return t
  end
  local ok, res = pcall(vim.fn.FugitiveHead, 1, bufnr)
  if ok and res ~= '' then
    t.branch = res
  end
  return t
end

M.file_with_git = function(bufpath, bufnr, gitroot)
  local rel_path = vim.fs.relpath(gitroot, bufpath)
  return {
    type = 'file',
    path = bufpath,
    relative_path = rel_path,
    file = vim.fs.basename(rel_path),
    dir = vim.fs.dirname(rel_path),
    root = git_info(gitroot, bufnr),
  }
end

M.file_nogit = function(bufname, _)
  local shortname = shorten_home(bufname)
  return {
    type = 'file',
    path = bufname,
    relative_path = shortname,
    file = vim.fs.basename(shortname),
    dir = vim.fs.dirname(shortname),
  }
end

M.terminal = function(bufname, bufnr)
  local dir, pid, cmd = bufname:match('^term://(.*)/(%d+):(.*)$')
  return {
    type = 'terminal',
    title = vim.b[bufnr].term_title or '', -- set by terminal
    dir = dir,
    pid = pid,
    cmd = cmd,
  }
end

M.quickfix = function()
  return {
    type = 'quickfix',
    title = vim.fn.getqflist({ title = true }).title or '',
  }
end

M.help = function(bufname)
  return { type = 'help', file = vim.fs.basename(bufname) }
end


M.nofile = function(_, bufnr, gitroot)
  if _G.Snacks then ---@diagnostic disable-line: unnecessary-if
    for _, explorer in ipairs(Snacks.picker.get({ source = 'explorer' })) do
      for _, w in ipairs(explorer.layout:get_wins()) do
        if w.buf == bufnr then
          return { type = 'directory', cwd = explorer:cwd() }
        end
      end
    end
  end

  if gitroot then
    return { type = 'scratch', cwd = git_info(gitroot).short }
  end
  return { type = 'scratch', cwd = shorten_home(vim.fn.getcwd()) }
end

M.get = function(bufnr)
  bufnr = tonumber(bufnr or 0) --[[@as integer]]
  local buftype = vim.bo[bufnr].buftype
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local gitroot = vim.fs.root(bufname, '.git')

  local bufinfo = {}
  if bufname == '' then
    -- could be scratch or a directory
    bufinfo = M.nofile(bufname, bufnr, gitroot)
  elseif buftype == '' and gitroot then
    -- normal file with git repo
    vim.b[bufnr].workspace_folder = gitroot -- for copilot
    bufinfo = M.file_with_git(bufname, bufnr, gitroot)
  elseif buftype == '' then
    -- normal file
    bufinfo = M.file_nogit(bufname, bufnr)
  elseif M[buftype] then ---@diagnostic disable-line: unnecessary-if
    -- other known buftypes
    bufinfo = M[buftype](bufname, bufnr)
  end

  bufinfo.bufname = bufname
  bufinfo.bufnr = bufnr
  bufinfo.listed = vim.bo[bufnr].buflisted

  return bufinfo
end

---@return string, string?
M.tabline = function(bufnr)
  local info = M.get(bufnr)
  if info.type == 'file' then
    return info.file, vim.fs.basename(vim.fs.dirname(info.path))
  elseif info.type == 'terminal' then
    ---@cast info.title string
    return ('[%s:%s]'):format(info.cmd, info.title:sub(1, 20)), info.pid
  elseif info.type == 'help' then
    return ('[help:%s]'):format(info.file)
  elseif info.type == 'quickfix' then
    return '[quickfix]'
  elseif info.type == 'directory' then
    return ('[dir:%s]'):format(vim.fs.basename(info.cwd))
  elseif info.type == 'scratch' then
    return '[Scratch]'
  end
  return '[?]'
end

M.statusline = function(bufnr)
  local info = M.get(bufnr)
  if info.type == 'file' and info.root then
    return ('(%s)%s/'):format(info.root.branch, info.dir), info.file
  elseif info.type == 'file' then
    return info.dir .. '/', info.file
  elseif info.type == 'terminal' then
    return info.cmd, info.title
  elseif info.type == 'help' then
    return '[Help]', info.file
  elseif info.type == 'quickfix' then
    return '[Quickfix]', info.title
  elseif info.type == 'directory' then
    return info.cwd .. '/', '[Explorer]'
  elseif info.type == 'scratch' then
    return info.cwd .. '/', '[Scratch]'
  end
  return { '[?]', '??' }
end

return setmetatable(M, {
  __call = function(_, ...)
    return M.get(...)
  end,
})
