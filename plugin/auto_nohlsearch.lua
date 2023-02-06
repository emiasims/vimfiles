local set_hlsearch = vim.tbl_add_reverse_lookup { "<CR>", "n", "N", "*", "#", "?", "/" }

vim.on_key(
  function(char)
    if vim.fn.mode() == "n" then
      local key = vim.fn.keytrans(char)
      if vim.o.hlsearch ~= set_hlsearch[key] then
        -- must be exactly true or false
        vim.o.hlsearch = (set_hlsearch[key] or false) and true
      end
    end
  end,
  vim.api.nvim_create_namespace "auto_hlsearch")
