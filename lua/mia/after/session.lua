local M = {
  dir = vim.fn.stdpath('state') .. '/mia/session',
  _enabled = false --[[@as boolean]],
}

---@class mia.session
---@field name string Display name of the session
---@field file string The original file/buffer path identifying the session context
---@field path string The filesystem path to the .vim session file
---@field root? string Git root
---@field mtime? integer Modification time

local function expand(file)
  return vim.fs.joinpath(M.dir, file)
end

---@param buf integer | string
---@param name? string
---@return mia.session
local function new_session_context(buf, name)
  local file = type(buf) == 'number' and vim.fn.bufname(buf) or buf --[[@as string]]
  file = vim.fn.fnamemodify(file, ':p')
  local root = vim.fs.root(file, '.git')

  if not name and root then
    name = vim.fs.relpath(vim.fs.dirname(root), file) --[[@as string]]
    name = name:gsub('/', '➔', 1)
  elseif not name then
    name = vim.fs.relpath('~', file)
    name = name and '~/' .. name
  end
  name = name or file
  local sess_filename = name:gsub('%%', '%%%%'):gsub('/', '%%') .. '.vim'

  return {
    file = file,
    name = name,
    root = root,
    path = expand(sess_filename),
  }
end

local function mtime(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.mtime.sec * 1000 + math.floor(stat.mtime.nsec / 1e6)
end

---@param sess mia.session?
function M.mksession(sess)
  sess = sess or vim.g.session
  if not sess or not M._enabled then
    return
  end

  local tmp = vim.fn.tempname()
  vim.cmd.mksession({ vim.fn.fnameescape(tmp), bang = true })
  local lines = vim.fn.readfile(tmp)
  vim.fn.delete(tmp)

  sess.mtime = nil
  table.insert(lines, 2, 'let g:session=' .. vim.fn.string(sess))
  vim.fn.writefile(lines, sess.path)
  sess.mtime = mtime(sess.path)

  vim.g.session = sess
  vim.v.this_session = sess.path
end

function M.status()
  if vim.g.session then
    local name = vim.g.session.name
    if #name > (vim.o.columns * 0.2) then
      local root = name:match('^.*➔') or ''
      name = name:sub(#root + 1)
      name = name:gsub('([^/])[^/]*/', '%1/')
      name = root .. name
    end
    return ('[%s: %s]'):format(M._enabled and 'S' or '$', name)
  end
end

function M.get_sessinfo(sort)
  local sessions = {}

  for f, ftype in vim.fs.dir(M.dir) do
    if ftype == 'file' and vim.endswith(f, '.vim') then
      local path = expand(f)
      local fd = assert(io.open(path, 'r'))
      fd:read('*l') ---@diagnostic disable-line: discard-returns
      local line = fd:read('*l')
      fd:close()

      local sess = line and line:match('^let g:session=(.*)$')
      if sess then
        local parsed = vim.api.nvim_parse_expression(sess, '', false)
        if parsed.error or parsed.ast.type ~= 'DictLiteral' then
          vim.fn.delete(path)
        else
          local s = vim.api.nvim_eval(sess)
          s.mtime = mtime(s.path)
          table.insert(sessions, s)
        end
      end
    end
  end

  if sort then
    table.sort(sessions, function(a, b)
      return (b.mtime or -1) < (a.mtime or -1)
    end)
    return sessions
  end
  return sessions
end

function M.list()
  local sessions = M.get_sessinfo(true)
  local chunks = { { 'Sessions:' } }
  for _, s in ipairs(sessions) do
    table.insert(chunks, { '\n' })
    if s.path == vim.v.this_session then
      table.insert(chunks, { ' > ' .. s.name, 'WarningMsg' })
    else
      table.insert(chunks, { '   ' .. s.name })
    end
  end
  vim.api.nvim_echo(chunks, false, {})
end

---@param sess 'last'|string|integer|mia.session?
function M.resolve(sess)
  local sessions = M.get_sessinfo()
  if not sess and vim.g.session then
    return vim.g.session
  end

  if not sess or type(sess) == 'number' then
    local file_path = vim.fn.bufname(sess or vim.api.nvim_get_current_buf())
    if file_path == '' then
      return nil
    end
    file_path = vim.fn.fnamemodify(file_path, ':p')
    return vim.iter(sessions):find(function(s)
      return s.file == file_path
    end)
  elseif sess == 'last' then
    return M.get_sessinfo(true)[1]
  elseif type(sess) == 'table' then
    return vim.iter(sessions):find(function(s)
      return s.file == sess.file and s.root == sess.root
    end)
  elseif type(sess) == 'string' then
    local path_from_str = vim.fn.fnamemodify(sess, ':p')
    return vim.iter(sessions):find(function(s)
      return s.name == sess or s.file == path_from_str or s.path == path_from_str
    end)
  end
end

---@param sess? string|mia.session
function M.load(sess)
  sess = M.resolve(sess)
  if sess then
    M.disable()
    mia.source.disable()
    local ok, err = pcall(vim.cmd.source, vim.fn.fnameescape(sess.path))
    mia.source.enable()
    M.enable()
    if ok then
      mia.info('Session loaded: ' .. sess.name)
    else
      mia.err('Session load failed: \n' .. err)
    end
  else
    mia.err('Session not found')
  end
end

---@param name string
function M.save(name)
  M.enable()
  local old_sess = vim.g.session

  local buf = old_sess and old_sess.file or vim.api.nvim_get_current_buf()
  local new_sess = new_session_context(buf, name)
  M.mksession(new_sess)

  if old_sess and old_sess.path ~= new_sess.path then
    vim.fn.delete(old_sess.path)
    mia.info('Session renamed to: ' .. new_sess.name)
  elseif old_sess then
    mia.info('Session saved: ' .. new_sess.name)
  else
    mia.info('New session started: ' .. new_sess.name)
  end
end

---@param sess string|mia.session?
function M.delete(sess)
  sess = M.resolve(sess)
  if not sess then
    return mia.err('Session not found')
  end
  if sess.path == vim.v.this_session then
    M.close()
  end
  vim.fn.delete(sess.path)
end

function M.close()
  M.disable()
  vim.g.session = nil
end

function M.disable()
  M._enabled = false
end

function M.enable()
  M._enabled = true
end

function M.enter(buf)
  local sess = M.resolve(buf)
  if sess then
    M.load(sess)
  else
    M.start()
  end
end

function M.start(name)
  if not vim.g.session then
    M.close()
    M.save(name)
  else
    mia.warn('Session already active: ' .. vim.g.session.name)
  end
end

local function _clean()
  M.close()
  for name in vim.fs.dir(M.dir, { follow = false }) do
    if vim.endswith(name, '.vim') then
      vim.fn.delete(expand(name))
    end
  end
end

function M.clean(force)
  if force then
    _clean()
    return
  end
  vim.ui.input({ prompt = 'Delete all sessions? [y/N] ' }, function(input)
    if input and input:lower():find('^%s*y') then
      _clean()
    end
  end)
end

function M.setup()
  local list_complete = mia.command.wrap_complete(function()
    return vim.iter(M.get_sessinfo()):map(mia.tbl.index('name')):totable()
  end)

  local tocmd = function(fn)
    return function(o)
      return fn(o.args ~= '' and o.args or nil)
    end
  end

  vim.fn.mkdir(M.dir, 'p')

  mia.command('Session', {
    subcommands = {
      list = tocmd(M.list),
      clean = tocmd(M.clean),
      close = tocmd(M.close),
      enter = { tocmd(M.enter), complete = 'buffer' },
      save = { tocmd(M.save), complete = list_complete },
      load = { tocmd(M.load), complete = list_complete },
      delete = { tocmd(M.delete), complete = list_complete },
      stop = tocmd(M.disable),
      start = tocmd(M.start),
      quit = function()
        M.delete()
        vim.cmd('qall!')
      end,
    },
    desc = 'Session management',
    nargs = '*',
  })

  local save_session = mia.F.eat(M.mksession)

  mia.augroup('mia-session', {

    -- saving
    FocusLost = save_session,
    VimLeavePre = save_session,
    VimSuspend = save_session,

    ---@param ev aucmd.callback.arg
    BufEnter = function(ev)
      if vim.bo[ev.buf].buftype == '' and vim.bo[ev.buf].modifiable then
        M.mksession()
      end
    end,

    -- on vimenter, start a session or load one. Ensure the primary buffer is focused
    VimEnter = function()
      vim.o.swapfile = false
      if vim.g.session or vim.fn.argc() ~= 1 then
        return
      end

      -- terms dont load properly unless scheduled. idk why
      vim.schedule(M.enter)
    end,
  })
  if vim.g.session then
    M.enable()
  end
end

return M
