---@class mia.ftplugin
---@field H? table helpers
---@field opts? table<string, any> vim options
---@field keys? mia.keymap[]
---@field ctx? mia.ctx[]

local M = { handler = {} }

M.ftplugins = setmetatable({}, {
  __index = function(_, key)
    return vim.F.npcall(require, 'mia.ftplugin.' .. key)
  end,
})

local Handler = {
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
}

M.handler = vim
  .iter(Handler)
  :map(function(name, handler)
    return name,
      function(buf, val)
        if not val then
          buf, val = 0, buf
        end
        handler(buf, val)
      end
  end)
  :fold({}, rawset)

function M.do_ftplugin(buf, filetype)
  buf = buf or vim.api.nvim_get_current_buf()
  filetype = filetype or vim.bo[buf].filetype
  local ftp = M.ftplugins[filetype] or {}
  for name, handler in pairs(Handler) do
    if ftp[name] then
      local ok, msg = pcall(handler, buf, ftp[name])
      if not ok then
        mia.err('Failed to set %s for %s in buffer %d:\n%s', name, filetype, buf, msg)
      end
    end
  end
end

function M.setup()
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

return M
