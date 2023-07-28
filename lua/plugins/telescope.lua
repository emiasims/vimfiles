return {
  'nvim-telescope/telescope.nvim',
  event = { 'InsertEnter', 'CmdlineEnter' },
  cmd = 'Telescope',
  dependencies = { 'debugloop/telescope-undo.nvim' },

  config = function()
    require 'telescope'.setup {
      defaults = {
        file_ignore_patterns = {
          '^data/',
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
      },
    }

    require 'telescope'.load_extension 'undo'
  end,
}
