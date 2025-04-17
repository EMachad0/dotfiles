return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'debugloop/telescope-undo.nvim',
    },
    keys = {
        -- find
        { '<leader>fb', '<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>', desc = 'Recent Buffers' },
        { '<leader>ff', '<cmd>Telescope find_files<cr>',                               desc = 'Find Files (Root Dir)' },
        -- undo buffer
        { '<leader>fu', '<cmd>Telescope undo<cr>', desc = 'Undo' }
    },
    config = function()
        require('telescope').setup({})
        require('telescope').load_extension('undo')
    end
}
