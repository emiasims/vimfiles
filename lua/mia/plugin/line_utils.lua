local M = {}

local modecolors = {
  n = { hl = 'stlNormalMode', abbrev = 'n' },
  i = { hl = 'stlInsertMode', abbrev = 'i' },
  v = { hl = 'stlVisualMode', abbrev = 'v' },
  V = { hl = 'stlVisualMode', abbrev = 'V' },
  [''] = { hl = 'stlVisualMode', abbrev = 'B' },
  R = { hl = 'stlReplaceMode', abbrev = 'R' },
  s = { hl = 'stlSelectMode', abbrev = 's' },
  S = { hl = 'stlSelectMode', abbrev = 'S' },
  [''] = { hl = 'stlSelectMode', abbrev = 'S' },
  c = { hl = 'stlTerminalMode', abbrev = 'c' },
  t = { hl = 'stlTerminalMode', abbrev = 't' },
  ['-'] = { hl = 'stlNormalMode', abbrev = '-' },
  ['!'] = { hl = 'stlNormalMode', abbrev = '!' },
}

function M.mode_info()
  return modecolors[vim.api.nvim_get_mode().mode:sub(1, 1)] or { hl = 'stlNormalMode', abbrev = '-' }
end

function hl(group, text)
  if not text then
    return '%#' .. group .. '#'
  end
  return ('%%#%s#%s%%*'):format(group, text or '')
end

vim.o.mousemoveevent = true
local pos
function mousepos()
  if not vim.in_fast_event() then
    pos = vim.fn.getmousepos()
  end
  return pos or {}
end

--- assumes laststatus=3
function mouse_on_line(name)
  if name == 'statusline' then
    return mousepos().screenrow == vim.o.lines - vim.o.cmdheight
  elseif name == 'tabline' then
    return mousepos().screenrow == 1
  end
end

--- @param spec mia.line.spec|mia.line.spec[]|nil
--- @return mia.line.flat_spec[]
local function _flatten(spec)
  if spec == nil then
    return {}
  end
  if type(spec) == 'function' then
    return _flatten(spec())
  end

  if type(spec) == 'string' or type(spec) == 'number' then
    return { { tostring(spec) } }
  end

  local flat_children = {}
  for _, child in ipairs(spec) do
    vim.list_extend(flat_children, _flatten(child))
  end

  if #flat_children == 0 then
    return {}
  end

  -- If the result is just one text node, merge attributes into it directly
  -- to avoid verbose wrappers (e.g. { ' n ', hl = 'Normal' })
  if #flat_children == 1 and type(flat_children[1][1]) == 'string' then
    local node = flat_children[1]
    if spec.pad then
      node[1] = ' ' .. node[1] .. ' '
    end
    node.hl = node.hl or spec.hl
    node.on_click = node.on_click or spec.on_click
    return { node }
  end

  -- If we have multiple children, wrap them in highlight tokens
  local res = {}

  if spec.pad then
    table.insert(res, { ' ' })
  end

  for i, child in ipairs(flat_children) do
    child.hl = child.hl or spec.hl
    table.insert(res, child)
    if spec.sep and i < #flat_children then
      table.insert(res, { spec.sep })
    end
  end

  if spec.pad then
    table.insert(res, { ' ' })
  end

  return res
end

--- @param spec mia.line.flat_spec[]
local function _resolve(spec)
  return vim
    .iter(spec)
    :map(function(t)
      return t.hl and hl(t.hl, t[1]) or t[1]
    end)
    :join()
end

local function _add_hover_hls(name, flat_spec)
  -- Build clickable regions
  local hover_spec = vim.deepcopy(flat_spec)
  for i, item in ipairs(hover_spec) do
    if item.on_click then
      item.hl = 'Clickable' .. i
      if vim.fn.hlexists(item.hl) ~= 1 then
        vim.api.nvim_set_hl(0, item.hl, { bold = true })
      end
    end
  end

  local click_stl = _resolve(hover_spec)

  local stl_spec = vim.api.nvim_eval_statusline(click_stl, {
    use_tabline = (name == 'tabline'),
    highlights = true,
  })
  local hls = stl_spec.highlights

  local mouse_col = mousepos().screencol
  local mouse_byte = vim.str_byteindex(stl_spec.str, 'utf-16', mouse_col, false)

  for i = 2, #hls do
    hls[i - 1].xend = hls[i].start
  end
  hls[#hls].xend = stl_spec.width

  -- find the smallest region that contains mouse_byte and is clickable
  --- @type integer?
  local hover_ix
  for _, grp in ipairs(hls) do
    local click_ix = grp.group:match('^Clickable(%d+)$')
    if click_ix and mouse_byte >= grp.start and mouse_byte < grp.xend then
      hover_ix = tonumber(click_ix) --[[@as integer]]
    end
    if grp.start > mouse_byte then
      break
    end
  end

  if hover_ix then
    local hover = flat_spec[hover_ix] --[[@as mia.line.flat_spec]]
    hover.hl = 'stlHover'
    hover[1] = '%3@v:lua.mia.line_utils._click@' .. hover[1] .. '%X'
    M._click = hover.on_click
  end
end

--- @class mia.line.flat_spec
--- @field [1] string
--- @field hl? string  Highlight group name
--- @field on_click? function Mouse click handler
--- @field hl_hover? string Highlight group name for hover state

--- @class mia.line.spec
--- @field [number] string|mia.line.spec|mia.line.spec[]|fun(): string|mia.line.spec|mia.line.spec[]?  Text to display
--- @field hl? string|fun(): string  Highlight group name
--- @field pad? boolean If true, pad text with spaces on both sides
--- @field sep? string Separator to use for nested specs
--- @field on_click? fun(nclicks: integer, button: 'l'|'r'|'m'|string) Mouse click handler if any

--- @param name string
--- @param spec mia.line.spec[]
--- @return string
function M.resolve(name, spec)
  local flat_spec = _flatten(vim.deepcopy(spec))

  if mouse_on_line(name) then
    _add_hover_hls(name, flat_spec)
  end

  -- Resolve final flat spec
  return _resolve(flat_spec)
end

M.flatten = _flatten

return M
