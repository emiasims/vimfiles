vim.pack.add({ 'https://github.com/williamboman/mason.nvim' }, { load = true })

mia.augroup('mason-pack', {
  PackChanged = function(ev)
    if ev.data and ev.data.name == 'mason.nvim' then
      vim.cmd.MasonUpdate()
    end
  end,
})

require('mason').setup({
  ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
})

local ok, blink = pcall(require, 'blink.cmp')
if ok then
  vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities(nil, true) })
end

local servers = vim
  .iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
  :map(function(file)
    return vim.fn.fnamemodify(file, ':t:r')
  end)
  :totable()

vim
  .iter(vim.tbl_values(vim.lsp._enabled_configs))
  :filter(function(cfg)
    return cfg.resolved_config and cfg.resolved_config.mason
  end)
  :map(function(cfg)
    local mason = cfg.resolved_config.mason
    mason = (mason == true and {}) or mason
    return { mason.name or cfg.resolved_config.name, mason.tools }
  end)
  :flatten(2)
  :filter(function(pkg)
    return not require('mason-registry').is_installed(pkg)
  end)
  :each(function(package)
    local pkg = require('mason-registry').get_package(package)
    pkg:install({}, function(success, res)
      if success then
        mia.info('MASON installed package "%s"', package)
      end
    end)
  end)

mia.augroup('lsp', {
  LspAttach = function(ev)
    if vim.fn.hasmapto('<C-h>', 'i') == 0 then
      mia.keymap({ '<C-h>', '<Cmd>lua vim.lsp.buf.signature_help()<Cr>', mode = 'i', buffer = ev.buf })
    end
  end,
})

vim.lsp.enable(servers)
