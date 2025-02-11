---@type LazySpec
return {
  'nvim-telescope/telescope.nvim',
  event = { 'InsertEnter', 'CmdlineEnter' },
  cmd = 'Telescope',
  enabled = false,

  dependencies = {
    'xiyaowong/telescope-emoji.nvim',
    'debugloop/telescope-undo.nvim',
    'lazy-ctx.nvim',
  },

  ctx = {
    {
      mode = 'ca',
      ctx = 'builtin.cmd_start',
      each = {
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
        ecf = 'Telescope config_files',
      },
    },
  },

  config = function(spec)
    local ts = require('telescope')
    ts.setup(spec.opts --[[@as table]])

    ts.extensions['config_files'] = {
      config_files = function(opts)
        return require('telescope.builtin').find_files(vim.tbl_extend('force', opts, {
          cwd = '~',
          find_command = {
            'git',
            '--git-dir=' .. vim.env.HOME .. '/.cfg/',
            '--work-tree=' .. vim.env.HOME,
            'ls-files',
            '--exclude-standard',
            '--cached',
          },
        }))
      end,
    }
  end,

  opts = {
    defaults = {
      layout_strategy = 'flex',
      layout_config = {
        flex = {
          flip_columns = 135,
          flip_lines = 35,
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
      mappings = { i = { ['<C-s>'] = 'select_horizontal' }, n = { ['<C-c>'] = 'close' } },
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
