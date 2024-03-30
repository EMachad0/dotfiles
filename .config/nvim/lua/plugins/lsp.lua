return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "",
                        package_pending = "",
                        package_uninstalled = "",
                    },
                }
            })
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup {
                -- A list of servers to automatically install if they're not already installed.
                ensure_installed = {
                    "lua_ls",
                    "rust_analyzer",
                },
            }
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("config.lsp")
        end
    },
    {
        "j-hui/fidget.nvim",
        opts = {
            -- options
        },
    },

    -- autocomplete
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        event = { "InsertEnter", "CmdlineEnter" },
        opts = function()
            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

            -- Require the cmp and lspconfig modules
            local cmp = require('cmp')

            -- CMP general setup
            return {
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-e>'] = cmp.mapping.abort(),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
                        if cmp.visible() then
                            local entry = cmp.get_selected_entry()
                            if not entry then
                                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                            end
                            cmp.confirm()
                        else
                            fallback()
                        end
                    end, {"i","s","c",}),
                }),
                sources = cmp.config.sources(
                    {{ name = 'nvim_lsp' }, { name = 'path' }},
                    {{ name = 'buffer' }}
                ),
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    },
                },
            }
        end
    },

    -- snipets
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*",
        -- install jsregexp (optional!).
        -- build = "make install_jsregexp"
        dependencies = {
            {
                "rafamadriz/friendly-snippets",
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end,
            },
            {
                "nvim-cmp",
                dependencies = {
                    "saadparwaiz1/cmp_luasnip",
                },
                opts = function(_, opts)
                    opts.snippet = {
                        expand = function(args)
                            require("luasnip").lsp_expand(args.body)
                        end,
                    }
                    table.insert(opts.sources, { name = "luasnip" })
                end,
            },
        },
    },

    -- rust
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end
    },
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        ft = { 'rust' },
    },
    {
        'saecki/crates.nvim',
        dependecies = "hrsh7th/nvim-cmp",
        ft = { 'rust', 'toml' },
        config = function(_, opts)
            local crates = require('crates')
            crates.setup(opts)
            crates.show()
        end
    },
}
