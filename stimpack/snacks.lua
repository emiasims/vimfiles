stimpack.add({ 'https://github.com/folke/snacks.nvim' })

local function build_completions(source)
  local opts = Snacks.picker.config.get({ source = source })
  local skip = { enabled = true, source = true }
  local completions = { cwd = 'dir' } ---@type table<string|number, any>
  for k, v in pairs(opts) do
    if not skip[k] and type(v) ~= 'table' then
      completions[k] = type(v) == 'boolean' and { 'true', 'false' } or true
    end
  end
  completions.focus = { 'input', 'list' }
  completions.layout = function() return vim.tbl_keys(Snacks.picker.config.get().layouts) end
  completions.finder = function()
    return vim
      .iter(Snacks.picker.config.get().sources)
      :map(function(_, v) return type(v.finder) == 'string' and v.finder or nil end)
      :totable()
  end
  return completions
end

local function pick_callback(source)
  return function(o)
    local opts = { source = source }
    for _, arg in ipairs(o.fargs) do
      local k, v = arg:match('^(%w+)=(.*)$')
      if not k then
        error('Invalid argument: ' .. arg)
      end
      if v == 'true' then
        opts[k] = true
      elseif v == 'false' then
        opts[k] = false
      else
        opts[k] = vim.fn.expandcmd(v)
      end
    end
    local p = Snacks.picker.pick(opts)
    if p then
      vim.wait(5000, function() return p.shown or p.closed or false end, 10)
    end
  end
end

mia.command('Pick', {
  nargs = '+',
  desc = 'Snacks picker',
  subcommands = function()
    local cmds = vim
      .iter(Snacks.picker.config.get().sources)
      :map(function(name) return name, { pick_callback(name), complete = build_completions(name) } end)
      :fold({}, rawset)
    cmds.resume = Snacks.picker.resume
    return cmds
  end,
})

local MacroReg = mia.cache.file('macro_reg')
mia.augroup('snacks', {
  TextYankPost = function() MacroReg[vim.v.event.regname] = nil end,
  RecordingLeave = function() MacroReg[vim.v.event.regname] = true end,
  FileType = {
    pattern = 'snacks_*',
    callback = function(ev)
      local name = ev.match:sub(8)
      if name == 'layout_box' then
        local rel_path = vim.fs.relpath('~', vim.fn.getcwd())
        -- the only time I see a 'layout_box' with my config is for snacks explorer
        -- everything else is a floating window, which won't be on the tabline.
        vim.b.update_bufinfo = {
          type = 'dir',
          name = rel_path and '~/' .. rel_path or vim.fn.getcwd(),
          dir = false,
        }
      else
        vim.b.update_bufinfo = {
          type = 'snacks',
          name = ev.match:sub(8), -- snacks_
        }
      end
    end,
  },
})

local function get_regitem(reg)
  local info = vim.fn.getreginfo(reg)

  if not MacroReg[reg] and info.regcontents and table.concat(info.regcontents, '\n'):match('%S') then
    local type = ({ v = 'c', V = 'l', ['\22'] = 'b' })[info.regtype:sub(1, 1)]
    type = type or info.regtype:sub(1, 1)
    local value = table.concat(info.regcontents, '\\n')
    return {
      text = reg .. ': ' .. value,
      type = type,
      reg = reg,
      content = value,
      data = { type = info.regtype, content = info.regcontents },
    }
  end
end

local ns = vim.api.nvim_create_namespace('snacks_put_register')
local function put_register(_opts)
  _opts = _opts or {}

  local buf = {
    nr = vim.api.nvim_get_current_buf(),
    pos = vim.api.nvim_win_get_cursor(0),
    undo = false,
  }

  return Snacks.picker.pick(vim.tbl_extend('force', {
    layout = 'select',
    preview = 'none',
    items = vim
      .iter(('*"+0123456789abcdefghijklmnopqrstuvwxyz-/#=_'):gmatch('.'))
      :map(get_regitem)
      :fold({}, function(items, item)
        if #items == 0 or item.content ~= items[#items].content or item.type ~= items[#items].type then
          table.insert(items, item)
        end
        return items
      end),

    format = function(item)
      -- like :registers
      return {
        { '  ' },
        { item.type, 'SnacksPickerUndoAdded' },
        { '  "' },
        { item.reg, 'SnacksPickerRegister' },
        { '   ' },
        { item.content },
      }
    end,

    on_change = function(_, item)
      local msg
      local opts = {
        number_hl_group = 'Special',
        hl_group = 'Visual',
        strict = false,
      }
      vim.api.nvim_buf_call(buf.nr, function()
        vim.api.nvim_buf_clear_namespace(buf.nr, ns, 0, -1)
        if buf.undo then
          vim.cmd.undo({ bang = true })
        end
        vim.api.nvim_win_set_cursor(0, buf.pos)
        buf.undo, msg = pcall(vim.api.nvim_put, item.data.content, item.data.type, true, false)
        if not buf.undo then
          mia.err(msg)
        else
          -- highlight with Visual extmark
          local sr, sc = unpack(vim.api.nvim_buf_get_mark(buf.nr, '['))
          local er, ec = unpack(vim.api.nvim_buf_get_mark(buf.nr, ']'))
          sr, er = sr - 1, er - 1
          opts.end_col = ec + 1
          if item.type == 'b' then
            for i = sr, er do
              opts.end_line = i
              vim.api.nvim_buf_set_extmark(buf.nr, ns, i, sc, opts)
            end
          else
            opts.end_line = er
            vim.api.nvim_buf_set_extmark(buf.nr, ns, sr, sc, opts)
          end
        end
      end)
    end,

    on_close = function(picker)
      vim.api.nvim_buf_clear_namespace(buf.nr, ns, 0, -1)
      if buf.undo then
        vim.api.nvim_buf_call(buf.nr, function() vim.cmd.undo({ bang = true }) end)
      end
    end,

    confirm = function(picker, item)
      picker:close()
      vim.api.nvim_put(item.data.content, item.data.type, true, false)
    end,
  }, _opts))
