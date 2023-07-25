-- for vscode style (nothing too complicated) to snipmate

local function read_json(path)
  local fd = vim.uv.fs_open(path, 'r', 0)
  local text = vim.uv.fs_read(fd, vim.uv.fs_stat(path).size)
  vim.uv.fs_close(fd)
  local snips = {}
  for name, snip in pairs(vim.json.decode(text)) do
    snip.name = name
    snips[#snips+1] = snip
  end
  return snips
end

local function convert(snippet)
  -- body, name, description, prefix

  local text = snippet.body
  if type(text) == 'string' then
    text = { text }
  end
  text = vim.split(table.concat(text, '\n'), '\n')
  text = vim.iter(text):map(function(s) return s == '' and '' or '\t' .. s end):totable()

  table.insert(text, 1, ('snippet %s %s'):format(snippet.prefix, snippet.description or snippet.name))
  return table.concat(text, '\n')
end

local function from_vscode(ft)
  local snipfiles = vim.list_extend(
    nvim.get_runtime_file(('snippets/%s.json'):format(ft), true),
    nvim.get_runtime_file(('snippets/%s/*.json'):format(ft), true)
  )

  local it = vim.iter(snipfiles)
  it:map(read_json)
  it:map(function(snips) return vim.iter.map(convert, snips) end)
  local snips = it:totable()
  for i, path in ipairs(snipfiles) do
    local suffix = path:match(('snippets/%s(/.+)%%.json'):format(ft)) or ''
    local filename = ('%s/snippets/snipmate/%s%s.snippets'):format(vim.fn.stdpath 'config', ft, suffix)
    vim.fn.mkdir(vim.fs.dirname(filename), 'p')
    local fd = vim.uv.fs_open(filename, 'w', 0)
    vim.uv.fs_write(fd, table.concat(snips[i], '\n\n'))
    vim.uv.fs_close(fd)
    vim.uv.fs_chmod(filename, 420)
  end
end

return { import = from_vscode }
