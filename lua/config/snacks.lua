local M = {}

mia.command('Pick', {
  nargs = '+',
  callback = function(cmd)
    local opts = { source = cmd.fargs[1] }

    for i = 2, #cmd.fargs do
      local k, v = cmd.fargs[i]:match('^(%w+)=(.*)$') -- escaping ws works
      if not k then
        error('Invalid argument: ' .. cmd.fargs[i])
      end
      if v == 'true' then
        opts[k] = true
      elseif v == 'false' then
        opts[k] = false
      else
        opts[k] = vim.fn.expandcmd(v)
      end
    end

    Snacks.picker.pick(opts)
  end,

  -- arglead, cmdline, cursorpos
  complete = function(arglead, cmdline, _)
    if cmdline == 'Pick ' then
      return vim.tbl_keys(Snacks.picker.config.get().sources --[[@as table]])
    end

    local opts = Snacks.picker.config.get({ source = cmdline:match('Pick (%S+)') })

    local opt = arglead:match('^(%w+)=')
    if not opt then
      local ret = { 'cwd=' }
      local skip = { enabled = true, source = true }

      for k, v in pairs(opts) do
        if not skip[k] and type(v) ~= 'table' then
          table.insert(ret, k .. '=')
        end
      end
      return ret
    end

    if opt == 'focus' then
      return { 'input', 'list' }
    elseif opt == 'finder' then
      return vim
        .iter(Snacks.picker.config.get().sources)
        :map(function(_, v)
          return type(v.finder) == 'string' and v.finder or nil
        end)
        :totable()
    elseif opt == 'layout' then
      return vim.tbl_keys(Snacks.picker.config.get().layouts)
    elseif opt == 'cwd' then
      return vim.fn.getcompletion(arglead:sub(#opt + 2), 'dir', true)
    elseif type(opts[opt]) == 'boolean' then
      return { 'true', 'false' }
    end
  end,
})

local MacroReg = mia.cache.file('macro_reg')
mia.augroup('mia-snacks', {
  TextYankPost = function()
    MacroReg[vim.v.event.regname] = nil
  end,
  RecordingLeave = function()
    MacroReg[vim.v.event.regname] = true
  end,
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
M.put_register = function(opts)
  opts = opts or {}

  local buf = {
    nr = vim.api.nvim_get_current_buf(),
    pos = vim.api.nvim_win_get_cursor(0),
    undo = false,
  }

  return Snacks.picker.pick(vim.tbl_extend('force', {
    layout = 'select',
    preview = 'none',
    items = vim
    .iter(('*"+0123456789abcdefghijklmnopqrstuvwxyz-/#=_')
    :gmatch('.'))
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
        vim.api.nvim_buf_call(buf.nr, function()
          vim.cmd.undo({ bang = true })
        end)
      end
    end,

    confirm = function(picker, item)
      picker:close()
      vim.api.nvim_put(item.data.content, item.data.type, true, false)
    end,
  }, opts))
end

---@module 'snacks'
---@type snacks.picker.Config
M.picker_opts = {
  enabled = true,
  layout = 'pseudo_sidebar',

  win = {
    input = {
      keys = { ['<C-t>'] = { 'tabdrop', mode = { 'i', 'n' } } },
    },
  },
  layouts = {
    pseudo_sidebar = { -- sidebar, but in floating windows.
      layout = {
        box = 'horizontal',
        backdrop = false,
        row = 1,
        width = 0,
        height = function()
          return vim.o.lines - 3
        end,
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
    cmd_complete = {
      preview = 'none',
      finder = function(opts, ctx)
        -- cmdcmplete & cmdcompletetype
      end,
    },
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
          :map(function(item)
            return { file = item, text = item }
          end)
          :totable()
      end,
    },
    nvim_plugins = {
      multi = {
        {
          finder = 'files',
          format = 'file',
          cwd = vim.fn.stdpath('data') .. '/lazy',
        },
        {
          finder = 'files',
          format = 'file',
          cwd = vim.fn.stdpath('config') .. '/mia_plugins',
        },
      },
    },
    config_files = {
      format = 'file',
      finder = function()
        return vim
          .iter(vim.fn.systemlist('git cfg ls-files --exclude-standard'))
          :map(function(item)
            return { file = item, cwd = vim.env.HOME, text = item }
          end)
          :totable()
      end,
    },
  },
}

M.ctxmap = {
  {
    mode = 'ca',
    -- ctx = 'builtin.cmd_start',
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
    { 'evr', 'Pick files cwd=$VIMRUNTIME' },
    { 'evs', 'Pick nvim_plugins' },
    { 'ecf', 'Pick config_files' },
    { 'gst', 'Pick git_status' },
    { 'ep', 'Pick prompts' },
  },
  { '<C-p>', { 'opt.buftype() == "" and opt.modifiable()', M.put_register }, desc = 'Pick register & put' },
}

M.keys = {
  { 'gd', '<Cmd>Pick lsp_definitions<Cr>', desc = 'Goto Definition' },
  { 'gD', '<Cmd>Pick lsp_declarations<Cr>', desc = 'Goto Declaration' },
  { 'gr', '<Cmd>Pick lsp_references<Cr>', nowait = true, desc = 'References' },
  { 'gI', '<Cmd>Pick lsp_implementations<Cr>', desc = 'Goto Implementation' },
  { 'gy', '<Cmd>Pick lsp_type_definitions<Cr>', desc = 'Goto T[y]pe Definition' },
  { '<C-g><C-o>', '<Cmd>Pick jumps<Cr>', desc = 'Pick jumps' },
  { 'z-', '<Cmd>Pick spelling<Cr>', desc = 'Pick spelling' },
}

return M
