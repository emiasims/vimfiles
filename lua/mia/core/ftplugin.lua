---@class mia.ftplugin
---@field H? table helpers
---@field opts? table<string, any> vim options
---@field keys? mia.keymap[]
---@field ctx? mia.ctx[]

local M = { handler = {} }

M.ftplugins = setmetatable({}, {
  __index = function(_, key)
    local ftp = require('mia.ftplugin')[key]
    if ftp then
      return ftp
    end
    return vim.F.npcall(require, 'mia.ftplugin.' .. key)
  end,
})

local Handler

local function do_handlers(buf, spec, filetype)
  if not spec then
    return
  end
  for name, handler in pairs(Handler) do
    if spec[name] then
      local ok, msg = pcall(handler, buf, spec[name])
      if not ok then
        mia.err('Failed to set %s for %s in buffer %d:\n%s', name, filetype, buf, msg)
      end
    end
  end
end

Handler = {
  opts = function(_, opts)
    for k, v in pairs(opts) do
      vim.opt_local[k] = v
    end
  end,

  var = function(buf, vars)
    for k, v in pairs(vars) do
      vim.b[buf][k] = v
    end
  end,

  keys = function(buf, keys)
    keys = mia.tbl.copy(keys)
    keys.buffer = buf
    mia.keymap(keys)
  end,

  ctxmap = function(buf, spec)
    spec = mia.tbl.copy(spec)
    spec.buffer = buf
    require('ctxmap').keymap.sets(spec)
  end,

  config = function(buf, cfg, filetype)
    do_handlers(buf, cfg(buf), filetype)
  end,
}

function M.do_ftplugin(buf, filetype)
  if not buf or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  filetype = filetype or vim.bo[buf].filetype
  do_handlers(buf, M.ftplugins[filetype], filetype)
end

function _setup()
  vim.api.nvim_create_autocmd('Filetype', {
    callback = function(ev)
      M.do_ftplugin(ev.buf, ev.match)
    end,
  })

  vim.iter(vim.api.nvim_list_bufs()):each(function(buf)
    if vim.b[buf].did_ftplugin == 1 then
      M.do_ftplugin(buf)
    end
  end)
end

function M.setup()
  if vim.fn.has('vim_starting') == 1 then
    vim.api.nvim_create_autocmd('VimEnter', { callback = _setup })
  else
    _setup()
  end
end

return M
