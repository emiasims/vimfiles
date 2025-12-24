local function on_call(modname)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...)
        return mia[modname][k](...)
      end
    end,
  })
end

---@type mia.commands
local M = {
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
      ---@diagnostic disable-next-line: undefined-field
      if cmd.smods.vertical or cmd.smods.horizontal then
        edit = vim.cmd.split
      end
      local ft = cmd.args == '' and vim.bo.filetype or cmd.args
      local files = vim
        .iter(vim.api.nvim_get_runtime_file('**/ftplugin/' .. ft .. '.*', true))
        :map(function(file)
          return {
            path = file,
            text = file
              :gsub('^' .. vim.pesc(vim.env.VIMRUNTIME) .. '/', ' : ')
              :gsub('^' .. vim.pesc(vim.fn.stdpath('config') --[[@as string]]) .. '/', ' : ')
              :gsub('^' .. vim.pesc(vim.env.HOME) .. '/', '~/'),
          }
        end)
        :totable()

      if
        cmd.bang -- user doesn't have a config
        or not vim.iter(files):any(function(item)
          return item.path:find('lua/mia/ftplugin') or item.path:find('after/ftplugin')
        end)
      then
        local suffix = 'ftplugin/' .. ft .. '.lua'
        table.insert(files, 1, {
          path = vim.fn.stdpath('config') .. '/after/' .. suffix,
          text = ' : after/' .. suffix,
        })
        table.insert(files, 2, {
          path = vim.fn.stdpath('config') .. '/lua/mia/' .. suffix,
          text = ' : lua/mia/' .. suffix,
        })
      end

      vim.ui.select(files, {
        prompt = 'Select ftplugin file',
        format_item = function(item)
          return item.text
        end,
      }, function(item)
        if item then
          edit({ item.path, mods = cmd.smods })
          vim.bo.bufhidden = 'wipe'
          vim.bo.buflisted = false
        end
      end)
    end,
  },

  CloseHiddenBuffers = {
    complete = 'command',
    nargs = '*',
    bar = true,
    range = true,
    bang = true,
    callback = function(cmd)
      local closed, modified = 0, 0
      vim.iter(vim.fn.getbufinfo({ buflisted = 1 })):each(function(info)
        modified = modified + ((info.hidden + info.changed == 2) and 1 or 0)
        if (info.hidden == 1 or info.loaded == 0) and (cmd.bang or info.changed == 0) then
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
        mia.warn('No output from "%s"', cmd.args)
        return
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

  Cclearquickfix = function()
    vim.fn.setqflist({})
  end,

  Lclearloclist = function()
    vim.fn.setloclist(0, {})
  end,

  Move = { on_call('file_move').cmd, nargs = '+', complete = 'file', bang = true },
  Repl = { on_call('repl').cmd, nargs = '?', complete = 'filetype', bar = true },
  ReplModeLine = { on_call('repl').send_modeline, bar = true },
}

return mia.commands(M)
