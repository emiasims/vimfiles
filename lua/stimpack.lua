local function errmsg(ok, a1, ...)
  if ok then
    return
  end
  local msg = ('stimpack: ' .. a1):format(...)
  vim.notify(msg, vim.log.levels.ERROR)
end

local function resolve(spec)
  if type(spec) == 'string' and not spec:find '://' and not spec:find '^/' then
    return 'https://github.com/' .. spec
  elseif type(spec) == 'table' and spec.src and not spec.src:find '://' and not spec.src:find '^/' then
    return vim.tbl_extend('force', spec, { src = 'https://github.com/' .. spec.src })
  end
  return spec
end

-- must match how vim.pack derives names, or manifest keys won't line up
-- with vim.pack.get()
local function spec_name(spec)
  local src = type(spec) == 'table' and (spec.name or spec.src) or spec
  return (src:match('[^/]+$'):gsub('%.git$', ''))
end

_G.stimpack = {}
function stimpack.add(specs, opts)
  local start = opts and opts.start or false
  local resolved = vim.tbl_map(resolve, specs)
  if coroutine.running() then
    coroutine.yield({ specs = resolved, start = start })
  else
    vim.pack.add(resolved, { load = true, confirm = false })
  end
end

local function install(packs)
  if #packs == 0 then
    return
  end
  local specs = vim.iter(packs):map(function(e) return e.specs end):flatten():totable()
  local ok, err = pcall(vim.pack.add, specs, { load = true, confirm = false })
  errmsg(ok, err)

  local success
  vim.iter(packs):filter(function(p) return coroutine.status(p.co) ~= 'dead' end):each(function(p)
    ok, success, err = pcall(coroutine.resume, p.co)
    errmsg(ok, 'error resuming packs.%s: %s', p.name, success or err)
  end)
end

local packs = vim
  .iter(vim.api.nvim_get_runtime_file('stimpack/*.lua', true))
  :map(function(f)
    return {
      path = f,
      -- unanchored: nvim_get_runtime_file returns absolute paths
      name = f:match('stimpack/([^/]*)%.lua$'),
      co = coroutine.create(function()
        local fn, err = loadfile(f)
        errmsg(fn, err)
        local ok, _err = pcall(fn --[[@as function]])
        errmsg(ok, _err)
      end),
    }
  end)
  :map(function(p)
    local ok, success, yield = pcall(coroutine.resume, p.co)
    errmsg(ok and success, 'error in packs.%s: %s', p.name, success or yield)
    if ok and success and yield then
      return { start = yield.start, specs = yield.specs, path = p.path, name = p.name, co = p.co }
    end
  end)
  :fold({ start = {}, after_draw = {} }, function(t, p)
    table.insert(t[p.start and 'start' or 'after_draw'], p)
    return t
  end)

local manifest = {}
for _, phase in ipairs({ 'start', 'after_draw' }) do
  for _, p in ipairs(packs[phase]) do
    for _, spec in ipairs(p.specs) do
      manifest[spec_name(spec)] = { path = p.path, start = phase == 'start' }
    end
  end
end

function stimpack.manifest()
  return manifest
end

-- UIEnter never fires in a headless nvim, so out-of-process tooling
-- (stimpack_ui's update child) needs a way to load the deferred packs
local flushed = false
function stimpack.flush()
  if flushed then return end
  flushed = true
  install(packs.after_draw)
end

install(packs.start)

vim.api.nvim_create_autocmd('UIEnter', {
  callback = vim.schedule_wrap(stimpack.flush),
})
