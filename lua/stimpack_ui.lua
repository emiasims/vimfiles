local api = vim.api
local async = require('async')
local pipe = require('pipe')

local M = {}

local ns = api.nvim_create_namespace('pack_float_ui')
local max_commits = 12
local fetch_parallelism = 8
local log_parallelism = 4

local state = {
  bufnr = nil,
  winid = nil,
  autocmd = nil,
  task = nil,
  check_dot_count = 0,
  checking = false,
  status = '',
  manifest = nil, -- nil = stimpack absent
  plugins = {},
  pending = {},
  clean = {},
  not_loaded = {},
  orphans = {},
  commits = {},
  expanded = {},
  line_to_name = {},
  name_to_line = {},
}

local function setup_highlights()
  local links = {
    PackFloatTitle = 'Title',
    PackFloatBorder = 'FloatBorder',
    PackFloatSection = 'Label',
    PackFloatPending = 'DiagnosticWarn',
    PackFloatClean = 'NormalFloat',
    PackFloatMuted = 'Comment',
    PackFloatHash = 'Number',
    PackFloatKey = 'Function',
    PackFloatError = 'DiagnosticError',
  }
  for group, link in pairs(links) do
    api.nvim_set_hl(0, group, { link = link, default = true })
  end
end

local function valid_window() return state.winid and api.nvim_win_is_valid(state.winid) end

local function valid_buffer() return state.bufnr and api.nvim_buf_is_valid(state.bufnr) end

local function plugin_at_cursor()
  if not valid_window() then
    return nil
  end
  local row = api.nvim_win_get_cursor(state.winid)[1]
  return state.line_to_name[row]
end

