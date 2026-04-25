local M = {
  dir = vim.fn.stdpath('state') .. '/mia/session',
  debounce = 5000,
  stale_age = 15 * 24 * 60 * 60 * 1000, -- 15 days

  _enabled = false --[[@as boolean]],
  _timer = nil --[[@as uv.uv_timer_t?]],
}

---@class mia.session
---@field name string Display name of the session
---@field file string The original file/buffer path identifying the session context
---@field path string The filesystem path to the .vim session file
---@field root? string Git root
---@field auto? boolean Whether the session was auto-started on VimEnter
---@field mtime? integer Modification time

local function expand(file) return vim.fs.joinpath(M.dir, file) end

---@param buf integer | string
---@param name? string
---@return mia.session
local function new_session_context(buf, name)
  local bufname --[[@as string]]
  if type(buf) == 'number' then
    bufname = vim.api.nvim_buf_get_name(buf)
  else
    bufname = vim.fn.fnamemodify(buf --[[@as string]], ':p')
    buf = vim.fn.bufnr(bufname)
  end

  local root = mia.bufinfo.get(buf).root
  if not name and root then
    name = vim.fs.relpath(vim.fs.dirname(root), bufname) --[[@as string]]
    name = name:gsub('/', '➔', 1)
  elseif not name then
    name = vim.fs.relpath('~', bufname)
    name = name and '~/' .. name
  end
  name = name or bufname
  local sess_filename = name:gsub('%%', '%%%%'):gsub('/', '%%') .. '.vim'

  return {
    file = bufname,
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
  table.insert(lines, 2, '" mia.session=' .. vim.json.encode(sess))
  vim.fn.writefile(lines, sess.path)
  sess.mtime = mtime(sess.path)

  vim.g.session = sess
  vim.v.this_session = sess.path
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

      local json = line and line:match('^" mia%.session=(.*)$')
      local sess
      if json then
        local ok, decoded = pcall(vim.json.decode, json)
        if ok then
          sess = decoded
        end
      end
      if sess then
        sess.path = path -- ensure path matches actual file on disk
        sess.mtime = mtime(path)
        table.insert(sessions, sess)
      end
    end
  end

  if sort then
    table.sort(sessions, function(a, b) return (b.mtime or -1) < (a.mtime or -1) end)
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
    return vim.iter(sessions):find(function(s) return s.file == file_path end)
  elseif sess == 'last' then
    return M.get_sessinfo(true)[1]
  elseif type(sess) == 'table' then
    return vim.iter(sessions):find(function(s) return s.file == sess.file and s.root == sess.root end)
  elseif type(sess) == 'string' then
    local path_from_str = vim.fn.fnamemodify(sess, ':p')
    return vim
      .iter(sessions)
      :find(function(s) return s.name == sess or s.file == path_from_str or s.path == path_from_str end)
  end
end

---@param sess? string|mia.session
function M.load(sess)
  sess = M.resolve(sess)
  if sess then
    M.disable()
    local ok, err = pcall(vim.cmd.source, vim.fn.fnameescape(sess.path))
    if ok then
      vim.g.session = vim.g.session or sess
      vim.v.this_session = sess.path
      mia.info('Session loaded: ' .. sess.name)
      M.enable()
    else
      mia.err('Session load failed: \n' .. err)
    end
  else
    mia.err('Session not found')
  end
end

---@param name? string
---@param auto? boolean
function M.save(name, auto)
  M.enable()
  local old_sess = vim.g.session

  local buf = old_sess and old_sess.file or vim.api.nvim_get_current_buf()
  local new_sess = new_session_context(buf, name)
  new_sess.auto = auto and true or nil
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

function M.disable() M._enabled = false end
function M.enable() M._enabled = true end
function M.is_enabled() return M._enabled end

function M.enter(buf)
  local sess = M.resolve(buf or vim.api.nvim_get_current_buf())
  if sess then
    M.load(sess)
  else
    M.close()
    M.start(nil, true)
  end
end

function M.renew()
  if not vim.g.session then
    return
  end
  vim.cmd.tabonly({ mods = { emsg_silent = true } })
  vim.cmd.wincmd({ 'o', mods = { emsg_silent = true } })
  vim.cmd.buffer(vim.g.session.file)
  vim.cmd.CloseHiddenBuffers()
end

function M.start(name, auto)
  if not vim.g.session then
    M.close()
    M.save(name, auto)
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

--- Check if a file is visible in any window across all tabs.
---@param file string
---@return boolean
local function is_file_visible(file)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_name(buf) == file then
        return true
      end
    end
  end
  return false
end

--- Delete sessions older than M.stale_age or whose source file no longer exists.
function M.prune()
  local now = os.time() * 1000
  local pruned = 0
  for _, s in ipairs(M.get_sessinfo()) do
    local age = s.mtime and (now - s.mtime) or math.huge
    local file_gone = not vim.uv.fs_stat(s.file)
    if age > M.stale_age or file_gone then
      vim.fn.delete(s.path)
      pruned = pruned + 1
    end
  end
  if pruned > 0 then
    mia.info('Pruned %d stale session(s)', pruned)
  end
end

--- Handle stale auto-session cleanup on exit.
--- Returns true if the normal save should be skipped.
---@return boolean
function M._check_stale_on_exit()
  local sess = vim.g.session
  if not sess or not sess.auto or not M._enabled then
    return false
  end

  if is_file_visible(sess.file) then
    return false
  end

  local ntabs = #vim.api.nvim_list_tabpages()
  if ntabs == 1 then
    -- single tab, source file not visible: silently delete
    vim.fn.delete(sess.path)
    M.close()
    return true
  end

  -- multiple tabs: prompt
  local choice = vim.fn.confirm(
    ('Session source file not visible: %s'):format(sess.name),
    '&Save and quit\n&Delete session and quit\n&Open source file and quit',
    2
  )
  if choice == 2 then
    vim.fn.delete(sess.path)
    M.close()
    return true
  elseif choice == 3 then
    vim.cmd('0tabnew ' .. vim.fn.fnameescape(sess.file))
    return false -- fall through to normal save
  end
  return false -- choice 1 or ESC: save normally
end

function M.setup()
  local list_complete = mia.command.wrap_complete(
    function() return vim.iter(M.get_sessinfo()):map(mia.tbl.index('name')):totable() end
  )

  local tocmd = function(fn)
    return function(o) return fn(o.args ~= '' and o.args or nil) end
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
      renew = M.renew,
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

  local function cancel_timer()
    if M._timer then
      M._timer:stop()
    end
  end

  --- Save immediately, cancelling any pending debounce timer.
  local function save_now()
    if vim.fn.getcmdwintype() ~= '' then
      -- can't save sessions when cmdwin is open
      M._timer:start(M.debounce, 0, vim.schedule_wrap(save_now))
      return
    end
    cancel_timer()
    local ok, err = pcall(M.mksession)
    if not ok then
      mia.err('Failed to save session:\n' .. err)
    end
  end

  --- Start or restart the debounce timer.
  local function save_debounced()
    if not M._timer then
      M._timer = vim.uv.new_timer()
    end
    M._timer:start(M.debounce, 0, vim.schedule_wrap(save_now))
  end

  mia.augroup('session', {
    -- movement: debounced save
    BufEnter = function(ev)
      if M._enabled and vim.bo[ev.buf].buftype == '' and vim.bo[ev.buf].modifiable then
        save_debounced()
      end
    end,

    -- layout changes: immediate save
    WinNew = save_now,
    WinClosed = save_now,
    TabNew = save_now,
    TabClosed = save_now,

    -- critical: immediate save
    FocusLost = save_now,
    VimSuspend = save_now,
    VimLeavePre = function()
      if not M._check_stale_on_exit() then
        save_now()
      end
    end,

    -- on vimenter, start a session or load one
    VimEnter = function()
      vim.o.swapfile = false
      if vim.g.session or vim.fn.argc() ~= 1 or vim.fn.expand('%:p'):match('^/tmp/') then
        vim.schedule(M.prune)
        return
      end

      -- terms dont load properly unless scheduled. idk why
      vim.schedule(function()
        if not vim.g.session then
          -- FIXME: nvim init.lua, open session|options. save options session. restart.
          -- loads init.lua session after options session, expect options sess
          -- additionally: :Session enter not working as expected.
          M.enter()
        end
        M.prune()
      end)
    end,
  })
  if vim.g.session then
    M.enable()
  end
end
M.setup()

return M
