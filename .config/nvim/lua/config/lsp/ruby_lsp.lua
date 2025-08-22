---@type vim.lsp.Config
return {
    cmd = { vim.fn.expand('~/.asdf/shims/ruby-lsp') },
    filetypes = { 'ruby' },
    root_markers = { 'Gemfile', '.git' },
    init_options = {
        addonSettings = {
            ['Ruby LSP Rails'] = {
                enablePendingMigrationsPrompt = false,
            },
        },
    },
}
