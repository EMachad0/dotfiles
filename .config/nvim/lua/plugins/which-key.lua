return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
    },
    config = function()
        local wk = require('which-key')
        wk.add({
            { '<leader>t', group = 'Toggle' },
        })
    end,
}
