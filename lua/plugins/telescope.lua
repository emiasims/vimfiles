---@type LazySpec
return {
  'nvim-telescope/telescope.nvim',
  -- event = { 'InsertEnter', 'CmdlineEnter' },
  cmd = 'Telescope',

  dependencies = {
    'xiyaowong/telescope-emoji.nvim',
    'debugloop/telescope-undo.nvim',
    'lazy-ctx.nvim',
  },

  -- keys = {
  --   {
  --     'ctx.each(telescope)',
  --     'builtin.cmd_start',
  --     mode = 'ca',
  --     pairs = {
  --       f = 'Telescope fd',
  --       fh = 'Telescope fd cwd=<C-r>=expand("%:h")<Cr>',
  --       o = 'Telescope fd cwd=~/org',
  --       u = 'Telescope undo',
  --       l = 'Telescope buffers',
  --       t = 'Telescope tags',
  --       tr = 'Telescope resume',
  --       mr = 'Telescope oldfiles',
  --       A = 'Telescope live_grep',
  --       h = 'Telescope help_tags',
  --       hi = 'Telescope highlights',
  --       em = 'Telescope emoji',
  --       ws = 'Telescope lsp_dynamic_workspace_symbols',
  --       ev = 'Telescope fd cwd=' .. vim.fn.stdpath('config'),
  --       evp = 'Telescope fd cwd=' .. vim.fn.stdpath('config') .. '/mia_plugins',
  --       evs = 'Telescope fd cwd=' .. vim.fn.stdpath('data') .. '/lazy',
  --       evr = 'Telescope fd cwd=' .. vim.env.VIMRUNTIME,
  --       gst = 'Telescope git_status',
  --     },
  --     clear = true,
  --   },
  -- },

  keys = {
    {
      'ctx.each(telescope)',
      'builtin.cmd_start',
      mode = 'ca',
      pairs = {
        f = 'Telescope fd',
        fh = 'Telescope fd cwd=<C-r>=expand("%:h")<Cr>',
        o = 'Telescope fd cwd=~/org',
        u = 'Telescope undo',
        l = 'Telescope buffers',
        t = 'Telescope tags',
        tr = 'Telescope resume',
        mr = 'Telescope oldfiles',
        A = 'Telescope live_grep',
        h = 'Telescope help_tags',
        hi = 'Telescope highlights',
        em = 'Telescope emoji',
        ws = 'Telescope lsp_dynamic_workspace_symbols',
        ev = 'Telescope fd cwd=' .. vim.fn.stdpath('config'),
        evp = 'Telescope fd cwd=' .. vim.fn.stdpath('config') .. '/mia_plugins',
        evs = 'Telescope fd cwd=' .. vim.fn.stdpath('data') .. '/lazy',
        evr = 'Telescope fd cwd=' .. vim.env.VIMRUNTIME,
        gst = 'Telescope git_status',
      },
    },
  },

  opts = {
    defaults = {
      layout_strategy = 'flex',
      layout_config = {
        flex = {
          flip_columns = 140,
          vertical = {
            vertical = {
              prompt_position = 'bottom',
              mirror = true,
              preview_cutoff = 30,
              preview_height = 15,
            },
          },
        },
      },
      file_ignore_patterns = {
        '^data/',
        '^[^/]+.egg-info/',
        '^local_runs/',
        '%.mp4$',
        '%.npz$',
        '%.png$',
        '%.rels$',
        '%.xml$',
        '%.svg$',
        '$ignore',
        '^src/parser.c$',
      },
      mappings = { i = { ['<C-s>'] = 'select_horizontal' } },
    },
    extensions = {
      -- See link for defaults & all options available
      -- https://github.com/debugloop/telescope-undo.nvim/blob/main/lua/telescope/_extensions/undo.lua#L6
      undo = {
        use_delta = true,
        -- side_by_side = true,
        layout_strategy = 'vertical',
        layout_config = { preview_height = 0.8 },
      },
      emoji = {
        action = function(emoji)
          emoji = emoji.value
          if vim.g._EM then
            vim.g._EM = nil
            local pos = vim.fn.getcurpos()
            vim.api.nvim_put({ emoji }, 'c', true, true)
            vim.schedule(vim.cmd.startinsert)
            vim.schedule_wrap(vim.fn.cursor)(pos[2], pos[3] + #emoji)
          else
            vim.fn.setreg('*', emoji)
            vim.fn.setreg('"', emoji)
            vim.schedule_wrap(vim.api.nvim_echo)({ { 'Yanked ' .. emoji, 'Type' } }, true, {})
          end
        end,
      },
    },
  },
}
