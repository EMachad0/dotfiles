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
            {
                'j-hui/fidget.nvim',
                tag = '*', -- pin to latest tag
                opts = {
                    -- options
                },
            },
        },
        config = function()
            local shared = require('config.lsp.shared')

            local base_dir = vim.fn.stdpath('config') .. '/lua/config/lsp'
            local files = vim.fn.globpath(base_dir, '*.lua', false, true)

            -- Base settings injected into every server
            vim.lsp.config('*', {
                on_attach = shared.on_attach,
                capabilities = shared.make_capabilities(),
            })

            for _, file in ipairs(files) do
                local name = vim.fn.fnamemodify(file, ':t:r') -- filename without .lua
                if name ~= 'shared' then
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
            'vtsls',
            'eslint',
        },
        automatic_enable = { false },
    },
    -- action preview picker plugin
    {
        'aznhe21/actions-preview.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim'
        },
        opts = function()
            local v = require('telescope.config').values
            return {
                backend = { 'telescope' },
                -- Copy Telescope's resolved defaults so the picker mirror telescope setup
                telescope = vim.tbl_deep_extend('force', {}, v),
            }
        end,
    },
}
