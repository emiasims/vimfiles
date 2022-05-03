vim.api.nvim_create_augroup('nvim-org-markup', { clear = true })

-- this re-definition simply wraps the callback with a function, so it will
-- use 'require' every time. Slightly slower, but updates when I'm reloading
-- the libraries as I edit the code
vim.api.nvim_create_autocmd('Filetype', {
  pattern = 'org',
  group = 'nvim-org-markup',
  desc = 'Register updating markup highlighting with tree-sitter',
  callback = function()
    require('org.object.extmarks').update()
    vim.treesitter.get_parser(0):register_cbs {
      on_bytes = function(...)
        require('org.object.extmarks').schedule_on_byte(...)
      end,
    }
  end,
})
