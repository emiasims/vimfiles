---@type LazySpec
-- return {}
return {
  'L3MON4D3/LuaSnip',
  build = 'make install_jsregexp',
  event = 'InsertEnter',

  dependencies = {
    'rafamadriz/friendly-snippets',
    'saadparwaiz1/cmp_luasnip',
  },

  config = function()
    local path = { snip = vim.fn.stdpath 'config' .. '/snippets' }
    path.lua = path.snip .. '/luasnip'
    path.mate = path.snip .. '/snipmate'
    local lua_load = require 'luasnip.loaders.from_lua'
    local mate_load = require 'luasnip.loaders.from_snipmate'

    lua_load.lazy_load { paths = path.lua }
    mate_load.lazy_load { paths = path.mate }

    local function get_files(ft)
      return vim.iter.filter(function(f) return f:match('^' .. path.snip) end,
        vim.list_extend(
          vim.api.nvim_get_runtime_file(('snippets/*/%s.*'):format(ft), true),
          vim.api.nvim_get_runtime_file(('snippets/*/%s/*.*'):format(ft), true)
        ))
    end

    vim.api.nvim_create_user_command('EditSnippets', function(cmd)
      local filetype = cmd.args == '' and vim.bo.filetype or cmd.args
      local files = get_files(filetype)

      local editcmd = vim.cmd.edit
      if cmd.smods.horizontal or cmd.smods.vertical then
        editcmd = vim.cmd.split
      end

      local prompt
      if #files == 0 then
        require 'mia.snippet'.import(filetype)
        files = get_files(filetype)
        prompt = 'Select one of (just imported):'
        if #files == 0 then
          prompt = 'Select one of (to create):'
          files = {
            path.mate .. ('/%s.snippets'):format(filetype),
            path.lua .. ('/%s.lua'):format(filetype),
          }
        end
      end
      if #files == 1 then
        editcmd(files[1])
      else
        vim.ui.select(files, {
          prompt = prompt,
          format_item = vim.fs.basename,
        }, function(name) editcmd { name, mods = cmd.smods } end)
        vim.api.nvim_create_autocmd('BufWritePost', {
          desc = 'Ensure files loaded',
          callback = function()
            lua_load.load { paths = path.lua }
            mate_load.load { paths = path.mate }
          end,
          once = true,
          nested = true,
          buffer = 0,
        })
      end
    end, { nargs = '?', complete = 'filetype' })
  end,
}
