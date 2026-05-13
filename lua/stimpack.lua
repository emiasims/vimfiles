local function errmsg(a1, ...)
  a1 = 'stimpack: ' .. a1
  mia.err(a1, ...)
end

_G.stimpack = {}
function stimpack.add(specs, opts)
  local start = opts and opts.start or false
  if coroutine.running() then
    coroutine.yield({ specs = specs, start = start })
  else
    vim.pack.add(specs, { load = true, confirm = false })
  end
end

local function install(packs)
  if #packs == 0 then
    return
  end
  local specs = vim.iter(packs):map(function(e) return e.specs end):flatten():totable()
  local ok, err = pcall(vim.pack.add, specs, { load = true, confirm = false })
  if not ok then
    errmsg('%s', err)
  end

  local success
  vim.iter(packs):filter(function(p) return coroutine.status(p.co) ~= 'dead' end):each(function(p)
    ok, success, err = pcall(coroutine.resume, p.co)
    if not ok then
      errmsg('error resuming packs.%s: %s', p.name, success or err)
    end
  end)
end

local packs = vim
  .iter(vim.api.nvim_get_runtime_file('stimpack/*.lua', true))
  :map(function(f)
    return {
      path = f,
      name = f:match('^stimpack/([^/]*)%.lua$'),
      co = coroutine.create(function()
        local fn, err = loadfile(f)
        if not fn then
          error(err)
        end
        fn()
      end),
    }
  end)
  :map(function(p)
    local ok, success, yield = pcall(coroutine.resume, p.co)
    if not (ok and success) then
      errmsg('error in packs.%s: %s', p.name, success or yield)
      return
    elseif yield then
      return { start = yield.start, specs = yield.specs, path = p.path, name = p.name, co = p.co }
    end
  end)
  :fold({ now = {}, later = {} }, function(t, p)
    table.insert(t[p.start and 'now' or 'later'], p)
    return t
  end)

install(packs.now)

vim.api.nvim_create_autocmd('UIEnter', {
  callback = vim.schedule_wrap(function() install(packs.later) end),
})
