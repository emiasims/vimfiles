M = {}

function M.file(filepath)
  ---@diagnostic disable: need-check-nil
  local cache = {}
  local cache_mtime = { sec = 0, nsec = 0 }

  if not filepath:match('/') then
    filepath = vim.fn.stdpath('state') .. '/mia/cache/' .. filepath
  end
  if not vim.endswith(filepath, '.json') then
    filepath = filepath .. '.json'
  end

  if vim.fn.filereadable(filepath) == 0 then
    vim.fn.mkdir(vim.fs.dirname(filepath), 'p')
    vim.fn.writefile({ '{}' }, filepath)
  end

  local function read_cache()
    local stat = vim.uv.fs_stat(filepath)
    if cache_mtime.sec == stat.mtime.sec and cache_mtime.nsec == stat.mtime.nsec then
      return
    end
    local file = io.open(filepath, 'r')
    cache = vim.json.decode(file:read('*a'))
    file:close()
    cache_mtime = stat.mtime
  end

  local function write_cache()
    local file = io.open(filepath, 'w')
    file:write(vim.json.encode(cache))
    file:close()
    local stat = vim.uv.fs_stat(filepath)
    cache_mtime = stat.mtime
  end

  return setmetatable({}, {
    __index = function(_, key)
      read_cache()
      return cache[key]
    end,
    __newindex = function(_, key, value)
      read_cache()
      cache[key] = value
      write_cache()
    end,
    __len = function(_)
      read_cache()
      local count = 0
      for _ in pairs(cache) do
        count = count + 1
      end
      return count
    end,
  })
end

return M
