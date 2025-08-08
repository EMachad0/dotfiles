return {
    -- autocomplete
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
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
            vim.g.cmp_toggle = true
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
                    ['<C-e>'] = cmp.mapping.close(),
                }),
                sources = cmp.config.sources(
                    { { name = 'nvim_lsp' }, { name = 'path' } }, -- priority 1
                    { { name = 'buffer' } } -- priority 2
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
    -- snipets and main keybinds
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
                    table.insert(opts.sources, { name = 'luasnip', group_index = 1 })
                end,
            },
        },
        config = function()
            local luasnip = require('luasnip')
            local cmp = require('cmp')

            local enter_mapping = cmp.mapping(function(fallback)
                if cmp.visible() then
                    if luasnip.expandable() then
                        luasnip.expand()
                    else
                        cmp.confirm({
                            select = true,
                        })
                    end
                else
                    fallback()
                end
            end)

            -- tab completion behavior recommended by copilot-cmp
            local function has_words_before()
                if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then return false end
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
            end

            -- Super Tab: select next item or jump to next snipet or fallback
            local tab_mapping = cmp.mapping(function(fallback)
                if cmp.visible() and has_words_before() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                elseif luasnip.locally_jumpable(1) then
                    luasnip.jump(1)
                else
                    fallback()
                end
            end, { "i", "s" })
            -- Shift-Tab: select previous item or fallback
            local stap_mapping = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                elseif luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" })

            local mappings = cmp.mapping.preset.insert({
                ['<CR>'] = enter_mapping,
                ['<Tab>'] = tab_mapping,
                ['<S-Tab>'] = stap_mapping,
            })

            cmp.setup({
                mapping = mappings,
            })
        end
    },
    -- vim command completion
    {
        'hrsh7th/cmp-cmdline',
        dependencies = { 'hrsh7th/nvim-cmp' },
        config = function()
            local cmp = require('cmp')

            -- Search (/, ?): use buffer words
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' },
                },
            })

            -- Commands (:): paths first, then command names
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' },
                }, {
                    {
                        name = 'cmdline',
                        options = {
                            ignore_cmds = { 'Man', '!' }
                        }
                    },
                }),
            })
        end,
    }
}
