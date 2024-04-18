return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        -- find
        { '<leader>fb', '<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>', desc = 'Buffers' },
        { '<leader>ff', '<cmd>Telescope find_files<cr>',                               desc = 'Find Files (Root Dir)' },
    },
}
