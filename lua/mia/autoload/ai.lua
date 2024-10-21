local openai = require('model.providers.openai')
local segment = require('model.util.segment')

local M = {}
-- select, type system message, go. i.e. "to spanish"

M.prompts = {
  code = {
    provider = openai,
    builder = function(input)
      return {
        messages = {
          {
            role = 'system',
            content = 'You are a 10x super elite programmer. Continue only with code. Do not write tests, examples, or output of code unless explicitly asked for.',
          },
          {
            role = 'user',
            content = input,
          },
        },
      }
    end,
  },
}

local input_if_selection = function(input, context)
  return context.selection and input or ''
end

local run_sys = function(messages, config)
  if config.system then
    table.insert(messages, 1, {
      role = 'system',
      content = config.system,
    })
  end

  return { messages = messages }
end

M.chats = {
  gpt4o = {
    provider = openai,
    params = { model = 'gpt-4o' },
    create = input_if_selection,
    run = run_sys,
  },
  ['gpt4o-mini'] = {
    provider = openai,
    params = { model = 'gpt-4o-mini' },
    create = input_if_selection,
    run = run_sys,
  },
}

return M
