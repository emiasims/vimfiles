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

function repl.send_visual()
  api.nvim_feedkeys('', 'nx', false)  -- this is annoying as shit.
  local open = api.nvim_buf_get_mark(0, '<')
  local close = api.nvim_buf_get_mark(0, '>')
  if vim.fn.visualmode():match 'V' then
    repl.send_text(api.nvim_buf_get_lines(0, open[1] - 1, close[1], true))
  elseif vim.fn.visualmode():match 'v' then
    repl.send_text(api.nvim_buf_get_text(0, open[1] - 1, open[2], close[1] - 1, close[2] + 1, {}))
  else
    api.nvim_echo({ { 'Trying to send visual text when not in visual mode', 'Error' } }, true, {})
  end
end

function repl.opfunc(type)
  local open = api.nvim_buf_get_mark(0, '[')
  local close = api.nvim_buf_get_mark(0, ']')
  if type == 'line' then
    repl.send_text(api.nvim_buf_get_lines(0, open[1] - 1, close[1], true))
  elseif type == 'char' then
    repl.send_text(api.nvim_buf_get_text(0, open[1] - 1, open[2], close[1] - 1, close[2] + 1, {}))
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
  repl.send_text(vim.api.nvim_get_current_line())
  api.nvim_feedkeys('j', 'n', false)
end

_G._repl = repl

return repl
