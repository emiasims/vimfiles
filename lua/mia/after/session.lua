local Config = { dir = vim.fn.stdpath('state') .. '/mia.session' }

local function expand(file)
  return vim.fs.joinpath(Config.dir, file)
end

local M = {}

local function build_sessinfo(buf)
  local file = type(buf) == 'number' and vim.fn.bufname(buf) or buf --[[@as string]]
  file = vim.fn.fnamemodify(file, ':p')
  local root = vim.fs.root(file, '.git')

  ---@class mia.session
  local sess = {
    file = file,
    name = root and (file:sub(#vim.fs.dirname(root) + 2)) or file,
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
  vim.g.session = sess
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
    if ftype == 'file' and f:sub(-4) == '.vim' then
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
  mia.info('Sessions:')
  for _, s in ipairs(M.get()) do
    if s.path == vim.v.this_session then
      mia.warn(' > ' .. s.name)
    else
      mia.info('   ' .. s.name)
    end
  end
end

---@param sess string|mia.session?
function M.lookup(sess)
  if type(sess) == 'table' and sess.path and sess.root and sess.file and sess.name then
    return vim.fn.filereadable(sess.path) == 1 and sess or nil
  end

  local info = M.get()
  -- return last used
  if sess == nil then
    local mtime = -2
    local last, mt
    for _, s in ipairs(info) do
      mt = vim.fn.getftime(s.path)
      if mt > mtime then
        mtime, last = mt, s
      end
    end
    return last

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
    mia.warn('Session loaded: ' .. sess.name)
  else
    mia.error('Session not found')
  end
end

---@param sess string|mia.session?
function M.save(sess)
  M.mksession(build_sessinfo(sess))
end

---@param sess string|mia.session?
function M.delete(sess)
  sess = M.lookup(sess)
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
  local file = vim.fn.bufname(buf or 0)
  vim.g.session = build_sessinfo(file)
  if name then
    vim.g.session.name = name
  end
  M.mksession(vim.g.session)
  mia.warn('New session started: ' .. vim.g.session.name)
end

function M.pick(opts)
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local previewers = require('telescope.previewers')

  -- results, entry_maker
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Sessions',
      finder = finders.new_table({
        results = M.get(),
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = vim.fn.getftime(entry.path),
          }
        end,
      }),
      previewer = previewers.new_buffer_previewer({
        ---@param entry { value:mia.session, display:string, ordinal:number }
        define_preview = function(self, entry)
          local lines = vim.fn.readfile(entry.value.path)

          local sess = lines[2]:match('^lua vim.g.session=vim.json.decode%(%[%[(.*)%]%]%)$')
          if not sess then
            return
          end

          ---@type mia.session
          sess = vim.json.decode(sess)

          local bit = vim.iter(lines):map(mia.partial(string.match, nil, '^badd %+%d+ (.*)$'))

          if sess.root then
            bit
              :map(mia.partial(vim.fn.fnamemodify, nil, ':p'))
              :map(mia.partial(string.match, nil, '^' .. vim.pesc(sess.root) .. '/(.*)$'))
          end

          local info = vim.split(vim.inspect(sess), '\n')
          info[1] = 'SessInfo = {'
          table.insert(info, '')
          table.insert(info, '')
          table.insert(info, 'Buffers = [[')
          vim.list_extend(info, bit:totable())
          table.insert(info, ']]')

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, info)
          local parser = assert(vim.treesitter.get_parser(self.state.bufnr, 'lua', { error = false }))
          vim.treesitter.highlighter.new(parser)
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd.source(selection.path)
        end)
        return true
      end,
    })
    :find()
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
      enter = { tocmd(M.enter), complete = 'buffer' },
      save = { tocmd(M.save), complete = list_complete },
      load = { tocmd(M.load), complete = list_complete },
      delete = { tocmd(M.delete), complete = list_complete },
      name = { tocmd(M.name), complete = list_complete },
      stop = tocmd(M.disable),
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
      if vim.g.session then
        return
      end

      if vim.fn.argc() == 0 then
        return M.load()
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
