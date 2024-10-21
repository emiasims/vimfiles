vim.g.copilot_no_maps = true
vim.g.copilot_assume_mapped = true

return {
  'github/copilot.vim',
  lazy = false,
  keys = {
    { '<C-Space>', '<Plug>(CopilotAccept)', mode = 'i' },
    { '<C-l>', '<Plug>(CopilotAcceptWord)', mode = 'i' },
    { '<C-j>', '<Plug>(CopilotAcceptLine)', mode = 'i' },
    { '<M-]>', '<Plug>(CopilotNext)', mode = 'i' },
    { '<M-[>', '<Plug>(CopilotPrevious)', mode = 'i' },
    { '<S-Space>', '<Plug>(miaCmpSuggest)<Plug>(CopilotSuggest)', mode = 'i' },
  },

  config = function()
    local ns = vim.api.nvim_create_namespace('mia-copilot')
    local hlgroup = 'CopilotSuggestion'

    -- next 2 functions set up a pretty reveal for the copilot suggestions
    local function setup_scanner_mark(buf, r, c)
      return vim.api.nvim_buf_set_extmark(buf, ns, r - 1, c, {
        end_col = c + 1,
        hl_group = hlgroup,
        right_gravity = false,
        end_right_gravity = true,
        strict = false,
      })
    end

    local start_scanner = vim.schedule_wrap(function(buf, markid, speed)
      local timer = vim.uv.new_timer()

      ---@param mdeets vim.api.keyset.extmark_details
      local setmark = function(start_row, start_col, mdeets)
        vim.api.nvim_buf_set_extmark(buf, ns, start_row, start_col, {
          id = markid,
          end_row = mdeets.end_row,
          end_col = mdeets.end_col,
          hl_group = hlgroup,
          strict = true,
        })
      end

      local scan = function()
        local success = pcall(function()
          local m = vim.api.nvim_buf_get_extmark_by_id(buf, ns, markid, { details = true })
          local dx = math.random(2, speed * 2 - 2)
          -- local dx = 5
          local success = pcall(setmark, m[1], m[2] + dx, m[3])
          if not success then
            setmark(m[1] + 1, 0, m[3])
          end
        end)
        if not success then
          timer:stop()
          pcall(timer.close, timer)
        end
      end

      timer:start(0, 15, vim.schedule_wrap(scan))
    end)

    local get_copilot_text = vim.fn['copilot#TextQueuedForInsertion']

    -- Want to be able to dot repeat insertions that include copilot
    local function repeatAccept(fn, fallback)
      return function()
        local ret = vim.fn['copilot#' .. fn](fallback or '')
        local st, en = ret:find('..=copilot#TextQueuedForInsertion%(%).')
        if not st then
          return ret -- fallback
        end

        local text = get_copilot_text()
        Text = text

        -- set up extmark to track the insertion + reveal prettily
        local buf = vim.api.nvim_get_current_buf()
        local curs = vim.api.nvim_win_get_cursor(0)
        local id = setup_scanner_mark(buf, unpack(curs))
        start_scanner(buf, id, math.floor(#text / 100) + 3)

        -- return the actual text
        return table.concat({
          vim.keycode('<C-g>u<Cmd>set paste<Cr>'),
          ret:sub(1, st - 1),
          text,
          ret:sub(en + 1),
          vim.keycode('<Cmd>set nopaste<Cr><C-g>u'),
        })
      end
    end

    mia.keymap({
      mode = 'i',
      {
        expr = true,
        nowait = true,
        silent = true,
        replace_keycodes = false,
        { '<Plug>(CopilotAccept)', repeatAccept('Accept') },
        { '<Plug>(CopilotAcceptWord)', repeatAccept('AcceptWord') },
        { '<Plug>(CopilotAcceptLine)', repeatAccept('AcceptLine') },
      },
      { '<Plug>(CopilotNext)', vim.fn['copilot#Next'] },
      { '<Plug>(CopilotPrevious)', vim.fn['copilot#Previous'] },
      { '<Plug>(CopilotSuggest)', vim.fn['copilot#Suggest'] },
    })
  end,
}
