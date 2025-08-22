return {
    {
        'lewis6991/gitsigns.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        opts = {
            on_attach = function(bufnr)
                -- Set up which-key gitsigns keymap group
                local wk_ok, wk = pcall(require, 'which-key')
                if wk_ok then
                    wk.add({
                        { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
                    })
                end

                local gitsigns = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ ']g', bang = true })
                    else
                        gitsigns.next_hunk()
                    end
                end, { desc = 'Next Git hunk' })
                map('n', '[c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[g', bang = true })
                    else
                        gitsigns.prev_hunk()
                    end
                end, { desc = 'Previous Git hunk' })

                -- Actions
                map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Stage hunk' })
                map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Reset hunk' })

                map('v', '<leader>hs', function()
                    gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, { desc = 'Stage selection as hunk' })
                map('v', '<leader>hr', function()
                    gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, { desc = 'Reset selection from hunk' })

                map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Stage buffer' })
                map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Reset buffer' })
                map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview hunk' })
                map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'Inline hunk preview' })

                map('n', '<leader>hb', function()
                    gitsigns.blame_line({ full = true })
                end, { desc = 'Blame line (full)' })

                map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff this file' })

                map('n', '<leader>hD', function()
                    gitsigns.diffthis('~')
                end, { desc = 'Diff against previous commit (~)' })

                map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, { desc = 'Quickfix: all repo hunks' })
                map('n', '<leader>hq', gitsigns.setqflist, { desc = 'Quickfix: buffer hunks' })

                -- Toggles
                map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle current line blame' })
                map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = 'Toggle word diff' })

                -- Text object
                map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'Select Git hunk' })
            end
        }
    },
    {
        'radyz/telescope-gitsigns',
        dependencies = {
            'lewis6991/gitsigns.nvim',
            'nvim-telescope/telescope.nvim',
        },
        keys = {
            { '<leader>fh', '<Cmd>Telescope git_signs<Cr>', desc = 'Git hunks' },
        },
        config = function()
            require('telescope').load_extension('git_signs')
        end,
    },
}
