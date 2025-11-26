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

BT.file = function(bufname, bufnr, gitroot)
  local path, root
  if gitroot then
    path = vim.fs.relpath(gitroot, bufname)
    root = git_info(gitroot, bufnr)
  end

  path = path or shorten_home(bufname)
  local dir, file = vim.fs.dirname(path), vim.fs.basename(path)

  return {
    type = 'file',
    desc = root and ('(%s)%s/'):format(root.branch, dir) or (dir .. '/'),
    name = file,
    tab_hint = vim.fs.basename(vim.fs.dirname(bufname)),
    wintitle = { path, root and root.short },
    root = root,
  }
end

BT.terminal = function(bufname, bufnr)
  local dir, pid, cmd = bufname:match('^term://(.*)/(%d+):(.*)$')
  local title = vim.b[bufnr].term_title or ''
  return {
    type = 'terminal',
    desc = cmd,
    name = title,
    tab_name = ('[%s:%s]'):format(cmd, title:sub(1, 20)),
    wintitle = { 'cmd: ' .. cmd, title },
    pid = pid,
    dir = dir,
  }
end

BT.quickfix = function()
  local title = vim.fn.getqflist({ title = true }).title or ''
  return {
    type = 'quickfix',
    desc = '[Quickfix]',
    name = title,
    tab_name = '[quickfix]',
  }
end

BT.help = function(bufname)
  local file = vim.fs.basename(bufname)
  return {
    type = 'help',
    desc = '[Help]',
    name = file,
    tab_name = ('[help:%s]'):format(file),
    wintitle = { file },
  }
end

BT.nowrite = function(bufname, _)
  local file = vim.fs.basename(bufname)
  return {
    type = 'nowrite',
    desc = '[NoWrite]',
    name = bufname,
    tab_name = ('[nowrite:%s]'):format(file),
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
            desc = ('[Explorer]%s/'):format(cwd),
            name = '⤬',
            hl = 'Special',
            tab_name = ('[dir:%s]'):format(vim.fs.basename(cwd)),
            cwd = cwd,
          }
        end
      end
    end
  end

  local cwd = gitroot and git_info(gitroot).short or shorten_home(vim.fn.getcwd())
  return {
    type = 'scratch',
    desc = ('[Scratch]%s/'):format(cwd),
    name = '⤬',
    hl = 'Special',
    tab_name = '[Scratch]',
    cwd = cwd,
  }
end

M.get = function(bufnr)
  bufnr = tonumber(bufnr or 0) --[[@as integer]]
  local buftype = vim.bo[bufnr].buftype
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local gitroot = vim.fs.root(bufname, '.git')

  local bufinfo
  if bufname == '' then
    bufinfo = BT.nofile(bufname, bufnr, gitroot)
  elseif buftype == '' then
    if gitroot then
      vim.b[bufnr].workspace_folder = gitroot
    end
    bufinfo = BT.file(bufname, bufnr, gitroot)
  else
    bufinfo = BT[buftype](bufname, bufnr)
  end

  bufinfo.bufname = bufname
  bufinfo.bufnr = bufnr
  bufinfo.listed = vim.bo[bufnr].buflisted

  if vim.b[bufnr].statusline then
    bufinfo.desc, bufinfo.name, bufinfo.hl = unpack(vim.b[bufnr].statusline)
  elseif vim.b[bufnr].tabline then
    bufinfo.tab_name, bufinfo.tab_hint = unpack(vim.b[bufnr].tabline)
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
