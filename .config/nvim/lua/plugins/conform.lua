return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    lazy = true,
    keys = {}, -- configuration on shared.lua
    opts = {
        -- Define your formatters
        formatters_by_ft = {
            lua = { 'stylua', lsp_format = 'fallback' },

            rust = { 'rustfmt' },

            ruby = { 'rubocop' },

            -- JS/TS stack: prefer Prettier, then eslint_d
            javascript = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },
            javascriptreact = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },
            typescript = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },
            typescriptreact = { 'prettierd', 'prettier', 'eslint_d', stop_after_first = true },

            -- Other Prettier-supported filetypes
            json = { 'prettierd', 'prettier', stop_after_first = true },
            jsonc = { 'prettierd', 'prettier', stop_after_first = true },
            css = { 'prettierd', 'prettier', stop_after_first = true },
            scss = { 'prettierd', 'prettier', stop_after_first = true },
            html = { 'prettierd', 'prettier', stop_after_first = true },
            markdown = { 'prettierd', 'prettier', stop_after_first = true },
            yaml = { 'prettierd', 'prettier', stop_after_first = true },
            graphql = { 'prettierd', 'prettier', stop_after_first = true },
        },
        -- Set default options
        default_format_opts = {
            -- Use the lsp formatter for the filetype if no specific formatter is defined
            -- lsp_format = 'fallback',
        },
        -- Set up format-on-save
        -- format_on_save = { timeout_ms = 500 },
        -- Customize formatters
        formatters = {
        },
    },
    init = function()
        -- on formating with operators, use conform
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
