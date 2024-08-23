local M = {}
---@param name string
---@param cmd cmd.usercmd
---@param opts? cmd.create_opts
local command = function(name, cmd, opts)
  vim.api.nvim_create_user_command(name, cmd, opts or {})
  M[name] = cmd
end

local echo = function(...)
  vim.api.nvim_echo({ ... }, true, {})
end

command('Move', function(cmd)
  local src, dest = cmd.fargs[1], cmd.fargs[2]
  if not dest then
    dest = src
    src = vim.fn.expand('%')
  end
  local moved = require('mia.move').Move(src, dest, cmd.bang)
  if moved then
    for ix, mv in ipairs(moved) do
      moved[ix] = mv[1] .. ' to ' .. mv[2]
    end
    echo({ 'Moved: ' .. table.concat(moved, ', '), 'WarningMsg' })
  end
end, { nargs = '+', bang = true, complete = 'file' })

command('Delete', function(cmd)
  if not cmd.bang then
    echo({ 'Are you sure? Must :Delete!', 'ErrorMsg' })
    return
  end

  local path = vim.fn.expand('%:p')
  local bn = vim.fn.bufnr()
  vim.cmd.argdelete({ '%', mods = { emsg_silent = true } })
  vim.fn.delete(path)
  vim.cmd.bwipeout(bn)
end, { bang = true })

command('Delview', function(cmd)
  if vim.o.modified and not cmd.bang then
    return echo({ 'Save before deleting view', 'ErrorMsg' })
  elseif vim.o.modified and cmd.bang then
    vim.cmd.write()
  end
  local path = vim.fn.expand('%:p') --[[@as string]]
  path = path:gsub('=', '==')
  path = path:gsub('^' .. vim.env.HOME, '~')
  path = path:gsub('/', '=+')
  local file = vim.o.viewdir .. path .. '='
  local success = vim.fn.delete(file) == 0
  if success then
    echo({ 'Deleted: ' .. file })
  else
    echo({ 'No view found: ' .. file, 'ErrorMsg' })
  end
  vim.api.nvim_feedkeys('zx', 'nt', true)

  vim.schedule_wrap(vim.api.nvim_feedkeys)('zVzz', 'mt', true)
end)

command('EditFtplugin', function(cmd)
  local edit = vim.cmd.edit
  if cmd.smods.vertical or cmd.smods.horizontal then
    edit = vim.cmd.split
  end
  edit({
    ('%s/%s/%s.%s'):format(
      vim.fn.stdpath('config'),
      'after/ftplugin',
      cmd.args == '' and vim.bo.filetype or cmd.args,
      cmd.bang and 'lua' or 'vim'
    ),
    mods = cmd.smods,
  })
  vim.bo.bufhidden = 'wipe'
  vim.bo.buflisted = false
end, { nargs = '?', bang = true, complete = 'filetype' })

command('CloseHiddenBuffers', function()
  -- local closed = {}
  local closed, modified = 0, 0
  vim.iter(vim.fn.getbufinfo({ buflisted = true })):each(function(info)
    modified = modified + ((info.hidden + info.changed == 2) and 1 or 0)
    if info.hidden == 1 and info.changed == 0 then
      vim.cmd.bdelete({ info.bufnr, mods = { silent = true } })
      closed = closed + 1
    end
  end)
  local msg = ('Closed %d hidden buffer%s'):format(closed, closed ~= 1 and 's' or '')
  if modified > 0 then
    msg = msg .. (', %s modified left open'):format(modified)
  end
  echo({ msg })
end)

command('Redir', function(cmd)
  local redir = cmd.args --[[@as string]]
  local lines = {}

  if redir:sub(1, 1) == '!' then
    redir = redir:sub(2):gsub(' %%', ' ' .. vim.fn.expand('%:p'))
    if cmd.range > 0 then
      -- filter range through command, like :!
      redir = redir
        .. ' <<< $'
        .. vim.fn
          .shellescape(table.concat(vim.fn.getline(cmd.line1, cmd.line2) --[[@as table]], '\n'))
          :gsub("'\\\\''", "\\\\'")
    end
    lines = vim.fn.systemlist(redir) --[=[@as string[]]=]
  elseif redir:sub(1, 1) == '=' then
    local values = { assert(loadstring('return ' .. redir:sub(2)))() }
    vim.iter(values):map(vim.inspect):each(function(v)
      vim.list_extend(lines, vim.split(v, '\n'))
    end)
  else
    ---@diagnostic disable-next-line: param-type-mismatch
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
  vim
    .iter({
      buftype = 'nofile',
      bufhidden = 'wipe',
      buflisted = false,
      swapfile = false,
    })
    :each(function(k, v)
      vim.bo[k] = v
    end)

  -- set lines
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end, { complete = 'command', nargs = '*', bar = true, range = true })

command('Clearqflist', function()
  vim.fn.setqflist({})
end)

command('Clearloclist', function()
  vim.fn.setloclist(0, {})
end)

--local options = { 'float', 'hidden', 'other_tabs', 'terminals' }
--command('Close', function(cmd)
--  vim.fn.setloclist(0, {})
--end, {
-----@type cmd.completeFunc
--complete = function (ArgLead, CmdLine, CursorPos)
--end, nargs = '+', bang = true })
--

command('UpdateMeta', function()

  -- mia values or something

  -- vim.hlgroup
  local hls = {}
  local hexpat = string.rep('[%da-fA-F]', 6)
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if not (name:match('^' .. hexpat .. '$') or name:match('^0x' .. hexpat .. '$')) then
      local desc
      if hl.link then
        desc = ('links to "%s"'):format(hl.link)
      else
        local _d = { mods = {} }
        for k, v in pairs(hl) do
          if type(v) == 'number' then
            table.insert(_d, ('%s: #%x'):format(k, v))
          elseif type(v) == 'boolean' then
            table.insert(_d.mods, ('%s%s'):format(v and '' or 'no', k))
          end
        end
        if #_d.mods > 0 then
          table.insert(_d, 'mods: ' .. table.concat(_d.mods, ', '))
        end
        desc = table.concat(_d, ', ')
      end

      table.insert(hls, ('---|"%s" %s'):format(name, desc))
    end
  end
  table.sort(hls)

  ---@diagnostic disable-next-line: param-type-mismatch
  local fname = vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', '_meta_gen.lua')
  local metafile = io.open(fname, 'w')
  local header = {
    '---@meta _',
    "error('Cannot require a meta file')",
    '-- automatically generated by :UpdateMeta\n',
    '---@alias vim.hlgroup\n',
  }
  if metafile then
    metafile:write(table.concat(header, '\n'))
    metafile:write(table.concat(hls, '\n'))
    metafile:close()
  end
end)

command('SudoEdit', function(cmd)
end, {
  desc = 'Edit file as root',
  nargs = '?',
  complete = 'file',
})

-- commands({
--   Move = { 'Edit file as root', '' },
--   Delete = { 'Delete' },
--   Delview = {},
--   EditFtplugin = {},
--   CloseHiddenBuffers = {},
--   Redir = {},
--   Clearqflist = {},
--   Clearloclist = {},
--   UpdateMeta = {},
--   SudoEdit = {},
-- })

return M
