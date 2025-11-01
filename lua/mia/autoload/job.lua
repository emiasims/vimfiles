local M = {
  -- this is a langflow webhook.
  webhook_url = 'http://localhost:7860/api/v1/webhook/23cab40f-4cbb-4d54-aa82-32b36d1a46d1',
}

local curl = require('plenary.curl')

function M.fetch(url)
  local web = curl.get(url, { sync = true })
  if web.status ~= 200 then
    error('Failed to fetch the webpage: ' .. web.status)
  end
  return web.body
end

function M.do_webhook(url, content)
  curl.post(M.webhook_url, {
    headers = {
      ['Content-Type'] = 'application/json',
    },
    body = vim.fn.json_encode({
      url = url,
      title = '',
      content = vim.base64.encode(content),
      user = '',
    }),
    sync = false,
  })
  mia.info('Sent to webhook.')
end

function M.send_request(args)
  local url, content
  if args:match('^https?://') then
    url = args
    content = M.fetch(url)
  end
  M.do_webhook(url, content)
  local done = false
  mia.spinner.add(function()
    return done
  end)
  local watcher = assert(vim.uv.new_fs_event())
  local path = vim.fs.abspath(('~/job/%s'):format(vim.fn.strftime('%Y.%m-%V')))
  watcher:start(path, {}, function(err, filename, status)
    done = true
    watcher:stop()
    watcher:close()
    if not err then
      mia.info('Job created: %s', filename)
      vim.schedule(function()
        vim.cmd.tabedit(vim.fs.joinpath(path, filename))
      end)
    else
      mia.err('Error watching file: ' .. err)
    end
  end)
end

M.cmd = function(args)
  M.send_request(args.args)
end

---@param args cmd.callback.arg
M.start = function(args)
  local content = args and args.args
  if not content or content == '' then
    vim.ui.input({ prompt = 'Enter URL or paste web content: ' }, function(input)
      if not input or input == '' then
        mia.warn('No URL provided.')
        return
      end
      M.send_request(input)
    end)
  end
  M.send_request(args.args)
end

M.refresh = function()
  local src = vim.fn.expand('%')
  if vim.fn.getcwd() ~= vim.fs.abspath('~/job') or not src:match('^%d%d%d%d%.%d%d%-%d%d/.*%.md') then
    mia.warn('File %s does not appear to be a job output file.', src)
    return
  end
  local date = os.date('%Y.%m-%V') --[[@as string]]
  if vim.startswith(src, date .. '/') then
    return mia.info('File is already up to date.')
  end

  vim.fn.mkdir(date, 'p')
  vim.cmd.Move(date .. '/')
end

return M
