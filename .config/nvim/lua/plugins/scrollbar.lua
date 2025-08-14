return {
    {
        'kevinhwang91/nvim-hlslens',
        config = function()
            require('hlslens').setup({
                nearest_only = true,
                nearest_float_when = 'always',
            })
        end
    },
    {
        'petertriho/nvim-scrollbar',
        event = 'VeryLazy',
        dependencies = {
            'kevinhwang91/nvim-hlslens',
            'lewis6991/gitsigns.nvim',
        },
        config = function()
            require('scrollbar').setup()
            require('scrollbar.handlers.search').setup()
            require('scrollbar.handlers.gitsigns').setup()
            require('scrollbar.handlers.diagnostic').setup()
        end,
    },
}
