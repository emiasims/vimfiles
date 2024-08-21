local M = {}

function M.load(name)
  local reqname = M.prefix .. '.' .. name
  local ok, mod = pcall(require, reqname)

  M.loaded[name] = ok and true
  if not ok then
    M.log[name] = M.log[name] or { load = {}, setup = {} }
    table.insert(M.log.load[name], { name = reqname, message = mod, time = os.date() })
  elseif mod.setup then
    ok, mod = pcall(mod.setup)
    -- if not ok then
    --   M.log.setup[name] = mod
    -- end
  end
end

function M.setup(path)
  M.prefix = path:gsub('/', '.')
  M.loaded = {}
  M.log = { load = {}, setup = {} }

  local files = vim.api.nvim_get_runtime_file('*/' .. path .. '/*.lua', true)
  for _, file in ipairs(files) do
    local name = file:match(M.prefix:gsub('%.', '%.') .. '/+([^/]+)%.lua$')
    if name ~= 'init' then
      M.load(name:gsub('/', '.'))
    end
  end

  return M
end

return setmetatable(M, {
  __index = function(_, k)
    local mod = package.loaded['mia.plugin.' .. k]
    -- if mod.setup then
    --   -- insert log stuff
    --   mod.setup()
    -- end
    return mod
  end,
})
