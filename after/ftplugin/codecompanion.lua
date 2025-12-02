local this_buf = vim.api.nvim_get_current_buf()
--- @param info mia.bufinfo
--- @return mia.bufinfo
vim.b.update_bufinfo = function(info)
  ---@type CodeCompanion.Chat
  local chat = require('codecompanion').buf_get_chat(this_buf)
  local status = ''
  if chat.status and chat.status ~= '' then
    status = ':' .. chat.status
  end
  return {
    type = 'codecompanion',
    name = (chat.title or chat.adapter.formatted_name) .. status,
    desc = ('[Chat]%s'):format(chat.adapter.model.name),
    tab_name = chat.title or ('[' .. chat.adapter.formatted_name .. ']'),
  }
end

vim.wo.conceallevel = 0
