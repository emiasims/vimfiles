local api = vim.api

local function attach(winid)
  winid = winid or api.nvim_get_current_win()
  if not (winid and api.nvim_win_is_valid(winid)) then
    return
  end
  local buf = api.nvim_win_get_buf(winid)
  if not buf then
    return
  end
  local type = vim.bo[buf].buftype == 'terminal' and 'termbar' or 'winbar'
  vim.wo[winid].winbar = '%!v:lua.' .. type .. '()'
  vim.b[buf].winbar_attached = true
end

local bt_allowed = { [''] = true, ['terminal'] = true }
local function au_attach(ev)
  vim.wo.winbar = ''
  if
    not api.nvim_win_get_config(0).zindex -- Not a floating window
    and bt_allowed[vim.bo[ev.buf].buftype]
    and api.nvim_buf_get_name(ev.buf) ~= '' -- Has a file name
    and not vim.wo[0].diff -- Not in diff mode
  then
    attach()
  end
end

mia.augroup('winbar', {
  BufWinEnter = au_attach,
  OptionSet = {
    { pattern = 'buftype', callback = au_attach },
  },
})

local def = {
  -- general definition
  winbar = function()
    local winid = vim.g.statusline_winid or api.nvim_get_current_win()
    local bufnr = api.nvim_win_get_buf(winid)
    local info = mia.bufinfo(bufnr)

    return {
      '    ',
      {
        '❬',
        ' :' .. vim.fn.win_id2win(winid),
        '  󰻾 :' .. winid,
        '   :' .. bufnr,
        '❭',
        hl = '@dark',
      },
      '%=',
      info and info.root and {
        { vim.fs.basename(info.root):upper(), hl = 'Directory' },
        { '❱', pad = true },
        { vim.fs.relpath(info.root, info.bufname), hl = 'Comment' },
      },
      ' ',
    }
  end,

  -- terminals get a special winbar
  termbar = function()
    local winid = vim.g.statusline_winid or api.nvim_get_current_win()
    local bufnr = api.nvim_win_get_buf(winid)
    return {
      ' ',
      vim
        .iter(api.nvim_list_bufs())
        :map(function(buf)
          local info = mia.bufinfo(buf)
          return info and info.pid and info
        end)
        :map(function(info)
          return {
            info.type .. ':' .. info.bufnr,
            hl = bufnr == info.bufnr and 'Directory' or 'Comment',
            on_click = bufnr ~= info.bufnr and function()
              api.nvim_set_current_win(winid)
              api.nvim_set_current_buf(info.bufnr)
            end,
          }
        end)
        :totable(),
      ' ',
      sep = ' ',
    }
  end,
}

function _G.winbar() return mia.line.render(def.winbar, 'winbar') end

function _G.termbar() return mia.line.render(def.termbar, 'winbar') end

return {
  definition = def,
  attach = attach,
}
