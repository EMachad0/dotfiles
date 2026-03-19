return {
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>lf',
            function() require('conform').format({ async = true }) end,
            mode = { 'n', 'v' },
            desc = 'Format',
        },
    },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
        formatters_by_ft = {
            lua = { 'stylua' },

            rust = { 'rustfmt' },

            ruby = { 'rubocop' },

            python = { 'ruff_format' },

            -- C/C++ family via clang-format
            c = { 'clang-format' },
            cpp = { 'clang-format' },
            objc = { 'clang-format' },
            objcpp = { 'clang-format' },
            cuda = { 'clang-format' },
            proto = { 'clang-format' },

            -- JS/TS stack: prefer Prettier, then eslint_d
            javascript = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },
            javascriptreact = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },
            typescript = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },
            typescriptreact = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },

            -- Other Prettier-supported filetypes
            json = { 'prettierd', 'prettier', 'jq', stop_after_first = true },
            jsonc = { 'prettierd', 'prettier', 'jq', stop_after_first = true },
            json5 = { 'prettierd', 'prettier', stop_after_first = true },
            css = { 'prettierd', 'prettier', stop_after_first = true },
            scss = { 'prettierd', 'prettier', stop_after_first = true },
            html = { 'prettierd', 'prettier', stop_after_first = true },
            svelte = { 'prettierd', 'prettier', stop_after_first = true },
            markdown = { 'prettierd', 'prettier', stop_after_first = true },
            yaml = { 'prettierd', 'prettier', stop_after_first = true },
            graphql = { 'prettierd', 'prettier', stop_after_first = true },

            -- C# formatting via OmniSharp LSP (installed with Mason)
            cs = { lsp_format = 'prefer' },
        },
        default_format_opts = {
            lsp_format = 'fallback',
        },
        formatters = {},
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        local wk_ok, wk = pcall(require, 'which-key')
        if wk_ok then
            wk.add({
                { '<leader>l', group = 'Formatter', mode = { 'n', 'v' } },
            })
        end
    end,
}
