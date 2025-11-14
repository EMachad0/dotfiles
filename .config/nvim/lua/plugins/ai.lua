return {
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
            require('copilot').setup({
                -- disable commands as copilot will be used through cmp
                suggestion = { enabled = false },
                panel = { enabled = false },
            })
        end,
        keys = {
            { '<leader>ta', '<Cmd>Copilot toggle<cr>', desc = 'Toggle Copilot' },
        },
    },
    {
        'zbirenbaum/copilot-cmp',
        -- Ensure copilot and cmp are available first
        dependencies = {
            'zbirenbaum/copilot.lua',
            'hrsh7th/nvim-cmp',
            'onsails/lspkind.nvim',
        },
        event = 'InsertEnter',
        config = function()
            -- configure cmp + copilot-cmp when cmp is available
            local has_cmp, cmp = pcall(require, 'cmp')
            if has_cmp then
                -- initialize copilot-cmp
                require('copilot_cmp').setup()

                -- inject copilot into cmp sources (avoid duplicates)
                local sources = cmp.get_config().sources or {}
                local has_copilot = false
                for _, src in ipairs(sources) do
                    if src.name == 'copilot' then
                        has_copilot = true
                        break
                    end
                end
                if not has_copilot then
                    table.insert(sources, 1, { name = 'copilot', group_index = 1 })
                end

                -- Sorting comparators recommended by copilot-cmp
                local sorting = cmp.get_config().sorting or {}
                sorting.priority_weight = 2
                sorting.comparators = {
                    require('copilot_cmp.comparators').prioritize,
                    cmp.config.compare.offset,
                    -- cmp.config.compare.scopes, -- intentionally disabled per default
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                }

                cmp.setup({
                    sources = sources,
                    sorting = sorting,
                })
            end

            -- ensure lspkind shows a Copilot icon without touching lsp.lua
            local has_lspkind, lspkind = pcall(require, 'lspkind')
            if has_lspkind then
                lspkind.init({
                    symbol_map = { Copilot = '' },
                })
            end
        end,
    }
}
