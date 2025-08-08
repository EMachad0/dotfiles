return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                -- disable commands as copilot will be used through cmp
                suggestion = { enabled = false },
                panel = { enabled = false },
            })
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        -- Ensure copilot and cmp are available first
        dependencies = {
            "zbirenbaum/copilot.lua",
            "hrsh7th/nvim-cmp",
            "onsails/lspkind.nvim",
        },
        event = "InsertEnter",
        config = function()
            -- initialize copilot-cmp
            require("copilot_cmp").setup()

            -- safely inject copilot into cmp sources after cmp is loaded
            local has_cmp, cmp = pcall(require, "cmp")
            if has_cmp then
                local sources = cmp.get_config().sources or {}
                table.insert(sources, 1, { name = "copilot" })
                cmp.setup({ sources = sources })
            end

            -- ensure lspkind shows a Copilot icon without touching lsp.lua
            local has_lspkind, lspkind = pcall(require, "lspkind")
            if has_lspkind then
                lspkind.init({
                    symbol_map = { Copilot = "" },
                })
            end
        end,
    }
}