local function split_lines(text)
  local lines = {}
  for line in (text or ''):gmatch('[^\n]+') do
    lines[#lines + 1] = line
  end
  return lines
end

local function short_rev(rev) return rev and rev:sub(1, 8) or 'unknown' end

local function is_pending(plugin) return plugin.rev and plugin.rev_to and plugin.rev ~= plugin.rev_to end

local function sort_by_name(items)
  table.sort(items, function(a, b) return a.spec.name < b.spec.name end)
end

local function load_manifest()
  local stim = _G.stimpack
  if stim and type(stim.manifest) == 'function' then
    local ok, m = pcall(stim.manifest)
    if ok and type(m) == 'table' then
      state.manifest = m
      return
    end
  end
  state.manifest = nil
end

local function is_orphan(plugin) return state.manifest ~= nil and state.manifest[plugin.spec.name] == nil end

local function set_plugins(plugins)
  state.plugins = plugins
  state.pending = {}
  state.clean = {}
  state.not_loaded = {}
  state.orphans = {}

  for _, plugin in ipairs(state.plugins) do
    if is_orphan(plugin) then
      state.orphans[#state.orphans + 1] = plugin
    elseif is_pending(plugin) then
      state.pending[#state.pending + 1] = plugin
    elseif plugin.active then
      state.clean[#state.clean + 1] = plugin
    else
      state.not_loaded[#state.not_loaded + 1] = plugin
    end
  end

  sort_by_name(state.plugins)
  sort_by_name(state.pending)
  sort_by_name(state.clean)
  sort_by_name(state.not_loaded)
  sort_by_name(state.orphans)
end

local function replace_plugin(plugin)
  local name = plugin.spec.name
  for i, existing in ipairs(state.plugins) do
    if existing.spec.name == name then
      state.plugins[i] = plugin
      set_plugins(state.plugins)
      return
    end
  end

  state.plugins[#state.plugins + 1] = plugin
  set_plugins(state.plugins)
end

local function reset_data()
  state.manifest = nil
  state.plugins = {}
  state.pending = {}
  state.clean = {}
  state.not_loaded = {}
  state.orphans = {}
  state.commits = {}
  state.expanded = {}
  state.line_to_name = {}
  state.name_to_line = {}
end

local function load_fast_plugin_list()
  load_manifest()
  local ok, plugins_or_err = pcall(vim.pack.get, nil, { info = false })
  if ok then
    set_plugins(plugins_or_err)
    return
  end
  state.status = tostring(plugins_or_err)
end

local render

-- uv timer resumptions arrive in fast-event context where most nvim API is
-- off limits; awaiting vim.schedule hops back to the main loop
local schedule = async.wrap(1, vim.schedule)

-- trampolining the callback through vim.schedule means awaiting tasks
-- always resume on the main loop; the closable kills the process when the
-- awaiting task is cancelled, so closing an operation reaps its children
--- @async
local function system(cmd)
  return async.await(function(callback)
    local obj = vim.system(cmd, { text = true }, function(result)
      vim.schedule(function() callback(result) end)
    end)
    return {
      close = function(_, cb)
        pcall(obj.kill, obj, 'sigterm')
        if cb then
          cb()
        end
      end,
    }
  end)
end

--- @async
local function git_commits(plugin)
  local result = system({
    'git',
    '-C',
    plugin.path,
    'log',
    '--oneline',
    '--decorate=short',
    plugin.rev .. '..' .. plugin.rev_to,
  })
  return result.code == 0 and split_lines(result.stdout) or {}
end

--- @async
local function fetch_one(plugin)
  local fetch = system({
    'git',
    '-C',
    plugin.path,
    'fetch',
    '--quiet',
    '--tags',
    '--force',
    '--recurse-submodules=yes',
    'origin',
  })
  if fetch.code ~= 0 then
    return { failed = true }
  end

  local ok, data = pcall(vim.pack.get, { plugin.spec.name }, { offline = true })
  if not ok or not data[1] then
    return { failed = true }
  end

  local updated = data[1]
  local out = { plugin = updated }
  if is_pending(updated) then
    out.commits = git_commits(updated)
  end
  return out
end

--- @async
local function spin()
  while true do
    async.sleep(350)
    schedule()
    if valid_buffer() then
      state.check_dot_count = state.check_dot_count % 3 + 1
      render()
    end
  end
end

local function checking_label()
  local dots = string.rep('.', math.max(1, state.check_dot_count))
  return '  checking' .. dots
end

local function set_lines(lines, hls)
  if not valid_buffer() then
    return
  end

  vim.bo[state.bufnr].modifiable = true
  api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
  vim.bo[state.bufnr].modifiable = false
  vim.bo[state.bufnr].modified = false

  api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
  for _, hl in ipairs(hls) do
    api.nvim_buf_set_extmark(state.bufnr, ns, hl[1], hl[2], {
      end_col = hl[3],
      hl_group = hl[4],
    })
  end
end

local function build_content()
  local lines = {}
  local hls = {}
  local line_to_name = {}
  local name_to_line = {}

  local function add(text, hl)
    local row = #lines
    lines[#lines + 1] = text
    if hl then
      hls[#hls + 1] = { row, 0, #text, hl }
    end
    return row
  end

  local function add_hl(row, start_col, end_col, hl) hls[#hls + 1] = { row, start_col, end_col, hl } end

  local function mark_plugin(row, name)
    line_to_name[row + 1] = name
    name_to_line[name] = name_to_line[name] or row + 1
  end

  local header = (' vim.pack  %d plugins  %d updates'):format(#state.plugins, #state.pending)
  if state.manifest and #state.orphans > 0 then
    header = header .. ('  %d orphaned'):format(#state.orphans)
  end
  if state.checking then
    header = header .. '  checking...'
  elseif state.status ~= '' then
    header = header .. '  ' .. state.status
  end
  add(header, 'PackFloatTitle')

  local help = ' [r] refresh  [u] update  [U] update all  [gf] config  [x] remove  [Enter] details  [q] close'
  local help_row = add(help)
  for start_pos, end_pos in help:gmatch('()%b[]()') do
    add_hl(help_row, start_pos - 1, end_pos - 1, 'PackFloatKey')
  end

  add('')

  local max_name = 0
  for _, plugin in ipairs(state.plugins) do
    max_name = math.max(max_name, #plugin.spec.name)
  end

  local function add_plugin(plugin, pending, name_hl)
    local name = plugin.spec.name
    local commits = state.commits[name]
    local commit_count = commits and #commits or 0
    local status = pending and (' +' .. commit_count) or ''
    local revs = pending and (' ' .. short_rev(plugin.rev) .. ' -> ' .. short_rev(plugin.rev_to))
      or (' ' .. short_rev(plugin.rev))
    local pad = string.rep(' ', math.max(0, max_name - #name))
    local line = ('  %s%s  %-4s %s'):format(name, pad, status, revs)

    local row = add(line)
    mark_plugin(row, name)

    local name_start = 2
    add_hl(row, name_start, name_start + #name, name_hl or (pending and 'PackFloatPending' or 'PackFloatClean'))
    local hash_start = line:find(short_rev(plugin.rev), 1, true)
    if hash_start then
      add_hl(row, hash_start - 1, #line, 'PackFloatHash')
    end

    if state.expanded[name] then
      add(('    path: %s'):format(plugin.path), 'PackFloatMuted')
      mark_plugin(#lines - 1, name)
      add(('    src:  %s'):format(plugin.spec.src), 'PackFloatMuted')
      mark_plugin(#lines - 1, name)

      if state.manifest then
        local entry = state.manifest[name]
        local origin
        if entry and entry.path then
          origin = vim.fn.fnamemodify(entry.path, ':t') .. (entry.start and ' (start)' or '')
        else
          origin = 'not declared in any pack file'
        end
        add(('    pack: %s'):format(origin), 'PackFloatMuted')
        mark_plugin(#lines - 1, name)
      end

      if pending then
        if commits == nil then
          add('    commits: loading...', 'PackFloatMuted')
          mark_plugin(#lines - 1, name)
        elseif #commits == 0 then
          add('    commits: no new commits found', 'PackFloatMuted')
          mark_plugin(#lines - 1, name)
        else
          local limit = math.min(#commits, max_commits)
          for i = 1, limit do
            local commit = commits[i]
            local commit_row = add('    ' .. commit)
            mark_plugin(commit_row, name)
            local hash = commit:match('^(%x+)')
            if hash then
              add_hl(commit_row, 4, 4 + #hash, 'PackFloatHash')
            end
          end
          if #commits > limit then
            add(('    ... %d more'):format(#commits - limit), 'PackFloatMuted')
            mark_plugin(#lines - 1, name)
          end
        end
      end
    end
  end

  add((' Updates (%d)'):format(#state.pending), 'PackFloatSection')
  if #state.pending == 0 then
    add(state.checking and checking_label() or '  no pending updates', 'PackFloatMuted')
  else
    for _, plugin in ipairs(state.pending) do
      add_plugin(plugin, true)
    end
  end

  add('')
  add((' Loaded (%d)'):format(#state.clean), 'PackFloatSection')
  for _, plugin in ipairs(state.clean) do
    add_plugin(plugin, false)
  end

  add('')
  add((' Inactive (%d)'):format(#state.not_loaded), 'PackFloatSection')
  if #state.not_loaded == 0 then
    add('  no inactive plugins', 'PackFloatMuted')
  else
    for _, plugin in ipairs(state.not_loaded) do
      add_plugin(plugin, false)
    end
  end

  if state.manifest then
    add('')
    add((' Orphans (%d)'):format(#state.orphans), 'PackFloatSection')
    if #state.orphans == 0 then
      add('  no orphaned plugins', 'PackFloatMuted')
    else
      for _, plugin in ipairs(state.orphans) do
        add_plugin(plugin, false, 'PackFloatError')
      end
    end
  end

  state.line_to_name = line_to_name
  state.name_to_line = name_to_line

  return lines, hls
end

render = function()
  if not valid_buffer() then
    return
  end
  local lines, hls = build_content()
  set_lines(lines, hls)
end

--- @async
local function refresh_local()
  load_manifest()
  local ok, plugins_or_err = pcall(vim.pack.get, nil, { offline = true })
  if not ok then
    state.status = tostring(plugins_or_err)
    render()
    return
  end

  state.commits = {}
  set_plugins(plugins_or_err)
  state.status = 'ready'
  render()

  async.await(
    pipe
      .new(state.pending)
      :parallel(log_parallelism)
      :map(function(plugin) return { name = plugin.spec.name, commits = git_commits(plugin) } end)
      :catch(function(_, plugin) return { name = plugin.spec.name, commits = {} } end)
      :each(function(r)
        state.commits[r.name] = r.commits
        render()
      end)
  )
end

--- @async
local function refresh_fetch()
  load_manifest()
  state.checking = true
  state.status = 'fetching remotes'
  state.check_dot_count = 1
  state.commits = {}
  render()

  local spinner = async.run('pack:spinner', spin)

  local total = #state.plugins
  local done = 0
  local failures = 0

  -- parallel workers do pure I/O; :each is the single serial mutation
  -- point, so results can't interleave state writes
  local ok, err = async.pawait(
    pipe
      .new(state.plugins)
      :parallel(fetch_parallelism)
      :map(fetch_one)
      :catch(function() return { failed = true } end)
      :each(function(r)
        done = done + 1
        if r.failed then
          failures = failures + 1
        else
          replace_plugin(r.plugin)
          if r.commits then
            state.commits[r.plugin.spec.name] = r.commits
          end
        end
        state.status = ('fetching remotes %d/%d'):format(done, total)
        render()
      end)
  )

  spinner:close()
  async.pawait(spinner)

  state.checking = false
  if not ok then
    state.status = 'refresh failed: ' .. tostring(err)
  else
    state.status = failures > 0 and ('ready, %d fetch failed'):format(failures) or 'ready'
  end
  render()
end

local function cancel_task()
  if state.task then
    state.task:close()
    state.task = nil
  end
  state.checking = false
  state.check_dot_count = 0
end

-- one owning task per operation: a closed task never resumes past its next
-- checkpoint, so cancellation replaces a check_id generation counter
local function start_task(name, fn)
  cancel_task()
  state.task = async.run(name, function()
    schedule()
    if not valid_buffer() then
      return
    end
    fn()
  end)
end

local function refresh(fetch) start_task('pack:refresh', fetch and refresh_fetch or refresh_local) end

local function close()
  if state.autocmd then
    pcall(api.nvim_del_autocmd, state.autocmd)
    state.autocmd = nil
  end
  if valid_window() then
    api.nvim_win_close(state.winid, true)
  end
  state.winid = nil
  state.bufnr = nil
  cancel_task()
end

-- vim.pack.update is synchronous, so it runs in a headless child nvim that
-- sources the same config. flush first: stimpack defers non-start packs to
-- UIEnter, which never fires headless. The chunk is one line because ex
-- commands split on newlines, and it os.exit()s explicitly because an
-- error in a -c command doesn't fail nvim's exit code on its own.
--- @async
local function run_update(names)
  local spec = vim.inspect(names, { newline = ' ', indent = '' })
  local chunk = table.concat({
    'if _G.stimpack and stimpack.flush then pcall(stimpack.flush) end',
    ('local ok, err = pcall(vim.pack.update, %s, { force = true, offline = true })'):format(spec),
    'if not ok then io.stderr:write(tostring(err)) os.exit(1) end',
    'os.exit(0)',
  }, ' ')

  local result = system({
    vim.v.progpath,
    '--headless',
    '-n', -- the parent owns swap and shada
    '-i',
    'NONE',
    '-c',
    'lua ' .. chunk,
  })

  if result.code ~= 0 then
    local detail = vim.trim(result.stderr or '')
    error(detail ~= '' and detail or ('update exited with code %d'):format(result.code), 0)
  end
end

local function update_plugins(names)
  if #names == 0 then
    vim.notify('vim.pack: no pending updates', vim.log.levels.INFO)
    return
  end

  state.status = 'updating ' .. table.concat(names, ', ')
  render()

  start_task('pack:update', function()
    local ok, err = async.pawait(async.run('pack:update:child', run_update, names))
    if not ok then
      vim.notify('vim.pack: ' .. tostring(err), vim.log.levels.ERROR)
      state.status = 'update failed'
      render()
      return
    end
    refresh_local()
  end)
end

local function update_current()
  local name = plugin_at_cursor()
  if not name then
    return
  end
  for _, plugin in ipairs(state.pending) do
    if plugin.spec.name == name then
      update_plugins({ name })
      return
    end
  end
  vim.notify(('vim.pack: %s has no pending update'):format(name), vim.log.levels.INFO)
end

local function update_all()
  local names = vim.iter(state.pending):map(function(plugin) return plugin.spec.name end):totable()
  update_plugins(names)
end

local function open_config()
  local name = plugin_at_cursor()
  if not name then
    return
  end
  local entry = state.manifest and state.manifest[name]
  if not entry or not entry.path then
    vim.notify(('vim.pack: no pack file declares %s'):format(name), vim.log.levels.INFO)
    return
  end
  local path = entry.path
  close()
  vim.cmd.edit(vim.fn.fnameescape(path))
end

local function remove_current()
  local name = plugin_at_cursor()
  if not name then
    return
  end
  -- declared plugins are refused so the pack files stay the source of
  -- truth: delete the stimpack.add line, refresh, then remove the orphan
  local orphan = vim.iter(state.orphans):any(function(p) return p.spec.name == name end)
  if not orphan then
    vim.notify(('vim.pack: %s is not an orphan'):format(name), vim.log.levels.INFO)
    return
  end
  if vim.fn.confirm(('Remove %s from disk?'):format(name), '&Yes\n&No', 2) ~= 1 then
    return
  end

  state.status = 'removing ' .. name
  render()

  start_task('pack:del', function()
    local ok, err = pcall(vim.pack.del, { name })
    if not ok then
      vim.notify('vim.pack: ' .. tostring(err), vim.log.levels.ERROR)
      state.status = 'remove failed'
      render()
      return
    end
    refresh_local()
  end)
end

local function jump(direction)
  if not valid_window() then
    return
  end
  local row = api.nvim_win_get_cursor(state.winid)[1]
  local rows = vim.tbl_keys(state.line_to_name)
  table.sort(rows)
  if direction > 0 then
    for _, next_row in ipairs(rows) do
      if next_row > row then
        api.nvim_win_set_cursor(state.winid, { next_row, 0 })
        return
      end
    end
    if rows[1] then
      api.nvim_win_set_cursor(state.winid, { rows[1], 0 })
    end
  else
    for i = #rows, 1, -1 do
      if rows[i] < row then
        api.nvim_win_set_cursor(state.winid, { rows[i], 0 })
        return
      end
    end
    if rows[#rows] then
      api.nvim_win_set_cursor(state.winid, { rows[#rows], 0 })
    end
  end
end

local function toggle_details()
  local name = plugin_at_cursor()
  if not name then
    return
  end
  state.expanded[name] = not state.expanded[name]
  render()
  if valid_window() and state.name_to_line[name] then
    api.nvim_win_set_cursor(state.winid, { state.name_to_line[name], 0 })
  end
end

local function map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = state.bufnr, silent = true, nowait = true, desc = desc })
end

local function setup_keymaps()
  map('q', close, 'Close')
  map('<Esc>', close, 'Close')
  map('r', function() refresh(true) end, 'Refresh updates')
  map('u', update_current, 'Update plugin')
  map('U', update_all, 'Update all pending')
  map('gf', open_config, 'Edit declaring pack file')
  map('x', remove_current, 'Remove orphaned plugin')
  map('<CR>', toggle_details, 'Toggle details')
  map(']]', function() jump(1) end, 'Next plugin')
  map('[[', function() jump(-1) end, 'Previous plugin')
end

function M.open(opts)
  opts = opts or {}

  if valid_window() then
    api.nvim_set_current_win(state.winid)
    return
  end

  setup_highlights()

  state.bufnr = api.nvim_create_buf(false, true)
  vim.bo[state.bufnr].buftype = 'nofile'
  vim.bo[state.bufnr].bufhidden = 'wipe'
  vim.bo[state.bufnr].swapfile = false
  vim.bo[state.bufnr].filetype = 'pack-float'

  local columns = vim.o.columns
  local screen_lines = vim.o.lines
  local width = math.min(100, math.max(64, math.floor(columns * 0.82)))
  local height = math.min(32, math.max(18, math.floor(screen_lines * 0.72)))

  state.winid = api.nvim_open_win(state.bufnr, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((screen_lines - height) / 2),
    col = math.floor((columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' vim.pack ',
    title_pos = 'center',
  })

  vim.wo[state.winid].cursorline = true
  vim.wo[state.winid].wrap = false

  reset_data()
  load_fast_plugin_list()
  setup_keymaps()
  render()

  local captured_win = state.winid
  state.autocmd = api.nvim_create_autocmd('WinClosed', {
    once = true,
    callback = function(ev)
      if vim._tointeger(ev.match) == captured_win then
        state.autocmd = nil
        state.winid = nil
        state.bufnr = nil
        cancel_task()
      end
    end,
  })

  refresh(opts.fetch ~= false)
end

api.nvim_create_user_command('Pack', function(command) M.open({ fetch = not command.bang }) end, {
  bang = true,
  desc = 'Open lazy-style vim.pack UI',
})

return M
