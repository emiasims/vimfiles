local groupid = vim.api.nvim_create_augroup('mia-org', { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.org",
  desc = "Add simple title to org files by default",
  group = groupid,
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local dirname = vim.fn.expand("%:p:h")
    local orgname = vim.fn.resolve(os.getenv('HOME') .. '/org')
    if dirname == orgname and #lines == 1 and lines[1] == "" then
      local title = vim.fn.expand("%:p:t"):lower()
      title = title:sub(1, #title - 4):gsub('_', ' ') -- minus '.org', "_" to " "
      title = title:gsub("(%a)([%w_']*)", function(first, rest)
        if #rest <= 1 then
          return (first .. rest):lower()
        end
        return first:upper() .. rest:lower()
      end)
      vim.api.nvim_buf_set_lines(0, 0, 0, false, { "#+title: " .. title })
      vim.fn.cursor(2, 1)
    end
  end,
})
