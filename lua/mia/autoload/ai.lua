local adapters = require('codecompanion.adapters')
local client = require('codecompanion.http')
local config = require('codecompanion.config')
local log = require('codecompanion.utils.log')

local M = {}
M.roles = {
  system = config.constants.SYSTEM_ROLE,
  user = config.constants.USER_ROLE,
  assistant = config.constants.LLM_ROLE,
}

---@module 'plenary.job'

---@alias mia.ai.messages { role: string, content: string, hide?: boolean }[]

---@param opts string|{ adapter: string?, query?: string, messages?: mia.ai.messages, sync: boolean? }
function M.ask(opts)
  local messages
  if type(opts) == 'string' then
    messages = { { role = M.roles.user, content = opts } }
  elseif opts.query then
    messages = { { role = M.roles.user, content = opts.query } }
  elseif opts.messages then
    messages = opts.messages
  else
    error('Invalid query')
  end

  local adapter = adapters.resolve(config.adapters[opts.adapter or 'gemini'])
  local response = {}
  local job
  ---@diagnostic disable-next-line: param-type-mismatch
  job = client.new({ adapter = adapter:map_schema_to_params() }):request(adapter:map_roles(messages), {
    ---@param err string
    ---@param data table
    callback = function(err, data)
      if err then
        return log:error(err)
      end

      if data then
        local result = adapter.handlers.chat_output(adapter, data)
        if result and result.output and result.output.content then
          local content = result.output.content:gsub('’', "'")
          table.insert(response, content)
        end
      end
    end,
    done = function()
      job.response = table.concat(response)
    end,
  })
  job.response = response

  if opts.sync then
    job:join()
  end
  return job
end

---@param opts { buf: number, adapter: string?, messages: mia.ai.messages }
---@return Job job Plenary job
function M.to_buf(opts)
  assert(opts.buf)
  local bufnr = opts.buf
  local adapter = adapters.resolve(config.adapters[opts.adapter or 'gemini'])
  local messages = opts.messages

  -- lock buffer
  vim.bo[bufnr].modifiable = false

  return client.new({ adapter = adapter:map_schema_to_params() }):request(adapter:map_roles(messages), {
    ---@param err string
    ---@param data table
    callback = function(err, data)
      if err then
        return log:error(err)
      end

      if data then
        local result = adapter.handlers.chat_output(adapter, data)
        if result and result.output and result.output.content then
          local content = result.output.content:gsub('’', "'")
          vim.bo[bufnr].modifiable = true
          vim.api.nvim_buf_set_text(bufnr, -1, -1, -1, -1, vim.split(content, '\n'))
          local win = vim.fn.bufwinid(bufnr)
          if win ~= -1 then
            vim.api.nvim_win_set_cursor(win, { vim.fn.line('$'), 0 })
          end
          vim.bo[bufnr].modifiable = false
        end
      end
    end,
    done = function()
      vim.bo[bufnr].modifiable = true
    end,
  })
end

local function setup()
  local requests = {}
  vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = 'CodeCompanionRequest*',
    group = vim.api.nvim_create_augroup('mia-ai-spin', { clear = true }),
    callback = function(ev)
      local eid = ev.data.id
      if ev.match == 'CodeCompanionRequestStarted' then
        requests[eid] = mia.spinner.add(function()
          return requests[eid] == nil
        end)
      elseif ev.match == 'CodeCompanionRequestFinished' then
        requests[eid] = nil
      end
    end,
  })
end
setup()

return M
