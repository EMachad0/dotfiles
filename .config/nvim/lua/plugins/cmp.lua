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
            -- ghost text
            vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })

            -- Require the cmp and lspconfig modules
            local cmp = require('cmp')
            local lspkind = require('lspkind')
            local luasnip_ok, luasnip = pcall(require, 'luasnip')

            -- autocomplete toggle
            vim.g.cmp_toggle = true
            vim.keymap.set('n', '<Leader>tc',
                function()
                    vim.g.cmp_toggle = not vim.g.cmp_toggle
                    local status
                    if vim.g.cmp_toggle then
                        status = 'enabled'
                    else
                        status = 'disabled'
                    end
                    vim.notify(('nvim-cmp %s'):format(status), vim.log.levels.INFO, { title = 'Completion' })
                end,
                { desc = 'toggle nvim-cmp' }
            )

            -- mappings
            local enter_mapping = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.confirm({ select = true })
                else
                    fallback()
                end
            end)

            -- tab completion behavior recommended by copilot-cmp
            local function has_words_before()
                if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' then return false end
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match('^%s*$') == nil
            end

            -- Super Tab: select next item or jump to next snipet or fallback
            local tab_mapping = cmp.mapping(function(fallback)
                if cmp.visible() and has_words_before() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                elseif luasnip_ok and luasnip.locally_jumpable(1) then
                    luasnip.jump(1)
                else
                    fallback()
                end
            end, { 'i', 's' })
            -- Shift-Tab: select previous item or fallback
            local stap_mapping = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                elseif luasnip_ok and luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' })

            return {
                enabled = function()
                    -- disable cmp on neo-tree and telescope buffers
                    local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
                    if buftype == 'prompt' then
                        return false
                    end
                    local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
                    if ft == 'neo-tree' or ft == 'TelescopePrompt' then
                        return false
                    end
                    return vim.g.cmp_toggle
                end,
                preselect = cmp.PreselectMode.None,
                completion = {
                    completeopt = 'menu,menuone,noinsert,noselect',
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = enter_mapping,
                    ['<Right>'] = cmp.mapping.confirm(),
                    ['<Tab>'] = tab_mapping,
                    ['<S-Tab>'] = stap_mapping,
                }),
                sources = cmp.config.sources(
                    { { name = 'nvim_lsp' }, { name = 'path' } }, -- priority 1
                    { { name = 'buffer' } }                       -- priority 2
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
                        -- maxwidth = 50,   -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        -- can also be a function to dynamically calculate max width such as
                        maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
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
        build = 'make install_jsregexp',
        dependencies = {
            {
                'rafamadriz/friendly-snippets',
                config = function()
                    require('luasnip.loaders.from_vscode').lazy_load()
                end,
            },
            {
                'hrsh7th/nvim-cmp',
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
    },
    -- vim command completion
    {
        'hrsh7th/cmp-cmdline',
        dependencies = { 'hrsh7th/nvim-cmp' },
        config = function()
            local cmp = require('cmp')

            local mapping = vim.tbl_deep_extend('force', cmp.mapping.preset.cmdline(), {
                ['<Right>'] = { c = cmp.mapping.confirm() },
            })

            -- Search (/, ?): use buffer words
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = mapping,
                sources = {
                    { name = 'buffer' },
                },
            })

            -- Commands (:): paths first, then command names
            cmp.setup.cmdline(':', {
                mapping = mapping,
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
