return {
  'milisims/nvim-org',
  -- dir = '~/.vim/mia_plugins/nvim-org',
  dev = true,
  -- lazy = true,
  config = function()
    -- vim.api.nvim_create_augroup('nvim-org-markup', { clear = true })

    -- -- this re-definition simply wraps the callback with a function, so it will
    -- -- use 'require' every time. Slightly slower, but updates when I'm reloading
    -- -- the libraries as I edit the code
    -- vim.api.nvim_create_autocmd('Filetype', {
    --   pattern = 'org',
    --   group = 'nvim-org-markup',
    --   desc = 'Register updating markup highlighting with tree-sitter',
    --   callback = function()
    --     require('org.object.extmarks').update()
    --     vim.treesitter.get_parser(0):register_cbs {
    --       on_bytes = function(...)
    --         require('org.object.extmarks').schedule_on_byte(...)
    --       end,
    --     }
    --   end,
    -- })


    -- local Object = require 'org.object.Object'
    -- local Reference = Object:new {
    --   name = 'reference',
    --   spec = function()
    --     return {
    --       str { 'ref', group = 'OrgRefStr', pre = '\\W' },
    --       str ':',
    --       re { '\\S*\\w', group = 'OrgRefName', name = 'name' },
    --     }
    --   end,
    -- }


    -- require('org.object').register(Reference)

    -- local function setup()
    --   local Object = require 'org.object.Object'
    --   local Cite = Object:new {
    --     name = 'cite',
    --     spec = function()
    --       return {
    --         str '[cite:',
    --         re { '\\S*\\w', group = 'OrgCitation', name = 'name' },
    --         str ']',
    --       }
    --     end,
    --   }
    --   require('org.object').register(Cite)

    --   -- local Cite = Object:new {
    --   --   name = 'cite',
    --   --   spec = function()
    --   --     return {
    --   --       eq { '[cite:', pre = '\\W' },
    --   --       rep {
    --   --         eq '@'
    --   --         re { '[^;\]]+', group = 'OrgCitation' name = 'name' }
    --   --       },
    --   --       str ']',
    --   --     }
    --   --   end,
    --   -- }
    --   -- require('org.object').register(Cite)

    --   local defaults = {
    --     OrgCitation = 'delimiter',
    --   }
    --   for capture, group in pairs(defaults) do
    --     vim.cmd(string.format('highlight! default link %s %s', capture, group))
    --   end
    -- end

    -- pcall(setup)
  end,
}
