local path = vim.fn.stdpath('config') .. '/queries/*/*.scm'
local src = require('mia.source').set_query
for _, file in ipairs(vim.fn.glob(path, 0, 1)) do
  src(file)
end
