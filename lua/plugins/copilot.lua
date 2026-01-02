vim.g.copilot_no_maps = true
vim.g.copilot_assume_mapped = true

return {
  'github/copilot.vim',
  enabled = mia.ide.enabled,
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
    -- Want to be able to dot repeat insertions that include copilot
    local function repeatAccept(fn, fallback)
      return function()
        local ret = vim.fn['copilot#' .. fn](fallback or '')
        local st, en = ret:find('..=copilot#TextQueuedForInsertion%(%).')
        if not st then
          return ret -- fallback
        end

        local text = vim.fn['copilot#TextQueuedForInsertion']()

        -- set up extmark to track the insertion + reveal prettily
        mia.reveal.track({ speed = math.min(#text, 500), max = 5000 })

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
    -- Note: workspace_folder is used, set by mia.autocmds

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

    mia.augroup('copilot', {
      User = {
        BufInfo = function(ev)
          vim.b.workspace_folder = ev.data.root
        end
      }
    })

  end,
}
