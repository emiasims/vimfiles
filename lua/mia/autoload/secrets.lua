return setmetatable({}, {
  __index = function(_, key)
    if vim.env[key] then
      return vim.env[key]
    end

    local sfx = #(vim.env.NVIM_APPNAME or 'nvim') + 2

    local fname = vim.fn.stdpath('config') --[[@as string]]
    fname = ('%s/secrets/%s.key'):format(fname:sub(1, -sfx), key)
    if vim.fn.filereadable(fname) == 1 then
      local ok, dat = pcall(util.fread, fname)
      return ok and dat or nil
    end
  end,
})
