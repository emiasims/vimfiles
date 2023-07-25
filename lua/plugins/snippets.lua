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

    require 'luasnip.loaders.from_lua'.lazy_load { paths = path.lua }
    require 'luasnip.loaders.from_snipmate'.lazy_load { paths = path.mate }

    local function get_files(ft)
      return vim.iter.filter(function(f) return f:match('^' .. path.snip) end,
        vim.list_extend(
          nvim.get_runtime_file(('snippets/*/%s.*'):format(ft), true),
          nvim.get_runtime_file(('snippets/*/%s/*.*'):format(ft), true)
        ))
    end

    nvim.create_user_command('EditSnippets', function(cmd)
      local filetype = cmd.args == '' and vim.bo.filetype or cmd.args
      local files = get_files(filetype)

      local prompt
      if #files == 0 then
        require 'mia.snippet'.import(filetype)
        require 'luasnip.loaders.from_snipmate'.load { paths = path.mate }
        files = get_files(filetype)
        prompt = "Select one of (just imported):"
      end
      if #files == 1 then
        vim.cmd.edit(files[1])
      else
        vim.ui.select(files, {
          prompt = prompt,
          format_item = vim.fs.basename
        }, function(name) vim.cmd.edit(name) end)
      end
    end, { nargs = '?', complete = 'filetype' })
  end,
}
