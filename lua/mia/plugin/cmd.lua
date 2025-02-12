---@type mia.commands
local impl = {
  Delete = {
    bang = true,
    callback = function(cmd)
      if not cmd.bang then
        mia.err('Are you sure? Must :Delete!')
        return
      end

      local path = vim.fn.expand('%:p')
      local bn = vim.fn.bufnr()
      -- vim
      vim.cmd.buffer({ '#', mods = { emsg_silent = true } })
      vim.cmd.argdelete({ '%', mods = { emsg_silent = true } })
      vim.fn.delete(path)
      vim.cmd.bwipeout(bn)
    end,
  },

  EditFtplugin = {
    nargs = '?',
    bang = true,
    complete = 'filetype',
    callback = function(cmd)
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
    end,
  },

  CloseHiddenBuffers = {
    complete = 'command',
    nargs = '*',
    bar = true,
    range = true,
    callback = function()
      -- local closed = {}
      local closed, modified = 0, 0
      vim.iter(vim.fn.getbufinfo({ buflisted = 1 })):each(function(info)
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
      mia.info(
        'Closed %d hidden buffer%s%s',
        closed,
        closed ~= 1 and 's' or '',
        modified > 0 and (', %s modified left open'):format(modified) or ''
      )
    end,
  },

  Redir = {
    desc = 'Redirect command output to a new scratch buffer',
    complete = 'command',
    nargs = '+',
    callback = function(cmd)
      local parsed = vim.api.nvim_parse_cmd(cmd.args, {})
      ---@diagnostic disable-next-line: param-type-mismatch
      local output = vim.api.nvim_cmd(parsed, { output = true })
      if output == '' then
        return mia.warn('No output from "%s"', cmd.args)
      end

      -- open window
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.w[win].scratch then
          vim.api.nvim_win_close(win, true)
        end
      end
      vim.cmd.vnew()
      vim.w.scratch = 1

      -- stylua: ignore
      vim.iter({
        buftype = 'nofile',
        bufhidden = 'wipe',
        buflisted = false,
        swapfile = false,
      }):each(function(k, v)
        vim.bo[k] = v
      end)

      -- set lines
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, '\n'))
    end,
  },
}

local function on_call(modname)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...)
        return mia[modname][k](...)
      end
    end,
  })
end

-- stylua: ignore
return mia.commands({
  Move = { on_call('file_move').cmd, nargs = '+', complete = 'file', bang = true },
  Delete = impl.Delete,
  Delview = impl.Delview,
  EditFtplugin = impl.EditFtplugin,
  CloseHiddenBuffers = impl.CloseHiddenBuffers,
  Redir = impl.Redir,
  Cclearquickfix = function() vim.fn.setqflist({}) end,
  Lclearloclist = function() vim.fn.setloclist(0, {}) end,
  UpdateMeta = on_call('metagen').write,
  SudoEdit = { on_call('sudo').edit, complete = 'file', nargs = '?' },
  Repl = { on_call('repl').cmd, nargs = '?', complete = 'filetype', bar = true },
  ReplModeLine = { on_call('repl').send_modeline, bar = true },
  Job = { on_call('job').cmd, nargs = 1, bar = true, bang = true },
  -- Session = { on_call('session'), complete = 'file', desc = 'Session management' },
})
