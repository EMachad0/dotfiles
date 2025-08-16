return {
    -- rust
    {
        'mrcjkb/rustaceanvim',
        dependencies = {},
        version = '^4', -- Recommended
        ft = { 'rust' },
        -- rustaceanvim is lazy loaded by default, but we can set it to load on demand
        lazy = false,
        config = function()
            local shared = require('config.lsp.shared')
            vim.g.rustaceanvim = {
                server = {
                    on_attach = shared.on_attach,
                    capabilities = shared.make_capabilities(),
                    settings = {
                        ['rust-analyzer'] = {
                            diagnostics = {
                                disabled = { 'inactive-code' },
                            },
                        },
                    },
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
