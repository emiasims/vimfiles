local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function get_libfile()
  local libfile = vim.fn.expand '~/.zotero/library.json'
  if vim.fn.filereadable('library.json') > 0 then
    libfile = 'library.json'
  end
  return libfile
end

local function open_or_write(entry)
  -- lazy, do this with actions
  local bufn = vim.fn.bufadd(vim.fn.expand '~/org/papers.org')
  vim.fn.bufload(bufn)
  if vim.fn.bufnr() ~= bufn then
    vim.cmd [[edit ~/org/papers.org]]
  end
  local search = vim.fn.search('\\V' .. entry.DOI, 'w')
  if search > 0 then
    vim.fn.search('^\\*', 'b')
    vim.cmd [[normal! zMzo]]
    return
  end

  setmetatable(entry, { __index = function() return '' end })

  local text = { '', '* ' .. entry.title }
  text[#text + 1] = vim.fn.eval [[org#time#dict('[today]').totext()]]
  text[#text + 1] = ':properties:'
  for _, a in ipairs(entry.creators) do
    setmetatable(a, { __index = function() return '' end })
    text[#text + 1] = (':author+: %s %s'):format(a.firstName, a.lastName)
  end
  text[#text + 1] = ':doi: ' .. 'https://doi.org/' .. entry.DOI
  if entry.publicationTitle then
    text[#text + 1] = ':journal: ' .. entry.publicationTitle
  end
  if entry.date then
    text[#text + 1] = ':date: ' .. entry.date
  end
  text[#text + 1] = ':end:'
  text[#text + 1] = '** Abstract'
  text[#text + 1] = ''
  text[#text + 1] = entry.abstractNote
  text[#text + 1] = ''
  text[#text + 1] = '** Notes'
  text[#text + 1] = ''
  vim.api.nvim_buf_set_lines(bufn, -1, -1, false, text)
  vim.schedule(function()
    vim.cmd [[normal! G3kgqlzRGzx]]
  end)

  -- local props = {}
  -- for _, a in ipairs(entry.creators) do
  --   props[#props + 1] = { 'author+', a.firstName .. ' ' .. a.lastName }
  -- end
  -- props[#props + 1] = { 'doi', 'https://doi.org/' .. entry.DOI }
  -- if entry.publicationTitle then
  --   props[#props + 1] = { 'journal', entry.publicationTitle }
  -- end
  -- if entry.date then
  --   props[#props + 1] = { 'date', entry.date }
  -- end

  -- org.Section {
  --   title = entry.title,
  --   plan = org.Timestamp { 'today', inactive = true },
  --   properties = props,
  --   subsections = {
  --     org.Section { title = 'Abstract', body = Paragraph(entry.abstractNote):format() },
  --     org.Section { title = 'Notes' },
  --   }
  -- }:write(bufn, -1)
end

local function get_finder(fname)
  return finders.new_table {
    results = vim.fn.json_decode(io.open(fname):read '*a').items,
    entry_maker = function(entry)
      local name = ''
      if entry.creators and entry.creators[1] then
        name = entry.creators[1].name
        if not name then
          name = ('%s. %s'):format(entry.creators[1].firstName:sub(1, 1), entry.creators[1].lastName)
        end
        if #entry.creators > 1 then
          name = name .. ' et al.'
        end
      end
      -- name, space, title, space, citekey
      name = ('%s%s"%s"%s(%s)'):format(
        name,
        (' '):rep(24 - vim.fn.strdisplaywidth(name)),
        entry.title,
        (' '):rep(164 - vim.fn.strdisplaywidth(entry.title) - vim.fn.strdisplaywidth(entry.citationKey)),
        entry.citationKey
      )
      return {
        value = entry,
        display = name,
        ordinal = name,
        -- ordinal = name .. (entry.abstractNote or ''),
      }
    end,
  }
end

function M.pick(opts)
  local libfile = get_libfile()

  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'colors',
    finder = get_finder(libfile),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        -- TODO https://github.com/nvim-telescope/telescope.nvim/issues/416#issuecomment-841273053
        -- open file with one selection, quickfix list for multiple
        -- open_or_write(action_state.get_selected_entry().value)
        local selections = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
        actions.close(prompt_bufnr)
        if #selections > 1 then
          P(#selections)
          error "Can't do multi selections yet"
        else
          open_or_write(action_state.get_selected_entry().value)
        end
      end)
      return true
    end,
  }):find()
end

function M.cite(opts)
  local libfile = get_libfile()

  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'colors',
    finder = get_finder(libfile),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selections = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
        actions.close(prompt_bufnr)
        local citations = {}
        if #selections > 1 then
          for _, entry in ipairs(selections) do
            citations[#citations + 1] = '@' .. entry.value.citationKey
          end
        else
          citations[1] = '@' .. action_state.get_selected_entry().value.citationKey
        end
        local citekey = ('[cite:%s]'):format(table.concat(citations, ';'))

        vim.schedule(function() vim.api.nvim_put({ citekey }, "c", true, true) vim.fn.feedkeys('a') end)
      end)
      return true
    end,
  }):find()
end

function M.zotero_open()
  local citation = vim.fn.expand('<cword>')
  local libfile = get_libfile()

  local items = vim.fn.json_decode(io.open(libfile):read '*a').items
  for _, item in ipairs(items) do
    if item.citationKey == citation then
      -- select the item in zotero by default
      -- should be: "zotero://select/library/items/" .. item.itemKey
      local action = {
        uri = item.select,
        msg = { { ('No pdf found. Selected "%s" in zotero'):format(citation), 'Todo' } }
      }

      -- if there's a pdf, open it in zotero
      for _, attachment in ipairs(item.attachments or {}) do
        if attachment.title and vim.endswith(attachment.title, 'pdf') then
          -- want to open, not select. Extract itemKey (why isn't that in attachments?)
          action = {
            uri = "zotero://open-pdf/library/items/" .. attachment.select:match('%w+$'),
            msg = { { ('pdf for "%s" opened in Zotero.'):format(citation) } },
          }
          break
        end
      end

      if action then
        vim.fn.jobstart(('xdg-open "%s"'):format(action.uri))
        if action.msg then
          vim.api.nvim_echo(action.msg, true, {})
        end
      end

    end
  end
end

function M.zotero_select()
  local citation = vim.fn.expand('<cword>')
  local libfile = get_libfile()

  local items = vim.fn.json_decode(io.open(libfile):read '*a').items
  for _, item in ipairs(items) do
    if item.citationKey == citation then
      -- select the item in zotero by default
      -- should be: "zotero://select/library/items/" .. item.itemKey
      vim.fn.jobstart(('xdg-open "%s"'):format(item.select))
      vim.api.nvim_echo({ { ('Selected "%s" in zotero'):format(citation) } }, true, {})
    end
  end

end

return M
