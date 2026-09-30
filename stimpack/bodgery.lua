stimpack.dev('mia', 'emiasims/nvim-bodgery')

vim.keymap.set({ 'n', 't' }, '<C-.>', function()
  if not pcall(require('bodgery').toggle) then
    vim.cmd.Claude({ mods = { vertical = true } })
  end
end)

-- loading the file before Claude writes it lets 'autoread' record the change
-- as an undo step (see 'undoreload') and attaches LSP so diagnostics after
-- the edit are real
local edit_tools = { Edit = true, Write = true, NotebookEdit = true, Update = true }
mia.augroup('bodgery', {
  User = {
    ClaudeToolUsePre = function(ev)
      local input = ev.data.tool_input or {}
      local file = edit_tools[ev.data.tool_name] and (input.file_path or input.notebook_path)
      local buf = file and vim.fn.bufadd(file)
      if buf and not vim.api.nvim_buf_is_loaded(buf) then
        vim.fn.bufload(buf)
        vim.bo[buf].buflisted = true
        -- bufload skips BufRead autocmds, so no filetype and no LSP
        vim.api.nvim_exec_autocmds('BufReadPost', { buffer = buf })
        mia.info('Claude: loaded %s (%s)', file, vim.api.nvim_buf_get_name(buf))
      end
    end,
  },

  BufWinEnter = {
    pattern = 'term://*//*:*claude*',
    callback = function() vim.wo.list = false end,
  },
})

mia.keymap({
  mode = { 'n', 't' },
  { '<F7>', '<Cmd>Pick claude<Cr>', desc = 'Pick claude session' },
})

---@return string?
local function read(path)
  local f = io.open(path, 'rb')
  if f then
    local text = f:read('*a')
    f:close()
    return text
  end
end

-- archive state of sessions the desktop app doesn't track, and when each session was last
-- (un)archived so auto-archiving skips sessions unarchived in the past week
local archive_state = mia.cache.file('claude_archive')
local archive_after = 7 * 86400

---@return table<string, { path: string, archived: boolean }> desktop app records by session id
local function desktop_records()
  local root = require('bodgery').config.get('claude').ccd_dir
  local out = {}
  for _, path in ipairs(vim.fn.glob(root .. '/*/*/local_*.json', true, true)) do
    local text = read(path) or ''
    local id = text:match('"cliSessionId":"([^"]+)"')
    if id then
      out[id] = { path = path, archived = text:match('"isArchived":(%a+)') == 'true' }
    end
  end
  return out
end

local function set_archived(item, archived)
  if item.desktop then
    local text = assert(read(item.desktop))
    local value = '"isArchived":' .. tostring(archived)
    local new, n = text:gsub('"isArchived":%a+', value, 1)
    if n == 0 then
      new = text:gsub('^{', '{' .. value .. ',', 1)
    end
    -- the desktop app never reads a partial file
    local tmp = item.desktop .. '.nvim'
    local f = assert(io.open(tmp, 'wb'))
    f:write(new)
    f:close()
    vim.uv.fs_rename(tmp, item.desktop)
  end
  item.archived = archived
  archive_state[item.id] = { archived = archived, at = os.time() }
end

---@param archived boolean
local function archive_action(archived)
  return function(picker)
    for _, item in ipairs(picker:selected({ fallback = true })) do
      if not item.group then
        set_archived(item, archived)
      end
    end
    picker.list:set_selected()
    picker:find()
  end
end

-- projects whose sessions are hidden in the picker
local folded = {} ---@type table<string, true>

---@param header table the project's item
---@param fold? true
local function set_folded(picker, header, fold)
  folded[header.project or ''] = fold
  picker.list:set_target()
  picker:find({
    on_done = function()
      for item, idx in picker:iter() do
        if item.group and item.project == header.project then
          return picker.list:view(idx)
        end
      end
    end,
  })
end

