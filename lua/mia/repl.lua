local repl = { endline = '<Cr><C-u>' }
local api = vim.api

function repl.get_target()
  local winnr = vim.tbl_filter(function(x)
    return api.nvim_buf_get_option(vim.fn.winbufnr(x), 'buftype') == 'terminal'
  end, api.nvim_tabpage_list_wins(0))[1]
  if winnr then
    local buffer = vim.fn.winbufnr(winnr)
    for _, chan in ipairs(api.nvim_list_chans()) do
      if chan.buffer and buffer == vim.fn.bufnr(chan.buffer) then
        return chan
      end
    end
  end
end

function repl.send_text(text, target)
  target = target or repl.get_target()
  if not target then
    api.nvim_echo({ { 'No term displayed in current window.', 'Error' } }, true, {})
    return
  end

  if type(text) == 'string' then
    text = { text }
  end
  local endl = vim.fn.getbufvar(0, 'repl_endline', repl.endline)
  text = table.concat(text, endl) .. endl
  if vim.o.filetype == 'python' then
    text = text .. endl
  end
  text = api.nvim_replace_termcodes(text, true, false, true)
  api.nvim_chan_send(target.id, text)
end

function repl.send_range(open, close, linewise)
  open = api.nvim_buf_get_mark(0, open)
  close = api.nvim_buf_get_mark(0, close)
  api.nvim_buf_set_mark(0, 'x', open[1], open[2], {})
  if linewise then
    repl.send_text(api.nvim_buf_get_lines(0, open[1] - 1, close[1], true))
  else
    repl.send_text(api.nvim_buf_get_text(0, open[1] - 1, open[2], close[1] - 1, close[2] + 1, {}))
  end
end

function repl.send_visual()
  api.nvim_feedkeys('', 'nx', false)  -- this is annoying as shit.
  if vim.fn.visualmode():match '[vV]' then
    repl.send_range('<', '>', vim.fn.visualmode():match 'V')
  else
    api.nvim_echo({ { 'Trying to send visual text when not in visual mode', 'Error' } }, true, {})
  end
end

function repl.opfunc(type)
  if type == 'line' or type == 'char' then
    repl.send_range('[', ']', type == 'line')
  else
    api.nvim_echo({ { "Can't send blocks to repl", 'Error' } }, true, {})
  end
end

function repl.send_motion()
  -- must use expr = true.
  vim.o.opfunc = 'v:lua._repl.opfunc'
  return 'g@'
end

function repl.send_line()
  local line = api.nvim_get_current_line()
  local ws = #line:match '^%s*'
  api.nvim_buf_set_mark(0, 'x', vim.fn.line '.', ws, {})
  repl.send_text(line:sub(ws + 1))
  api.nvim_feedkeys('j', 'n', false)
end

function repl.start(filetype)
  filetype = filetype or vim.bo.filetype
  local cmd
  if filetype == 'python' then
    cmd = _G._conda.env .. '/bin/ipython'  -- lua/mia/conda.lua
  end
  vim.cmd.vsplit()
  vim.cmd.term(cmd)
  vim.cmd.wincmd 'p'

  local last = vim.fn.line '$'
  local start = last
  local comment_pat = '%s*' .. vim.o.commentstring:gsub('%%s', '.*')

  while start > 0 and vim.fn.getline(start):match(comment_pat) do
    start = start - 1
  end

  for lnum = start + 1, last do
    local pat = vim.o.commentstring:gsub('%%s', 'repl: (.+)')
    local replmodeline = vim.fn.getline(lnum):match(pat)
    if replmodeline then
      vim.cmd(replmodeline)
    end

    -- send lines from the modeline
    pat = vim.o.commentstring:gsub('%%s', '\\vsend%%(\\[(.+)\\])?: (.+)')
    local matches = vim.fn.matchlist(vim.fn.getline '$', pat)
    if #matches > 0 then
      repl.send_text(vim.split(matches[3], matches[2] ~= '' and matches[2] or '|'))
    end
  end
end

api.nvim_create_user_command('Repl', function(cmd)
  if cmd.args == '' then
    cmd.args = nil
  end
  repl.start(cmd.args)
end, { nargs = '?', complete = 'filetype', bar = true })

_G._repl = repl

return repl
