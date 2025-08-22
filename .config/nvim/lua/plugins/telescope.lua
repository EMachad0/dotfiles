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
        {
            '<leader>ff',
            function()
                local builtin = require('telescope.builtin')
                local hidden = vim.g.telescope_show_hidden_files == true
                builtin.find_files({
                    hidden = hidden,
                })
            end,
            desc = 'Find Files',
        },
        {
            '<leader>fs',
            function()
                local builtin = require('telescope.builtin')
                local hidden = vim.g.telescope_show_hidden_files == true
                builtin.live_grep({
                    additional_args = function()
                        local args = {}
                        if hidden then
                            table.insert(args, '--hidden')
                        end
                        return args
                    end,
                    -- Seed with word under cursor
                    default_text = vim.fn.expand('<cword>'),
                })
            end,
            desc = 'Find String',
        },
        -- undo buffer
        { '<leader>fu', '<cmd>Telescope undo<cr>',                                     desc = 'Undo' },
        -- git
        { '<leader>fg', '<cmd>Telescope git_status<cr>',                               desc = 'Git Status' },
        { '<leader>fh', '<cmd>Telescope git_commits<cr>',                              desc = 'Git Commits' },
        { '<leader>fH', '<cmd>Telescope git_bcommits<cr>',                             desc = 'Git Buffer Commits' },
    },
    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        -- Set up which-key telescope keymap group
        local wk_ok, wk = pcall(require, 'which-key')
        if wk_ok then
            wk.add({
                { '<leader>f', group = 'Telescope', mode = { 'n' } },
            })
        end

        -- Persisted session toggle state
        if vim.g.telescope_show_hidden_files == nil then
            vim.g.telescope_show_hidden_files = false
        end

        local function get_hidden_state()
            return vim.g.telescope_show_hidden_files == true
        end

        local function relaunch_find_files_with_hidden(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local current_text = action_state.get_current_line()
            actions.close(prompt_bufnr)
            vim.g.telescope_show_hidden_files = not get_hidden_state()
            builtin.find_files({
                cwd = picker.cwd,
                hidden = get_hidden_state(),
                default_text = current_text,
            })
        end

        local function relaunch_live_grep_with_hidden(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local current_text = action_state.get_current_line()
            actions.close(prompt_bufnr)
            vim.g.telescope_show_hidden_files = not get_hidden_state()
            builtin.live_grep({
                cwd = picker.cwd,
                additional_args = function()
                    local args = {}
                    if get_hidden_state() then
                        table.insert(args, '--hidden')
                    end
                    return args
                end,
                default_text = current_text,
            })
        end

        telescope.setup({
            defaults = {
                file_ignore_patterns = { '.git/' },
                -- Truncate long paths from the start so filenames stay visible
                path_display = { 'smart' },
                mappings = {
                    i = {
                        ['<esc>'] = actions.close
                    },
                    n = {},
                },
            },
            pickers = {
                find_files = {
                    mappings = {
                        i = {
                            ['<C-.>'] = relaunch_find_files_with_hidden,
                        },
                    },
                },
                live_grep = {
                    mappings = {
                        i = {
                            ['<C-.>'] = relaunch_live_grep_with_hidden,
                        },
                    },
                },
                lsp_references = {
                    show_line = false,
                },
            },
        })
        telescope.load_extension('undo')
    end
}