--- Shows the session in `win`, or in a vertical split of the main window.
---@param win? integer
local function open_session(picker, item, win)
  vim.api.nvim_set_current_win(win or picker.main)
  if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) then
    if not win then
      vim.cmd.vsplit()
    end
    vim.api.nvim_win_set_buf(0, item.bufnr)
  else
    require('bodgery').open('claude', {
      cwd = item.project,
      args = { '--resume', item.id },
      win = win,
      mods = not win and { vertical = true } or nil,
    })
  end
end

local kept = {} ---@type table<string, true>

--- Deletes a transcript Claude never replied in, such as one holding only /clear or /model.
---@return boolean deleted
local function purge(id)
  if kept[id] then
    return false
  end
  local projects = vim.fs.joinpath(require('bodgery.harness.claude.launch').config_dir(), 'projects')
  local path = vim.fn.glob(vim.fs.joinpath(projects, '*', id .. '.jsonl'), true, true)[1]
  if not path or (read(path) or ''):find('"role":"assistant"', 1, true) then
    kept[id] = true
    return false
  end
  os.remove(path)
  vim.fn.delete(path:gsub('%.jsonl$', ''), 'rf')
  return true
end

---@param record? { path: string, archived: boolean }
local function session_item(s, record)
  local saved = archive_state[s.id] or {}
  if record and saved.archived and not record.archived then
    -- unarchived in the desktop app
    saved = { archived = false, at = os.time() }
    archive_state[s.id] = saved
  end
  local item = {
    id = s.id,
    title = s.title or 'Untitled',
    text = s.title or 'Untitled',
    project = s.cwd,
    time = s.last_activity,
    live = s.live,
    bufnr = s.bufnr,
    desktop = record and record.path,
    archived = (record or saved).archived == true,
  }
  if not item.archived and os.time() - math.max(s.last_activity, saved.at or 0) > archive_after then
    set_archived(item, true)
  end
  return item
end

