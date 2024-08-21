---@type table<string, fun(ev: aucmd.trigger)>
local M = {}

function M.lua(ev)
  require('mia.reloader').reload_lua_module(ev.file, ev.buf)
end

function M.query(ev)
  local ft, kind = ev.file:match('(%w+)/(%w+)%.scm')
  local n = 0
  local action, msg
  if kind == 'highlights' then
    action = function()
      vim.cmd.TSBufDisable('highlight')
      vim.cmd.TSBufEnable('highlight')
    end
    msg = 'Reloaded %s "%s" buffer%s highlights'
  else
    action = function()
      vim.cmd.mkview()
      vim.cmd.update()
      vim.cmd.edit()
      vim.cmd.loadview()
    end
    msg = 'Reloaded %s "%s" buffer%s'
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == ft then
      n = n + 1
      vim.api.nvim_buf_call(buf, action)
    end
  end
  vim.notify(msg:format(n, ft, n == 1 and '' or 's'))
end

function M.vim(ev)
  vim.cmd.source(ev.file)
end

setmetatable(M, {
  __index = function(_, k)
    -- function to stop lua errors
    return function(ev)
      local msg = ('Unable to source filetype: ".%s"'):format(k)
      if vim.api.nvim_buf_get_name(ev.buf) == ev.file then
        msg = ('Unable to source %s files'):format(vim.bo[ev.buf].filetype)
      end
      vim.api.nvim_echo({ { msg, 'ErrorMsg' } }, true, {})
    end
  end,

  __call = util.restore_opt( --
    { eventignore = { append = { 'SourceCmd' } } },
    function(t, ev)
      local ft = vim.bo[ev.buf].filetype
      if vim.fn.fnamemodify(vim.fn.bufname(ev.buf), ':p') ~= ev.file then
        ft = ev.file:match('%.(%w+)$')
      end

      local s, r = pcall(t[ft], ev)
      if not s then
        vim.schedule(function()
          -- scheduled to avoid error in autocmd, which would stop the autocmd
          error(r, 0)
        end)
      end
    end
  ),
})

return M
