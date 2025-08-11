return {
    cmd = { 'clangd' },
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
