local M = {}

local DIR = vim.env['HOME'] .. '/job'
local Roles = mia.ai.roles

local curl = require('plenary.curl')
function M.fetch(url)
  local web = curl.get(url, { sync = true })
  if web.status ~= 200 then
    error('Failed to fetch the webpage: ' .. web.status)
  end
  return web.body
end

function M.write_job_info(buf, body)
  return mia.ai.to_buf({
    adapter = 'flash',
    buf = buf,
    messages = {
      {
        role = Roles.system,
        content = [[
You need to parse the content of this webpage that has a job description, and extract the following:
- Job title
- Organization name
- Location (city, state, building)
- Compensation (including salary, benefits, etc.)
- Full position description

You must return the extracted information in markdown format with the following skeleton:
```
*Position*: {job title}
*Organization*: {organization name}
*Location*: {location}
*Compensation*: {compensation}

# Description

{reformatted description in markdown}

# Resume

# Cover

## Suggestions

## -Letter

```
Notes:
- Replace the placeholders (curly braces) with the extracted information.
- Do not reply with any other information.
- If you cannot extract any of the information, do not include it
- You MUST return the information in this markdown format
- The description MUST be reformatted, using markdown bold, italics, and bullet points as needed.
- Prefer a dash `-` for bullet points
- DO NOT wrap any output in backticks
      ]],
      },
      {
        role = Roles.user,
        content = ('Parse:\n```html\n%s\n```'):format(body),
      },
    },
    done = function()
      vim.api.nvim_buf_call(buf, function()
        vim.cmd.g({ '/^```\\a*$/d', mods = { emsg_silent = true } })
        vim.cmd.write({ mods = { emsg_silent = true } })
      end)
    end,
  })
end

function M.set_filename(buf)
  local job = mia.ai.ask({
    adapter = 'flash',
    messages = {
      {
        role = Roles.system,
        content = table.concat({
          'You will be given info about a job and organization.',
          'Respond with ONLY a filename: `{short_organization_name}/{short_job_title}.md`',
          'Notes:',
          '- There must be no spaces',
          '- The shortened org name should be less than 15 characters, but it is okay to be longer if you must',
          '- The shortened job title should be less than 20 characters, but it is okay to be longer if you must',
          '- Abbreviate as nessesary where it makes sense',
          '- Underscores are acceptable',
        }, '\n'),
      },
      {
        role = Roles.user,
        content = table.concat({
          '*URL*: https://some.thing/here',
          '*Position*: Supervisor Bioinformatics Scientist - Genomic Diagnostic Laboratory',
          "*Organization*: The Children's Hospital of Philadelphia",
          '*Location*: Philadelphia, PA, Abramson Building',
        }, '\n'),
      },
      {
        role = Roles.assistant,
        content = 'CHOP/SrBioinformatics.md',
      },
      {
        role = Roles.user,
        content = table.concat({
          '*URL*: https://some.other.thing/here',
          '*Position*: Bioinformatician (open rank, I-IV)',
          '*Organization*: University of Massachusetts Chan Medical School',
        }, '\n'),
      },
      {
        role = Roles.assistant,
        content = 'UMChanMed/bioinformatician.md',
      },
      {
        role = Roles.user,
        content = table.concat(
          vim.api.nvim_buf_get_lines(buf, 2, vim.api.nvim_buf_call(buf, function()
            return vim.fn.search('^# Description', 'nw')
          end) - 2, false),
          '\n'
        ),
      },
    },
  })

  job:after_success(function(j)
    vim.schedule(function()
      vim.api.nvim_buf_call(buf, function()
        local filename = vim.fn.fnameescape(vim.trim(j.response))
        vim.cmd.file(vim.fs.joinpath(DIR, filename))
        vim.cmd.write({ bang = true })
        vim.cmd.FixAutochdir()
      end)
    end)
  end)
  return job
end

function M.start_resume_chat()
  ---@type CodeCompanion.Chat
  local chat = assert(require('codecompanion').chat({ fargs = { 'pro' } }))

  local ws = require('codecompanion.strategies.chat.slash_commands.workspace').new({
    Chat = chat,
    config = {},
    context = {},
    opts = {},
  })

  vim.api.nvim_set_current_buf(chat.bufnr)
  ws.workspace = ws:read_workspace_file(vim.fs.joinpath(DIR, 'codecompanion-workspace.json'))
  ws:output('Resume')

  mia.reveal.text('#buffer\n\nTailor a resume for this position.\n', { pos = { -1, -1 } })

  return vim.iter(vim.api.nvim_buf_get_keymap(chat.bufnr, 'n')):find(function(map)
    return map.desc == 'Send'
  end).callback
end

local function wait(condition, interval, timeout)
  timeout, interval = timeout or 10000, interval or 50
  vim.wait(timeout, function()
    vim.cmd.redraw({ bang = true })
    return condition()
  end, interval, false)
end

function M.new(url, body)
  vim.cmd.tabnew()
  local buf = vim.fn.bufnr()
  vim.bo[buf].filetype = 'markdown'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    '# Info',
    '',
    '*URL*: ' .. url,
    '',
  })
  if not body then
    body = M.fetch(url)
  end

  local desc_job = M.write_job_info(buf, body)

  wait(function()
    return vim.fn.search('^# Description', 'nw') > 0
  end)

  M.set_filename(buf)

  wait(function()
    return vim.fn.bufname(buf) ~= ''
  end)

  local send = M.start_resume_chat()
  desc_job:after_success(vim.schedule_wrap(send))
end

M.cmd = function(args)
  M.new(args.args, args.bang and mia.put('+'))
end

return M
