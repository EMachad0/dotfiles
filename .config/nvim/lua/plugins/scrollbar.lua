return {
    {
        'petertriho/nvim-scrollbar',
        event = 'VeryLazy',
        dependencies = {
            'kevinhwang91/nvim-hlslens',
            'lewis6991/gitsigns.nvim',
        },
        config = function()
            require('scrollbar').setup()
            require('scrollbar.handlers.search').setup({
                -- remove hlslens floating window
                override_lens = function() end,
            })
            require('scrollbar.handlers.gitsigns').setup()
            require('scrollbar.handlers.diagnostic').setup()
        end,
    },
}
