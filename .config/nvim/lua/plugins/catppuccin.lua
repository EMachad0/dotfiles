return {
  -- Catppuccin
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,     -- make sure to load this before all the other start plugins
    lazy = false,        -- make sure we load this during startup if it is your main colorscheme
    config = function()
      -- configuration must run before the colorscheme is applied
      require('catppuccin').setup({
        -- auto detect plugins and enabled their respective catpuccin theme
        auto_integrations = true,
      })

      -- actually load the colorscheme
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  }
}
