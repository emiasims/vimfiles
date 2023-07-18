local make_command = function(name, cmd, opts)
  vim.api.nvim_create_user_command(name, cmd, opts or {})
end
local echo = function(...) vim.api.nvim_echo({ ... }, true, {}) end

make_command('CloseFloatingWindows', function()
  local closed = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
      closed[#closed + 1] = win
    end
  end
  print('Windows closed: ', table.concat(closed, ' '))
end)

make_command('Move', function(cmd)
  local filename = cmd.args
  local force = cmd.bang

  local f = io.open(filename, 'r')
  if f ~= nil and io.close(f) and not force then
    echo { 'E13: File exists (add ! to override)', 'Error' }
    return
  end

  local path = vim.fn.expand '%:p'
  vim.cmd.file { vim.fn.fnameescape(filename), mods = { silent = true, keepalt = true } }
  vim.cmd.write { bang = true }
  vim.cmd.filetype 'detect'
  vim.fn.delete(path)
end, { nargs = 1, bang = true, complete = 'file' })

make_command('Delete', function(cmd)
  if not cmd.bang then
    echo { 'Are you sure? Must :Delete!', 'Error' }
    return
  end

  local path = vim.fn.expand '%:p'
  local bn = vim.fn.bufnr()
  vim.fn.delete(path)
  vim.cmd.bwipeout(bn)
end, { bang = true })


make_command('Delview', function(cmd)
  if vim.o.modified and not cmd.bang then
    return echo { 'Save before deleting view', 'Error' }
  elseif vim.o.modified and cmd.bang then
    vim.cmd.write()
  end
  local path = vim.fn.expand '%:p':gsub('=', '==')
  path = path:gsub('^' .. vim.env.HOME, '~')
  path = path:gsub('/', '=+')
  local file = vim.o.viewdir .. path .. '='
  local success = vim.fn.delete(file) == 0
  if success then
    echo { 'Deleted: ' .. file }
  else
    echo { 'No view found: ' .. file, 'Error' }
  end

  local ufo = require 'ufo'
  ufo.openAllFolds()
  ufo.disable()
  ufo.enable()
  vim.cmd.filetype 'detect'
  vim.cmd.write()
  vim.o.foldlevel = 99
  vim.api.nvim_feedkeys('zx', 'nt', true)
  vim.schedule(function()
    ufo.closeAllFolds()
    vim.api.nvim_feedkeys('zvzz', 'mt', true)
  end)
end)

make_command('EditFtplugin', function(cmd)
  vim.cmd.edit(
    ('%s/%s/%s.%s'):format(
      vim.fn.stdpath 'config',
      'after/ftplugin',
      cmd.args == '' and vim.bo.filetype or cmd.args,
      cmd.bang and 'lua' or 'vim'))
  vim.bo.bufhidden = 'wipe'
  vim.bo.buflisted = false
end, { nargs = '?', bang = true, complete = 'filetype' })

-- from runtime, edited to have cursor positioning
make_command('InspectTree', function(cmd)
  local src_win = vim.api.nvim_get_current_win()
  -- directly from $VIMRUNTIME/plugin/nvim.lua
  if cmd.mods ~= '' or cmd.count ~= 0 then
    local count = cmd.count ~= 0 and cmd.count or ''
    local new = cmd.mods ~= '' and 'new' or 'vnew'

    vim.treesitter.inspect_tree {
      command = ('%s %s%s'):format(cmd.mods, count, new),
    }
  else
    vim.treesitter.inspect_tree()
  end
  -- end
  vim.keymap.set('n', 'q', '<cmd>q<cr>', { buffer = true })
  vim.api.nvim_set_current_win(src_win)
end, { desc = 'Inspect treesitter language tree for buffer', count = true })

make_command('CloseHiddenBuffers', function()
  -- local closed = {}
  local closed, modified = 0, 0
  vim.iter(vim.fn.getbufinfo { buflisted = true }):each(function(info)
    modified = modified + ((info.hidden + info.changed == 2) and 1 or 0)
    if info.hidden == 1 and info.changed == 0 then
      vim.cmd.bdelete { info.bufnr, mods = { silent = true } }
      closed = closed + 1
    end
  end)
  local msg = ('Closed %d hidden buffer%s'):format(closed, closed ~= 1 and 's' or '')
  if modified > 0 then
    msg = msg .. (', %s modified left open'):format(modified)
  end
  echo { msg }
end)

make_command('Redir', function(cmd)
  local redir, lines = cmd.args, {}

  if redir:sub(1, 1) == '!' then
    redir = redir:sub(2):gsub(' %%', ' ' .. vim.fn.expand '%:p')
    if cmd.range > 0 then
      -- filter range through command, like :!
      redir = redir .. ' <<< $' .. vim.fn.shellescape(
        table.concat(vim.fn.getline(cmd.line1, cmd.line2), '\n')
      ):gsub("'\\\\''", "\\\\'")
    end
    lines = vim.fn.systemlist(redir)
  elseif redir:sub(1, 1) == '=' then
    local values = { assert(loadstring('return ' .. redir:sub(2)))() }
    vim.iter(values):map(vim.inspect):each(function(v)
      vim.list_extend(lines, vim.split(v, '\n'))
    end)
  else
    lines = vim.split(vim.fn.execute(redir), '\n')
  end

  -- open window
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.w[win].scratch then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.cmd.vnew()
  vim.w.scratch = 1
  vim.iter {
    buftype = 'nofile',
    bufhidden = 'wipe',
    buflisted = false,
    swapfile = false,
  }:each(function(k, v) vim.bo[k] = v end)

  -- set lines
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end, { complete = 'command', nargs = '*', bar = true, range = true})

make_command('Clearqflist', function() vim.fn.setqflist {} end)
make_command('Clearloclist', function() vim.fn.setloclist(0, {}) end)
