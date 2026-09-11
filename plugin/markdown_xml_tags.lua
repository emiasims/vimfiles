local M = {}

--- @param _ any
--- @param handler fun(err: any, result: any)
M.initialize = function(_, handler)
  handler(nil, {
    capabilities = {
      semanticTokensProvider = {
        legend = { tokenTypes = { 'tag' }, tokenModifiers = {} },
        full = true,
      },
    },
  })
  return true, 1
end

--- @param params { textDocument: { uri: string } }
--- @param handler fun(err: any, result: { data: integer[] })
M['textDocument/semanticTokens/full'] = function(params, handler)
  local bufnr = vim.uri_to_bufnr(params.textDocument.uri)

  if not vim.api.nvim_buf_is_valid(bufnr) then
    handler(nil, { data = {} })
    return true, 1
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local tokens = {}
  local prev_row, prev_col = 0, 0

  -- semantic tokens are delta-encoded against the previous token
  local function add_hl(row, col, len)
    local drow = row - prev_row
    local dcol = drow == 0 and col - prev_col or col
    vim.list_extend(tokens, { drow, dcol, len, 0, 0 })
    prev_row, prev_col = row, col
  end

  local function find_tag(line, ...) return line:find('</?[^>]+>', ...) end

  for i, line in ipairs(lines) do
    local row = i - 1
    local init = 1
    local s, e = find_tag(line, init)
    while s do
      if line:sub(s, s + 3) == '<!--' then
        -- jump past the whole comment so tag-like text inside it is ignored
        local close = line:find('-->', s + 4, true)
        init = close and close + 3 or e + 1
      else
        add_hl(row, s - 1, e - s + 1)
        init = e + 1
      end
      s, e = find_tag(line, init)
    end
  end

  handler(nil, { data = tokens })
  return true, 1
end

--- @param bufnr integer
local function attach_xml_highlighter(bufnr)
  local id = vim.lsp.start({
    name = 'markdown_tags_lsp',
    root_dir = vim.fn.getcwd(),
    cmd = function(_)
      return {
        request = function(method, params, handler)
          if M[method] then
            return M[method](params, handler)
          end
          handler(nil, {})
          return true, 1
        end,
        notify = function() end,
        is_closing = function() return false end,
        terminate = function() end,
      }
    end,
  })

  if id then
    vim.lsp.buf_attach_client(bufnr, id)
  end
end

vim.api.nvim_set_hl(0, '@lsp.type.tag', { link = 'Tag' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args) attach_xml_highlighter(args.buf) end,
})
