local repl = {}

local cfg = {
  cmd = {
    python = _G._conda.env .. '/bin/ipython',  -- lua/mia/conda.lua
    julia = 'julia'
  },
  keys = { global = true, motion = 'gx', line = 'gxl' },
  tkeys = { confirm = '<Cr>' },
  mark = 'x',
  keybinds = { repl_only = false },
  endline = { python = '<Cr><C-u>' }, -- default and filetypes
  on_attach = {
    python = function()
      local setup_greek = function(char)
        vim.keymap.set('t', '\\' .. char, vim.fn.digraph_get('*' .. char))
      end
      for i = 65, 90 do
        setup_greek(string.char(i))
      end
      for i = 97, 122 do
        setup_greek(string.char(i))
      end
    end
  },
}

function repl.setup(opts)
  -- cfg
  -- keybinds: global or only when you open a repl?
  -- end of line per filetype
  -- whether or not to mark

  repl._setup_keymaps(false)
end

function repl._setup_endline(bufnr, filetype)
  if bufnr == true then
    bufnr = vim.api.nvim_get_current_buf()
  end
  vim.b.repl_endline = cfg.endline[filetype]
end

function repl.get_target()
  local winnr = vim.tbl_filter(function(x)
    return vim.api.nvim_buf_get_option(vim.fn.winbufnr(x), 'buftype') == 'terminal'
  end, vim.api.nvim_tabpage_list_wins(0))[1]
  if winnr then
    local buffer = vim.fn.winbufnr(winnr)
    for _, chan in ipairs(vim.api.nvim_list_chans()) do
      if chan.buffer and buffer == vim.fn.bufnr(chan.buffer) then
        return chan
      end
    end
  end
end

function repl.send_text(text, target)
  target = target or repl.get_target()
  if not target then
    return vim.api.nvim_err_writeln 'No terminal window displayed in current tab.'
  end

  if type(text) == 'string' then
    text = { text }
  end
  local endl = vim.fn.getbufvar(vim.fn.bufnr(), 'repl_endline', '<CR>')
  text = table.concat(text, endl) .. endl
  if vim.o.filetype == 'python' then
    text = text .. endl
  end
  text = vim.api.nvim_replace_termcodes(text, true, false, true)
  vim.api.nvim_chan_send(target.id, text)
end

function repl.send_range(open, close, linewise)
  if type(open) == 'number' and type(close) == 'number' then
    -- send line number range
    open, close, linewise = { open }, { close }, true
  else
    -- send range over two marks
    open = vim.api.nvim_buf_get_mark(0, open)
    close = vim.api.nvim_buf_get_mark(0, close)
  end
  vim.api.nvim_buf_set_mark(0, 'x', open[1], open[2], {})
  if linewise then
    repl.send_text(vim.api.nvim_buf_get_lines(0, open[1] - 1, close[1], true))
  else
    repl.send_text(vim.api.nvim_buf_get_text(0, open[1] - 1, open[2], close[1] - 1, close[2] + 1, {}))
  end
end

function repl.send_visual()
  if vim.fn.visualmode():match '[vV]' then
    -- this is odd. Is there a better way to exit visual mode and update the marks?
    vim.api.nvim_feedkeys('', 'nx', false)
    repl.send_range('<', '>', vim.fn.visualmode():match 'V')
  else
    vim.api.nvim_err_writeln 'Trying to send visual text when not in visual char or line mode'
  end
end

function repl.opfunc(type)
  if type == 'line' or type == 'char' then
    repl.send_range('[', ']', type == 'line')
  else
    vim.api.nvim_err_writeln 'Unable send blocks to repl'
  end
end

function repl.send_motion()
  vim.o.opfunc = "v:lua.require'mia.repl'.opfunc"
  return 'g@'
end

function repl.send_line()
  local line = vim.api.nvim_get_current_line()
  local ws = #line:match '^%s*'
  vim.api.nvim_buf_set_mark(0, 'x', vim.fn.line '.', ws, {})
  repl.send_text(line:sub(ws + 1))
  vim.api.nvim_feedkeys('j', 'n', false)
end

function repl.send_modeline()
  -- TODO target
  local last = vim.fn.line '$'
  local lnum = last
  local pattern = {
    comment = '%s*' .. vim.o.commentstring:gsub('%%s', '.*'),
    repl = vim.o.commentstring:gsub('%%s', '%%s*repl cmd: (.+)'),
    send = vim.o.commentstring:gsub('%%s', '\\v\\s*repl send%%(\\[(.+)\\])?: (.+)'),
  }

  local cmd = {}
  local send = {}
  while lnum > 0 and vim.fn.getline(lnum):match(pattern.comment) do
    local vimcmd = vim.fn.getline(lnum):match(pattern.repl)
    if vimcmd then
      cmd[#cmd+1] = vimcmd
    else
      local matches = vim.fn.matchlist(vim.fn.getline(lnum), pattern.send)
      if #matches > 0 then
        send[#send+1] = vim.split(matches[3], matches[2] ~= '' and matches[2] or '|')
      end
    end
    lnum = lnum - 1
  end

  vim.iter(cmd):rev():map(vim.cmd)
  vim.iter(send):rev():map(repl.send_text)
end

function repl.start(filetype)
  local bufnr
  if cfg.cmd[filetype] == 'function' then
    bufnr = cfg.cmd[filetype]()
    if not bufnr then
      vim.api.nvim_err_writeln(('Repl setup function for "%s" must return terminal buffer number'):format(filetype))
      return
    end
  else
    vim.cmd.vsplit()
    vim.cmd.term(cfg.cmd[filetype])
    bufnr = vim.api.nvim_get_current_buf()
    vim.cmd.wincmd 'p'
    repl.send_modeline()
  end
  -- repl._setup_keymaps(bufnr)
  if cfg.on_attach[filetype] then
    cfg.on_attach[filetype]()
  end
  repl._setup_endline(bufnr, filetype)
end

vim.api.nvim_create_user_command('Repl', function(cmd)
  -- set up keybinds here?
  repl.start(cmd.args == '' and vim.bo.filetype or cmd.args)
end, { nargs = '?', complete = 'filetype', bar = true })

vim.api.nvim_create_user_command('ReplModeLine', repl.send_modeline, { bar = true })

return repl