-- stimpack.dev loads immediately, before snacks (a start pack) is set up
vim.schedule(function()
  Snacks.picker.sources.claude = {
    title = 'Claude Sessions',
    layout = { preset = 'sidebar', preview = false },
    focus = 'list',
    auto_close = false,
    jump = { close = false },
    sort = { fields = { 'sort' } },
    archived = false,
    toggles = { archived = 'a' },

    on_show = function(picker)
      -- scheduled because bodgery clears a terminal's session after these events fire
      local refresh = vim.schedule_wrap(function()
        picker.list:set_target()
        picker:find({ refresh = true })
      end)
      mia.augroup('claude_picker' .. picker.id, {
        User = {
          ClaudeSessionEnter = refresh,
          ClaudeSessionLeave = refresh,
          -- Claude appends titles to the transcript mid-session
          ClaudeStatusChanged = refresh,
        },
        [{ 'TermClose', 'BufWipeout', 'BufWinEnter', 'BufWinLeave' }] = {
          pattern = 'term://*//*:*claude*',
          callback = refresh,
        },
      })
    end,
    on_close = function(picker) pcall(vim.api.nvim_del_augroup_by_name, 'mia.claude_picker' .. picker.id) end,

    filter = {
      -- re-run the finder when a search starts or ends, since searching shows folded sessions
      transform = function(_, filter)
        local searching = not filter:is_empty()
        if filter.meta.searching ~= searching then
          filter.meta.searching = searching
          return true
        end
      end,
    },

    finder = function(opts, ctx)
      local searching = not ctx.filter:is_empty()
      ctx.picker.matcher.opts.keep_parents = searching
      local desktop = desktop_records()
      local cwd = vim.fn.getcwd()
      local sessions = require('bodgery').sessions('claude', { fields = { 'cwd', 'title', 'live', 'bufnr' } })

      local groups, by_project = {}, {}
      for s in sessions do
        local keep = s.title or s.live or s.bufnr or desktop[s.id] or not purge(s.id)
        local item = keep and session_item(s, desktop[s.id])
        if item and (opts.archived or not item.archived) then
          local key = s.cwd or ''
          local group = by_project[key]
          if not group then
            group = {
              header = {
                group = true,
                project = s.cwd,
                current = s.cwd == cwd,
                text = s.cwd and vim.fs.basename(s.cwd) or '(no directory)',
                open = not folded[key],
              },
            }
            -- sessions arrive newest first, so the other groups stay in order of last activity
            table.insert(groups, group.header.current and 1 or #groups + 1, group)
            by_project[key] = group
          end
          item.parent = group.header
          group[#group + 1] = item
        end
      end

      local items = {}
      for i, group in ipairs(groups) do
        group.header.sort = ('%04d'):format(i)
        group.header.count = #group
        for j, item in ipairs(group) do
          item.sort = ('%s.%04d'):format(group.header.sort, j)
        end
        group[#group].last = true
        items[#items + 1] = group.header
        if group.header.open or searching then
          vim.list_extend(items, group)
        end
      end
      return items
    end,

    format = function(item, picker)
      if item.group then
        local icons = picker.opts.icons.files
        return {
          { item.open and icons.dir_open or icons.dir, 'SnacksPickerDirectory' },
          { item.text, item.current and { 'SnacksPickerDirectory', 'SnacksPickerBold' } or 'SnacksPickerDirectory' },
          { item.project and (' (%s)'):format(vim.fn.fnamemodify(item.project, ':~')) or '', 'SnacksPickerDimmed' },
          { item.open and '' or (' (%d)'):format(item.count), 'SnacksPickerDimmed' },
        }
      end
      local tree = Snacks.picker.format.tree(item, picker)[1]
      local shown = item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) and #vim.fn.win_findbuf(item.bufnr) > 0
      local status = shown and '● ' or item.bufnr and '○ ' or item.live and '◌ ' or '  '
      local time = Snacks.picker.util.reltime(item.time)
      local width = vim.api.nvim_win_get_width(picker.list.win.win)
      local room = width - vim.api.nvim_strwidth(tree[1] .. status) - #time - 2
      return {
        tree,
        { status, 'SnacksPickerSpecial' },
        { Snacks.picker.util.truncate(item.title, room), item.archived and 'SnacksPickerDimmed' or nil },
        {
          col = 0,
          virt_text = { { time, 'SnacksPickerTime' } },
          virt_text_pos = 'right_align',
          hl_mode = 'combine',
        },
      }
    end,

    actions = {
      claude_archive = archive_action(true),
      claude_unarchive = archive_action(false),
      claude_split = function(picker, item)
        if item and not item.group then
          open_session(picker, item)
        end
      end,
      claude_fold = function(picker, item)
        local header = item and (item.group and item or item.parent)
        if header then
          set_folded(picker, header, true)
        end
      end,
    },

    win = {
      input = {
        keys = {
          ['<a-a>'] = { 'toggle_archived', mode = { 'i', 'n' } },
          ['<a-x>'] = { 'claude_archive', mode = { 'i', 'n' } },
          ['<a-u>'] = { 'claude_unarchive', mode = { 'i', 'n' } },
          ['<S-CR>'] = { 'claude_split', mode = { 'i', 'n' } },
        },
      },
      list = {
        keys = {
          ['A'] = 'toggle_archived',
          ['x'] = 'claude_archive',
          ['u'] = 'claude_unarchive',
          ['h'] = 'claude_fold',
          ['<S-CR>'] = 'claude_split',
          ['l'] = 'confirm',
        },
      },
    },

    confirm = function(picker, item)
      if not item then
        return
      elseif item.group then
        return set_folded(picker, item, item.open or nil)
      end
      local shown = item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) and vim.fn.win_findbuf(item.bufnr) or {}
      if #shown > 0 then
        local here = vim.api.nvim_get_current_tabpage()
        local win = vim.iter(shown):find(function(w) return vim.api.nvim_win_get_tabpage(w) == here end)
        return vim.api.nvim_set_current_win(win or shown[1])
      end
      local terms = require('bodgery.terminal').terminals
      local win = vim
        .iter(vim.api.nvim_tabpage_list_wins(0))
        :find(function(w) return terms[vim.api.nvim_win_get_buf(w)] ~= nil end)
      open_session(picker, item, win)
    end,
  }
end)
