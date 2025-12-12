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

--- @class mia.bufinfo
--- @field type 'file'|'terminal'|'quickfix'|'help'|'nowrite'|'directory'|'scratch'|string
--- @field desc string Display description
--- @field name string Display name
--- @field cwd? string Current working directory if applicable
--- @field tab_name? string Tabline name if different
--- @field tab_hint? string Tabline hint for disambiguation
--- @field wintitle? table<number, string> Wintitle lines
--- @field hl? string Highlight group for name in statusline
--- @field root? { path: string, short: string } Git root info if applicable

---@type table<string, fun(bufname:string, bufnr:integer, gitroot?:string):mia.bufinfo>
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
    cwd = dir,
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
    cwd = dir,
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

BT.acwrite = function(bufname, _)
  local file = vim.fs.basename(bufname)
  return {
    type = 'acwrite',
    desc = '[AcWrite]',
    name = bufname,
    tab_name = ('[acwrite:%s]'):format(file),
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

--- @return mia.bufinfo
local function _get(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
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

  local update = vim.b[bufnr].update_bufinfo
  if update then
    if type(update) == 'function' then
      update = update(vim.deepcopy(bufinfo))
    end
    bufinfo = vim.tbl_extend('force', bufinfo, update or {}) --[[@as mia.bufinfo]]
  end

  return bufinfo
end

--- @return mia.bufinfo
function M.get(bufnr)
  local ok, info = pcall(_get, tonumber(bufnr or 0))
  if not ok then
    return {
      type = 'error',
      desc = '[Error]',
      name = 'bufinfo error',
      hl = 'Error',
      tab_name = '[%bufinfo error%]',
      error = info
    }
  end
  return info --[[@as mia.bufinfo]]
end

do -- set up autocmds
  local function update_bufinfo(ev)
    vim.b[ev.buf].bufinfo = M.get(ev.buf)
  end

  mia.augroup('mia.bufinfo', {
    BufEnter = update_bufinfo,
    BufFilePost = update_bufinfo,
    TermEnter = update_bufinfo,
    TermRequest = update_bufinfo,
    OptionSet = { pattern = 'buftype', callback = update_bufinfo }
  })

end

return setmetatable(M, {
  --- @return mia.bufinfo
  __call = function(_, bufnr)
    bufnr = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
    return vim.b[bufnr].bufinfo or M.get(bufnr) --[[@as mia.bufinfo]]
  end,
})
