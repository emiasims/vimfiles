local Config = { dir = vim.fn.stdpath('state') .. '/mia.session' }

local function expand(file)
  return vim.fs.joinpath(Config.dir, file)
end

local M = {}

local function build_sessinfo(buf)
  local file = type(buf) == 'number' and vim.fn.bufname(buf) or buf --[[@as string]]
  file = vim.fn.fnamemodify(file, ':p')
  local root = vim.fs.root(file, '.git')

  local name
  if root then
    name = vim.fs.relpath(vim.fs.dirname(root), file)
  else
    name = vim.fs.relpath('~', file)
    name = name and '~/' .. name
  end

  ---@class mia.session
  local sess = {
    file = file,
    name = name or file,
    root = root,
    path = expand(file:gsub('%%', '%%%%'):gsub('/', '%%') .. '.vim'),
  }
  return sess
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

  table.insert(lines, 2, ('lua vim.g.session=vim.json.decode([[%s]])'):format(vim.fn.json_encode(sess)))
  vim.fn.writefile(lines, sess.path)
  vim.system({ 'ln', '-sf', sess.path, expand('last-session.vim') })
  vim.g.session = sess
  vim.v.this_session = sess.path
end

function M.status()
  if vim.g.session then
    local name = vim.g.session.name
    if #name > (vim.o.columns * 0.2) then
      name = name:gsub('([^/])[^/]*/', '%1/')
    end
    return ('[%s: %s]'):format(M._enabled and 'S' or '$', name)
  end
end

function M.get()
  local sessions = {}

  for f, ftype in vim.fs.dir(Config.dir) do
    if ftype == 'file' and vim.endswith(f, '.vim') then
      local fd = assert(io.open(expand(f), 'r'))
      fd:read('*l') ---@diagnostic disable-line: discard-returns
      local info = fd:read('*l'):match('^lua vim.g.session=vim.json.decode%(%[%[(.*)%]%]%)$')
      fd:close()

      info = info and vim.json.decode(info)
      if info and vim.fn.filereadable(info.file) == 1 then
        table.insert(sessions, info)
      else
        vim.fn.delete(f)
      end
    end
  end

  return sessions
end

