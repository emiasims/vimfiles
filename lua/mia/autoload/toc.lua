local ts = vim.treesitter

---@class ToCOpts
---@field id integer
---@field node TSNode
---@field metadata vim.treesitter.query.TSMetadata
---@field match TSQueryMatch
---@field bufnr integer
---@field parser vim.treesitter.LanguageTree
---@field query vim.treesitter.Query

---@class ToCHeading
---@field bufnr integer
---@field lnum integer
---@field text string Description
---@field end_lnum? integer
---@field type? string Single character
---@field module? string Defaults to the capture ID or metadata.module

---@alias ToCProcessor fun(_: TSNode, _: ToCHeading): ToCHeading?

---@type table<string, ToCProcessor>
local processor = {}

---@param bufnr integer
---@param id integer
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param query vim.treesitter.Query
---@return ToCHeading
local function preprocess(bufnr, id, node, metadata, query)
  local r, c, er, ec = node:range()
  return {
    lnum = r + 1,
    col = c + 1,
    end_lnum = er + 1,
    end_col = ec + 1,
    text = ts.get_node_text(node, bufnr, { metadata = metadata }), -- range
    module = metadata.module or query.captures[id],
    bufnr = bufnr,
    pattern = '', -- required to display info
  }
end

function processor.vimdoc(node, heading)
  local capture = heading.module
  local text = heading.text
  local row, col = node:start()
  -- only column_headings at col 1 are headings, otherwise it's code examples
  local is_code = (capture == 'h4' and col > 0)
  -- ignore tabular material
  local is_table = (capture == 'h4' and (text:find('\t') or text:find('  ')))
  -- ignore tag-only headings
  local is_tag = node:child_count() == 1 and node:child(0):type() == 'tag'
  if not (is_code or is_table or is_tag) then
    return {
      lnum = row + 1,
      text = (capture == 'h3' or capture == 'h4') and '  ' .. text or text,
    }
  end
end

local function get_toc(bufnr, lang)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local parser = ts.get_parser(bufnr, lang)
  local query = ts.query.get(parser:lang(), 'toc')
  local root = parser:parse()[1]:root()

  local headings = {}

  if not query then
    return headings
  end

  local process = processor[parser:lang()]

  local heading
  for id, node, md in query:iter_captures(root, bufnr) do
    heading = preprocess(bufnr, id, node, md[id] or {}, query)
    if process then
      heading = process(node, heading)
    end
    if heading then
      table.insert(headings, heading)
    end
  end

  return headings
end

local function show_toc()
  local parser = vim.treesitter.get_parser()
  local _, query = pcall(vim.treesitter.query.get, parser:lang(), 'toc')

  if parser and query then
    local name = vim.fn.bufname()
    local toc = get_toc()
    vim.fn.setloclist(0, toc, ' ')
    vim.cmd.lopen()
    vim.w.quickfix_title = 'Table of Contents: ' .. name
  elseif parser then
    mia.warn("No toc query found for '%s'", parser:lang())
  else
    mia.warn('No parser found for filetype ' .. vim.treesitter.language.get_lang(vim.bo.filetype))
  end
end

return {
  get = get_toc,
  show = show_toc,
}
