return {
    -- Catppuccin
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000, -- make sure to load this before all the other start plugins
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        config = function()
            -- actually load the colorscheme
            vim.cmd([[colorscheme catppuccin-mocha]])
        end,
    }
}
