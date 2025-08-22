---@type vim.lsp.Config
return {
    -- Force a single position/offset encoding to avoid mixed-client warnings
    cmd = { 'clangd', '--offset-encoding=utf-16' },
    capabilities = { offsetEncoding = { 'utf-16' } },
    init_options = {
        clangdFileStatus = true,
        clangdSemanticHighlighting = true,
    },
    filetypes = { 'c', 'cpp', 'cxx', 'cc' },
    root_dir = function() vim.fn.getcwd() end,
    settings = {
        ['clangd'] = {
            ['compilationDatabasePath'] = 'build',
            ['fallbackFlags'] = { '-std=c++17' }
        }
    }
}
