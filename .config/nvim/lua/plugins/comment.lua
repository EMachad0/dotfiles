-- comment with gc & gcc
return {
    {
        'numToStr/Comment.nvim',
        lazy = false,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'JoosepAlviste/nvim-ts-context-commentstring',
        },
        opts = {
            pre_hook = function()
                return require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
            end,
        },
        config = function()
            require('ts_context_commentstring').setup({
                enable = true,
                enable_autocmd = false,
            })

            require('Comment').setup()
        end,
    },
}
