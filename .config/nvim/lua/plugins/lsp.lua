return {
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = function()
            require('mason').setup({
                ui = {
                    icons = {
                        package_installed = '',
                        package_pending = '',
                        package_uninstalled = '',
                    },
                }
            })
        end
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = false,
        init = function()
            -- Disable automatic setup, we are doing it manually
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end,
    },
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason-lspconfig.nvim' },
            { 'j-hui/fidget.nvim' },
        },
        config = function()
            -- This is where all the LSP shenanigans will live
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_lspconfig()

            -- this runs only when an LSP is active on the buffer
            lsp_zero.on_attach(function(_, bufnr)
                -- diagnostic config (use vim.diagnostic.config for signs)
                local severity = vim.diagnostic.severity
                vim.diagnostic.config({
                    virtual_text = true, -- shows inline messages
                    underline = true,    -- underlines the words
                    signs = {
                        text = {
                            [severity.ERROR] = "✘ ",
                            [severity.WARN]  = "▲ ",
                            [severity.HINT]  = "⚑ ",
                            [severity.INFO]  = " ",
                        },
                    },
                    update_in_insert = false,
                })

                -- keymaps
                local keymap_options = { buffer = bufnr, silent = true }

                local function map(mode, lhs, rhs, desc)
                    local opts = vim.tbl_extend('force', keymap_options, { desc = desc })
                    vim.keymap.set(mode, lhs, rhs, opts)
                end

                -- LSP core actions
                map('n', '<leader>lh', vim.lsp.buf.hover, 'LSP: Hover')
                map('n', '<leader>lR', vim.lsp.buf.rename, 'LSP: Rename')
                map('n', '<leader>la', vim.lsp.buf.code_action, 'LSP: Code Action')

                -- Go to/peek
                map('n', '<leader>ld', vim.lsp.buf.definition, 'LSP: Go to Definition')
                map('n', '<leader>lD', vim.lsp.buf.declaration, 'LSP: Go to Declaration')
                map('n', '<leader>lt', vim.lsp.buf.type_definition, 'LSP: Type Definition')
                map('n', '<leader>li', vim.lsp.buf.implementation, 'LSP: Go to Implementation')
                map('n', '<leader>lr', vim.lsp.buf.references, 'LSP: References')
                map('n', '<leader>lk', vim.lsp.buf.signature_help, 'LSP: Signature Help')

                -- Diagnostics
                map('n', '<leader>le', vim.diagnostic.open_float, 'Diagnostics: Line Diagnostics')
                map('n', '<leader>l[', function() vim.diagnostic.jump({ count = -1, float = true }) end,
                    'Diagnostics: Previous')
                map('n', '<leader>l]', function() vim.diagnostic.jump({ count = 1, float = true }) end,
                    'Diagnostics: Next')
                map('n', '<leader>lq', vim.diagnostic.setloclist, 'Diagnostics: To LocList')

                -- Symbols (Telescope if available)
                local telescope_ok, tbuiltin = pcall(require, 'telescope.builtin')
                if telescope_ok then
                    map('n', '<leader>ls', tbuiltin.lsp_document_symbols, 'LSP: Document Symbols')
                    map('n', '<leader>lS', tbuiltin.lsp_dynamic_workspace_symbols, 'LSP: Workspace Symbols')
                else
                    map('n', '<leader>ls', vim.lsp.buf.document_symbol, 'LSP: Document Symbols')
                    map('n', '<leader>lS', vim.lsp.buf.workspace_symbol, 'LSP: Workspace Symbols')
                end

                -- Workspace folders
                map('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, 'LSP: Workspace Add Folder')
                map('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'LSP: Workspace Remove Folder')
                map('n', '<leader>lwl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, 'LSP: Workspace List Folders')

                -- Formatting
                map({ 'n', 'v' }, '<leader>lf', function()
                    vim.lsp.buf.format({ async = true })
                end, 'LSP: Format')
            end)

            -- LSP Servers config
            require('mason-lspconfig').setup {
                automatic_enable = {
                    -- rust_analyzer is enable by rustancean vim
                    exclude = { 'rust_analyzer' }
                },
                -- A list of servers to automatically install if they're not already installed.
                ensure_installed = {
                    'lua_ls',
                    'rust_analyzer',
                    'clangd',
                },
                handlers = {
                    --- this first function is the "default handler"
                    -- - it applies to every language server without a "custom handler"
                    function(server_name)
                        -- try to load a module in 'nvim/lua/config/lsp/server_name.lua'
                        local status, setup_function = pcall(require, 'config.lsp.' .. server_name)
                        if status then
                            setup_function() -- Call the function directly if the module is successfully loaded
                        else
                            -- If the module does not exist, use a default setup and print a warning message
                            require('lspconfig')[server_name].setup({})
                            print('Warning: No custom configuration found for ' .. server_name .. '.')
                        end
                    end,
                },
            }
        end
    },
}
