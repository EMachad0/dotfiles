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

            -- this runs only when an lsp is active on the buffer
            lsp_zero.on_attach(function(_, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp_zero.default_keymaps({ buffer = bufnr })

                vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', { buffer = bufnr })
            end)

            -- LSP Servers config
            require('mason-lspconfig').setup {
                -- A list of servers to automatically install if they're not already installed.
                ensure_installed = {
                    'lua_ls',
                    'rust_analyzer',
                    'clangd',
                },
                handlers = {
                    --- this first function is the "default handler"
                    --- it applies to every language server without a "custom handler"
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
                    -- rust_analizer config by rustaceanvim
                    rust_analyzer = lsp_zero.noop,
                },
            }
        end
    },

    -- autocomplete
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'onsails/lspkind.nvim'
        },
        event = { 'InsertEnter', 'CmdlineEnter' },
        opts = function()
            -- lsp_zero configure the autocompletion settings.
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_cmp()

            -- ghost text
            vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })

            -- Require the cmp and lspconfig modules
            local cmp = require('cmp')
            local lspkind = require('lspkind')

            -- autocomplete toggle
            vim.g.cmp_toggle = false
            vim.keymap.set('n', '<Leader>tc',
                function()
                    vim.g.cmp_toggle = not vim.g.cmp_toggle
                    local status
                    if vim.g.cmp_toggle then
                        status = 'ENABLED'
                    else
                        status = 'DISABLED'
                    end
                    print('nvim-cmp', status)
                end,
                { desc = 'toggle nvim-cmp' }
            )

            return {
                enabled = function()
                    return vim.g.cmp_toggle
                end,
                completion = {
                    completeopt = 'menu,menuone,noinsert', -- auto select first item
                },
                mapping = cmp.mapping.preset.insert({
                    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources(
                    { { name = 'nvim_lsp' }, { name = 'path' } },
                    { { name = 'buffer' } }
                ),
                experimental = {
                    ghost_text = {
                        hl_group = 'CmpGhostText',
                    },
                },
                formatting = {
                    fields = { 'abbr', 'kind', 'menu' },
                    format = lspkind.cmp_format({
                        mode = 'symbol', -- show only symbol annotations
                        maxwidth = 50,   -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        -- can also be a function to dynamically calculate max width such as
                        -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                    })
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
            }
        end
    },

    -- snipets
    {
        'L3MON4D3/LuaSnip',
        -- follow latest release.
        version = 'v2.*',
        -- install jsregexp (optional!).
        -- build = "make install_jsregexp"
        dependencies = {
            {
                'rafamadriz/friendly-snippets',
                config = function()
                    require('luasnip.loaders.from_vscode').lazy_load()
                end,
            },
            {
                'nvim-cmp',
                dependencies = {
                    'saadparwaiz1/cmp_luasnip',
                },
                opts = function(_, opts)
                    opts.snippet = {
                        expand = function(args)
                            require('luasnip').lsp_expand(args.body)
                        end,
                    }
                    table.insert(opts.sources, { name = 'luasnip' })
                end,
            },
        },
    },

    -- rust
    {
        'rust-lang/rust.vim',
        ft = 'rust',
        init = function()
            vim.g.rustfmt_autosave = 1
        end
    },
    {
        'mrcjkb/rustaceanvim',
        dependencies = {
            'VonHeikemen/lsp-zero.nvim',
        },
        version = '^4', -- Recommended
        ft = { 'rust' },
        config = function()
            local lsp_zero = require('lsp-zero')
            return {
                server = {
                    capabilities = lsp_zero.get_capabilities()
                },
            }
        end
    },
    {
        'saecki/crates.nvim',
        dependencies = 'hrsh7th/nvim-cmp',
        ft = { 'rust', 'toml' },
        config = function(_, opts)
            local crates = require('crates')
            crates.setup(opts)
            crates.show()
        end
    },
}
