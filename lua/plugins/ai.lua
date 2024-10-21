---@type LazySpec
return {
  'gsuuon/model.nvim',
  -- 'milisims/model.nvim',
  -- dev = true,
  lazy = true,
  cmd = { 'M', 'Model', 'Mchat' },
  init = function()
    vim.filetype.add({ extension = { mchat = 'mchat' } })
  end,
  ft = 'mchat',
  keys = {
    { 'cmd', ':Mdelete<cr>', mode = 'n' },
    { 'cms', ':Mselect<cr>', mode = 'n' },
    { 'cm ', ':Mchat<cr>', mode = 'n' },
  },
  config = function()
    require('model').setup({
      prompts = mia.ai.prompts,
      chats = mia.ai.chats,
      secrets = { OPENAI_API_KEY = mia.secrets.openai },
    })
  end,
}