end

---@module 'snacks'
---@type snacks.picker.Config
local picker_opts = {
  enabled = true,
  layout = 'pseudo_sidebar',

  layouts = {
    -- sidebar, but in floating windows.
    pseudo_sidebar = { --[[@as snacks.picker.layout.Config]]
      layout = { ---@diagnostic disable-line: missing-fields
        box = 'horizontal',
        backdrop = false,
        row = 1,
        width = 0,
        height = function() return vim.o.lines - 3 end,
        {
          box = 'vertical',
          width = 50,
          {
            win = 'input',
            height = 1,
            border = 'rounded',
            title = ' {title} {live} {flags}',
            title_pos = 'center',
          },
          { win = 'list', border = 'rounded' },
        },
        {
          win = 'preview',
          title = '{preview}',
          border = 'rounded',
          wo = { wrap = true },
        },
      },
    },
  },
  sources = {
    dirs = {
      preview = 'directory',
      finder = function(opts, ctx)
        return require('snacks.picker.source.proc').proc({
          opts,
          {
            cmd = 'fdfind',
            args = { '--type', 'd', '--color', 'never', '-E', '.git' },
            ---@param item snacks.picker.finder.Item
            transform = function(item)
              item.file = item.text
              -- item.file = opts.cwd and (vim.fs.joinpath(opts.cwd, item.text) or item.text
              item.cwd = opts.cwd
            end,
          },
        }, ctx)
      end,
    },
    prompts = {
      format = 'file',
      cwd = vim.fn.stdpath('config') .. '/prompts',
      finder = function()
        return vim
          .iter(vim.api.nvim_get_runtime_file('prompts/*.*', true))
          :map(function(item) return { file = item, text = item } end)
          :totable()
      end,
    },
    sessions = {
      sort = { fields = { 'time:desc' } },
      matcher = { frecency = true, sort_empty = true, cwd_bonus = false },
      format = 'text',
      finder = function() return require('session').get_sessinfo() end,

      transform = function(sess, _)
        return {
          time = sess.mtime,
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
          require('session').load(item.file)
        end
      end,
    },
    -- filter excludes some paths and bc it merges via tbl_extend, setting to nil
    -- doesn't remove the filter. And setting to true says to use only those dirs.
    ---@diagnostic disable-next-line: assign-type-mismatch
    recent = { filter = false },
  },
}

require('snacks').setup({
  bigfile = { enabled = false },
  dashboard = { enabled = false },
  explorer = { enabled = true },
  indent = { enabled = true, indent = { char = '╎' } },
  input = { enabled = true },
  notifier = {
    margin = { bottom = 1 },
    enabled = true,
    style = 'history',
    top_down = false,
  },
  quickfile = { enabled = false },
  scope = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = false }, -- ??

  picker = picker_opts,
})

mia.keymap({
  { 'gd', '<Cmd>Pick lsp_definitions<Cr>', desc = 'Goto Definition' },
  { 'gD', '<Cmd>Pick lsp_declarations<Cr>', desc = 'Goto Declaration' },
  { 'grr', '<Cmd>Pick lsp_references<Cr>', nowait = true, desc = 'References' },
  { 'gI', '<Cmd>Pick lsp_implementations<Cr>', desc = 'Goto Implementation' },
  { 'gy', '<Cmd>Pick lsp_type_definitions<Cr>', desc = 'Goto T[y]pe Definition' },
  { '<C-g><C-o>', '<Cmd>Pick jumps<Cr>', desc = 'Pick jumps' },
  { 'z-', '<Cmd>Pick spelling<Cr>', desc = 'Pick spelling' },
})

local ctx = require('ctxmap')

ctx.keymap.sets({
  mode = 'ca',
  ctx = 'cmd.start',
  { 'p', 'Pick smart' },
  { 'pi', 'Pick' },
  { 'pp', 'Pick pickers' },
  { 'f', 'Pick files' },
  { 'fh', 'Pick files cwd=%:h' },
  { 'u', 'Pick undo' },
  { 'l', 'Pick buffers' },
  { 'pr', 'Pick resume' },
  { 'mr', 'Pick recent' },
  { 'A', 'Pick grep' },
  { 'h', 'Pick help' },
  { 'n', 'Pick notifications' },
  { 'ex', 'Pick explorer' },
  { 'hi', 'Pick highlights' },
  { 'em', 'Pick icons' },
  { 't', 'Pick lsp_symbols' },
  { 'ps', 'Pick lsp_symbols' },
  { 'pws', 'Pick lsp_workspace_symbols' },
  { 'ev', 'Pick files cwd=<C-r>=stdpath("config")<Cr>' },
  { 'evp', 'Pick files cwd=<C-r>=stdpath("config")<Cr>/mia_plugins' },
  { 'evs', 'Pick files cwd=<C-r>=stdpath("data")<Cr>/lazy' },
  { 'evr', 'Pick files cwd=$VIMRUNTIME' },
  { 'ecf', 'Pick files cwd=~/dotfiles' },
  { 'gst', 'Pick git_status' },
  { 'ep', 'Pick prompts' },
})

ctx.keymap.set('n', '<C-p>', {
  { 'opt.buftype() == "" and opt.modifiable()', function()
    return put_register()
  end },
}, { desc = 'Pick register & put' })
