---@type LazySpec
return {
  { 'tpope/vim-fugitive', event = 'VeryLazy' },
  {
    'lewis6991/gitsigns.nvim',
    event = 'TextChanged',
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local opts = { buffer = bufnr }

        -- local ctx = require('ctx')
        -- ctx.set('n', ']c', { gs.next_hunk, ctx.opt.diff.off }, opts)
        -- ctx.set('n', '[c', { gs.prev_hunk, ctx.opt.diff.off }, opts)

        -- local vo = require 'ctx.contexts'.vimopt
        -- map('n', ']c', {gs.next_hunk, vo.wo.diff}, { buffer = bufnr })
        -- local not_diffmode = function() return not vim.wo.diff end

        opts.dotrepeat = true
        local nmap, xmap = require('mapfun')({ 'n', 'x' }, opts) -- buffer normal map
        nmap('gsh', gs.stage_hunk, { desc = 'Stage hunk' })
        nmap('gsr', gs.reset_hunk, { desc = 'Reset hunk' })
        xmap('gsh', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Stage visually selected hunk' })
        xmap('gsr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Reset visually selected hunk' })
        nmap('gsS', gs.stage_buffer, { desc = 'Stage buffer' })
        nmap('gSS', 'gsS', { remap = true })
        nmap('gsu', gs.undo_stage_hunk, { desc = 'Undo last stage' })
        nmap('gsR', gs.reset_buffer, { desc = 'Reset buffer' })
        nmap('gsp', gs.preview_hunk, { desc = 'Preview hunk' })
        nmap('gsb', function()
          gs.blame_line({ full = true })
        end, { desc = 'Git blame' })
        nmap('gstb', gs.toggle_current_line_blame, { desc = 'Blame current line' })
        nmap('gsd', gs.diffthis, { desc = 'Diff hunk' })
        nmap('gsD', function()
          gs.diffthis('~')
        end, { desc = 'Diff hunk different??' })
        nmap('gstd', gs.toggle_deleted, { desc = 'Stage hunk' })
      end,
    },
  },
}
