local foldhue = require('foldhue')
local langs = foldhue.langs

local function get_decorators(buf, node)
  if node:type() == 'decorator' then
    node = node:parent()
  end
  if node:type() ~= 'decorated_definition' then
    return nil
  end
  local decorators = {}
  for child in node:iter_children() do
    if child:type() ~= 'decorator' then
      node = child
      break
    end
    decorators[#decorators+1] = vim.treesitter.get_node_text(child, buf, {})
  end
  return table.concat(decorators, ' '), node
end

function langs.python(buf, lnum)
-- function Python(buf, lnum)
  -- local descendant = root:named_descendant_for_range(lnum, 0, lnum, 1)
  -- if it's decorated, get the function_definition
  local node = vim.treesitter.get_node_at_pos(buf, lnum, 0)
  -- local node = vim.treesitter.get_parser(buf):parse()[1]:root():named_descendant_for_range(lnum, 0, lnum, 1)
  local decorators, func = get_decorators(buf, node)
  if decorators then
    node = func
    lnum = node:start()
  end
  local groups = foldhue.from_captures(buf, lnum)

  -- if the parameters are on multiple lines, get those
  -- local func = root:named_descendant_for_range(lnum, 0, lnum, 1)
  if node:type() == "function_definition" then
    local parameters = node:field("parameters")[1]
    local start_row, _, end_row = parameters:range()
    -- local parameter, ln, colstart, colend, _
    if end_row > start_row then
      -- local group_name = "Folded@parameter"
      for child in parameters:iter_children() do

        -- if child:named() then
        --   -- P(child:type(), child:range())
        --   ln, colstart, _, colend = child:range()
        --   parameter = foldhue.from_captures(buf, ln, { range = { colstart+1, colend } })
        --   vim.list_extend(groups, parameter)
        --   groups[#groups+1] = { ", ", "Folded" }
        -- end

        if child:type() == "identifier" then
          local text = vim.treesitter.get_node_text(child, buf)
          groups[#groups+1] = { text, group_name }
          groups[#groups+1] = { ", ", "Folded" }
        end

      end
      groups[#groups][1] = ")"
    end
  end

  groups[#groups+1] = { ' ...', 'Folded' }
  if decorators and #decorators > 0 then
    groups[#groups+1] = { ' ' .. decorators, 'Folded' }
  end
  return groups
end

-- function langs.org(buf, lnum, node)
--   local groups = from_query(buf, lnum, node)
--   -- if property drawer, do something else
--   return groups
-- end

function langs.lua(buf, lnum)
  local groups = foldhue.from_captures(buf, lnum)
  groups[#groups+1] = { ' ... ', 'Folded' }
  local col = #vim.api.nvim_buf_get_lines(buf, lnum, lnum+1, false)[1]
  local node = vim.treesitter.get_node_at_pos(buf, lnum, col)
  vim.list_extend(groups, foldhue.from_captures(buf, node:end_(), {}))
  return groups
end

return langs