function M.list()
  local sessions = M.get()
  local chunks = { { 'Sessions:\n' } }
  for _, s in ipairs(sessions) do
    if s.path == vim.v.this_session then
      table.insert(chunks, { ' > ' .. s.name .. '\n', 'WarningMsg' })
    else
      table.insert(chunks, { '   ' .. s.name .. '\n' })
    end
  end
  chunks[#chunks][1] = chunks[#chunks][1]:sub(1, -2)
  vim.api.nvim_echo(chunks, false, {})
  return sessions
end

---@param sess string|mia.session?
function M.lookup(sess)
  if type(sess) == 'table' and sess.path and sess.root and sess.file and sess.name then
    return vim.fn.filereadable(sess.path) == 1 and sess or nil
  end

  local info = M.get()
  if not sess or sess == 'last' then
    local last = vim.uv.fs_readlink(expand('last-session.vim'))
    if last and vim.fn.filereadable(last) == 1 then
      return vim.iter(info):find(function(s)
        return s.path == last
      end)
    end

  -- session object, verify with root and file
  elseif type(sess) == 'table' then
    return vim.iter(info):find(function(s)
      return s.file == sess.file and s.root == sess.root
    end)

  -- name or path
  elseif type(sess) == 'string' then
    return vim.iter(info):find(function(s)
      return s.name == sess or s.file == sess
    end)
  end
end

---@param sess? string|mia.session
function M.load(sess)
  sess = M.lookup(sess)
  if sess then
    M.enable()
    vim.cmd.source(vim.fn.fnameescape(sess.path))
    mia.info('Session loaded: ' .. sess.name)
  else
    mia.err('Session not found')
  end
end

---@param sess string|mia.session?
function M.save(sess)
  M.mksession(build_sessinfo(sess))
end

---@param sess string|mia.session?
function M.delete(sess)
  sess = M.lookup(sess)
  if not sess then
    return mia.err('Session not found')
  end
  if sess.path == vim.v.this_session then
    M.disable()
    vim.g.session = nil
  end
  vim.fn.delete(sess.path)
end

function M.name(name)
  local sess = vim.g.session
  if sess then
    sess.name = name
    M.mksession(sess)
  end
end

function M.disable()
  M._enabled = false
end

function M.enable()
  M._enabled = true
end

function M.enter(buf, ...)
  local sess = build_sessinfo(buf or 0)
  if M.lookup(sess) then
    M.load(sess)
  else
    M.start(sess.file)
  end
end

function M.start(buf, name)
  M.enable()
  if not vim.g.session then
    local file = vim.fn.bufname(buf or vim.api.nvim_get_current_buf())
    vim.g.session = build_sessinfo(file)
    if name then
      vim.g.session.name = name
    end
  end

  M.mksession(vim.g.session)
  mia.info('New session started: ' .. vim.g.session.name)
end

function M.pick()
  return Snacks.picker.pick('Sessions', {
    sort = { fields = { 'time:desc' } },
    matcher = { frecency = true, sort_empty = true, cwd_bonus = false },
    format = 'text',
    items = M.get(),

    transform = function(sess, ctx)
      return {
        time = vim.uv.fs_stat(sess.path).mtime.sec,
        file = sess.path,
        text = sess.name,
        sess = sess,
        name = sess.name,
        -- TODO buffers saved, tabs
      }
    end,
    confirm = function(picker, item, _)
      picker:close()
      if item then
        M.load(item.file)
      end
    end,
  })
end

function M.mini_starter_items(nrecent)
  local last = M.lookup()
  local pick = { action = 'Session pick', name = 'Pick Sessions', section = 'Sessions' }
  if not last then
    return pick
  end
  ---@diagnostic disable-next-line: cast-local-type
  last = ('Last Session (%s)'):format(last.name)
  return { { action = 'Session load', name = last, section = 'Sessions' }, pick }
end

function M.clean()
  mia.err('Delete all sessions?')
  vim.ui.input({ prompt = '[y/N] ' }, function(input)
    if input and input:lower():find('^%s*y') then
      for name in vim.fs.dir(Config.dir, { follow = false }) do
        if vim.endswith(name, '.vim') then
          vim.fn.delete(expand(name))
        end
      end
    end
  end)
end

function M.setup()
  local list_complete = mia.command.wrap_complete(function()
    return vim.iter(M.get()):map(mia.tbl.index('name')):totable()
  end)

  local tocmd = function(fn)
    return function(o)
      return fn(o.args ~= '' and o.args or nil)
    end
  end

  vim.fn.mkdir(Config.dir, 'p')

  mia.command('Session', {
    subcommands = {
      list = tocmd(M.list),
      pick = tocmd(M.pick),
      last = tocmd(M.last),
      clean = tocmd(M.clean),
      enter = { tocmd(M.enter), complete = 'buffer' },
      save = { tocmd(M.save), complete = list_complete },
      load = { tocmd(M.load), complete = list_complete },
      delete = { tocmd(M.delete), complete = list_complete },
      name = { tocmd(M.name), complete = list_complete },
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

    SessionLoadPost = function()
      -- ftdetect the new files.
      local ftdetect = mia.partial(vim.cmd.filetype, 'detect')
      for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if not vim.b[buf.bufnr].did_ftplugin then
          vim.api.nvim_buf_call(buf.bufnr, ftdetect)
        end
      end
    end,

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
      local args = vim.fn.argv()
      vim.o.swapfile = false
      if vim.g.session or vim.fn.argc() == 0 then
        return
      end

      M.enter(vim.fn.fnamemodify(args[1], ':p'))

      if vim.fn.bufnr(args[1]) ~= vim.api.nvim_get_current_buf() then
        -- ensure the primary buffer is focused
        -- check in each tab if the buffer is open, if so, focus it
        -- otherwise, start a new tab with it, keeping the window layout otherwise
        local win = vim.fn.win_findbuf(vim.fn.bufnr(args[1]))
        if #win > 0 then
          vim.api.nvim_set_current_win(win[1])
        else
          vim.cmd.tabnew({ args[1], range = { 0 } })
        end
      end
      vim.cmd.args(args)
    end,
  })
end

return M
