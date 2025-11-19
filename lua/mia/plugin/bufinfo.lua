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

---@type table<string, fun(bufname:string, bufnr:integer, gitroot?:string):table>
local BT = {}

BT.file_with_git = function(bufpath, bufnr, gitroot)
  local rel_path = vim.fs.relpath(gitroot, bufpath)
  local info = {
    type = 'file',
    path = bufpath,
    relative_path = rel_path,
    file = vim.fs.basename(rel_path),
    dir = vim.fs.dirname(rel_path),
    root = git_info(gitroot, bufnr),
  }
  info.tabline = { info.file, vim.fs.basename(vim.fs.dirname(info.path)) }
  info.statusline = { ('(%s)%s/'):format(info.root.branch, info.dir), info.file }
  info.wintitle = { info.relative_path, info.root.short }
  return info
end

BT.file_nogit = function(bufname, _)
  local shortname = shorten_home(bufname)
  local info = {
    type = 'file',
    path = bufname,
    relative_path = shortname,
    file = vim.fs.basename(shortname),
    dir = vim.fs.dirname(shortname),
  }
  info.tabline = { info.file, vim.fs.basename(vim.fs.dirname(info.path)) }
  info.statusline = { info.dir .. '/', info.file }
  info.wintitle = { info.relative_path }
  return info
end

BT.terminal = function(bufname, bufnr)
  local dir, pid, cmd = bufname:match('^term://(.*)/(%d+):(.*)$')
  local info = {
    type = 'terminal',
    title = vim.b[bufnr].term_title or '', -- set by terminal
    dir = dir,
    pid = pid,
    cmd = cmd,
  }
  info.tabline = { ('[%s:%s]'):format(info.cmd, info.title:sub(1, 20)) }
  info.statusline = { info.cmd, info.title }
  info.wintitle = { 'cmd: ' .. info.cmd, info.title }
  return info
end

BT.quickfix = function()
  local title = vim.fn.getqflist({ title = true }).title or ''
  return {
    type = 'quickfix',
    title = title,
    tabline = { '[quickfix]' },
    statusline = { '[Quickfix]', title }
  }
end

BT.help = function(bufname)
  local file = vim.fs.basename(bufname)
  return {
    type = 'help',
    file = file,
    statusline = { '[Help]', file },
    tabline = { ('[help:%s]'):format(file) },
    wintitle = { file },
  }
end

BT.nofile = function(_, bufnr, gitroot)
  if _G.Snacks then ---@diagnostic disable-line: unnecessary-if
    for _, explorer in ipairs(Snacks.picker.get({ source = 'explorer' })) do
      for _, w in ipairs(explorer.layout:get_wins()) do
        if w.buf == bufnr then
          local cwd = explorer:cwd()
          return {
            type = 'directory',
            cwd = cwd,
            tabline = { ('[dir:%s]'):format(vim.fs.basename(cwd)) },
            statusline = { cwd .. '/', '[Explorer]' },
          }
        end
      end
    end
  end

  local info = { type = 'scratch' }
  if gitroot then
    info.cwd = git_info(gitroot).short
  else
    info.cwd = shorten_home(vim.fn.getcwd())
  end
  info.statusline = { info.cwd .. '/', '[Scratch]' }
  info.tabline = { '[Scratch]' }
  return info
end

M.get = function(bufnr)
  bufnr = tonumber(bufnr or 0) --[[@as integer]]
  local buftype = vim.bo[bufnr].buftype
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local gitroot = vim.fs.root(bufname, '.git')

  local bufinfo = {}
  if bufname == '' then
    bufinfo = BT.nofile(bufname, bufnr, gitroot)
  elseif buftype == '' and gitroot then
    vim.b[bufnr].workspace_folder = gitroot -- for copilot
    bufinfo = BT.file_with_git(bufname, bufnr, gitroot)
  elseif buftype == '' then
    bufinfo = BT.file_nogit(bufname, bufnr)
  else
    bufinfo = BT[buftype](bufname, bufnr)
  end

  bufinfo.bufname = bufname
  bufinfo.bufnr = bufnr
  bufinfo.listed = vim.bo[bufnr].buflisted

  if vim.b[bufnr].statusline then
    bufinfo.statusline = vim.b[bufnr].statusline
  elseif vim.b[bufnr].tabline then
    bufinfo.tabline = vim.b[bufnr].tabline
  elseif vim.b[bufnr].wintitle then
    bufinfo.wintitle = vim.b[bufnr].wintitle
  end

  return bufinfo
end

return setmetatable(M, {
  __call = function(_, bufnr)
    return vim.b[bufnr].bufinfo or M.get(bufnr)
  end,
})
