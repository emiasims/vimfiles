local list = {}
-- if org#listitem#has_ordered_bullet(getline('.'))|call org#list#reorder()|endif

function list.reorder()
  -- get list
  local list_node = require('mia.tslib').node_at_curpos()
  while list_node:parent() ~= nil and list_node:type() ~= 'list' do
    list_node = list_node:parent()
  end
  if list_node:type() ~= 'list' then
    return
  end

  -- get node type
  -- Get range of bullet: list -> listitem -> bullet
  local ls = list_node:named_child(0):named_child(0):range()
  local bullet = vim.api.nvim_buf_get_lines(0, ls, ls + 1, 0)[1]
  local start, is_text
  if bullet:match '^%s*%d+' then
    is_text = false
    start = 1
  elseif bullet:match '^%s*%l+' then
    is_text = true
    start = string.byte 'a'
    -- note: string.byte('a') for counter sets
  elseif bullet:match '^%s*%u+' then
    is_text = true
    start = string.byte 'A'
  else -- unordered
    return
  end

  local ls, cs, le, ce, replacement, item_node
  -- for item_node in list_node:iter_children() do
  for i = start, start + list_node:named_child_count() - 1 do
    item_node = list_node:named_child(i - start)
    ls, cs, le, ce = item_node:named_child(0):range()
    replacement = is_text and string.byte(i) or tostring(i)
    vim.api.nvim_buf_set_text(0, ls, cs, le, ce - 1, { replacement })
  end
end

return list
