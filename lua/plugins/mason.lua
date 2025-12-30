---@type LazySpec
return {
  'williamboman/mason.nvim',
  enabled = mia.ide.enabled,
  build = ':MasonUpdate',
  event = 'VeryLazy',
  opts = {
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
  },
  config = function(_, opts)
    require('mason').setup(opts)

    -- Extend neovim's client capabilities with the completion ones.
    vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities(nil, true) })

    -- Get and enable servers
    local servers = vim
      .iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
      -- .iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
      :map(function(file)
        return vim.fn.fnamemodify(file, ':t:r')
      end)
      :totable()

    -- install uninstalled packages.
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
          -- mason notifies error if it fails.
        end)
      end)

      vim.lsp.enable(servers)
  end,
}
