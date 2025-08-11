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
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'j-hui/fidget.nvim' },
        },
        opts = {
            -- this runs only when an LSP is active on the buffer
            on_attach = function(_, bufnr)
                -- diagnostic config (use vim.diagnostic.config for signs)
                local severity = vim.diagnostic.severity
                vim.diagnostic.config({
                    virtual_text = true, -- shows inline messages
                    underline = true,    -- underlines the words
                    signs = {
                        text = {
                            [severity.ERROR] = '✘ ',
                            [severity.WARN]  = '▲ ',
                            [severity.HINT]  = '⚑ ',
                            [severity.INFO]  = ' ',
                        },
                    },
                    update_in_insert = false,
                })

                -- keymaps
                local keymap_options = { buffer = bufnr, silent = true }

                local function map(mode, lhs, rhs, desc)
                    local lopts = vim.tbl_extend('force', keymap_options, { desc = desc })
                    vim.keymap.set(mode, lhs, rhs, lopts)
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
            end
        },
        config = function(_, opts)
            local base_dir = vim.fn.stdpath('config') .. '/lua/config/lsp'
            local files = vim.fn.globpath(base_dir, '*.lua', false, true)

            -- Build capabilities once, enhanced by cmp-nvim-lsp
            local function make_capabilities()
                local caps = vim.lsp.protocol.make_client_capabilities()
                local ok, cmp = pcall(require, 'cmp_nvim_lsp')
                if ok then caps = cmp.default_capabilities(caps) end
                return caps
            end

            -- Base settings injected into every server
            vim.lsp.config('*', {
                on_attach = opts.on_attach,
                capabilities = make_capabilities(),
            })

            for _, file in ipairs(files) do
                local name = vim.fn.fnamemodify(file, ':t:r') -- filename without .lua
                local modname = ('config.lsp.%s'):format(name)
                local ok, mod = pcall(require, modname)
                if not ok then
                    vim.notify('LSP config failed: ' .. modname .. '\n' .. mod, vim.log.levels.ERROR)
                else
                    vim.lsp.config(name, mod)
                    vim.lsp.enable(name)
                end
            end
        end
    },
    {
        'mason-org/mason-lspconfig.nvim',
        dependencies = {
            'mason-org/mason.nvim',
            'neovim/nvim-lspconfig',
        },
        -- A list of servers to automatically install if they're not already installed.
        ensure_installed = {
            'lua_ls',
            'rust_analyzer',
            'clangd',
        },
        automatic_enable = { false },
    },
}
