-- Shared LSP helpers: keymaps (on_attach) and capabilities

-- Copy diagnostics helpers used by on_attach
local function copy_line_diagnostics()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
    if #diagnostics == 0 then
        vim.notify('No diagnostics on current line', vim.log.levels.INFO)
        return
    end
    local messages = {}
    for _, diagnostic in ipairs(diagnostics) do
        table.insert(messages, diagnostic.message)
    end
    local text = table.concat(messages, '\n')
    vim.fn.setreg('+', text)
    vim.notify('Copied line diagnostics to clipboard', vim.log.levels.INFO)
end

local function copy_file_diagnostics()
    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics == 0 then
        vim.notify('No diagnostics in file', vim.log.levels.INFO)
        return
    end
    local messages = {}
    for _, diagnostic in ipairs(diagnostics) do
        local line_number = diagnostic.lnum + 1
        table.insert(messages, string.format('%d:%d: %s', line_number, diagnostic.col + 1, diagnostic.message))
    end
    local text = table.concat(messages, '\n')
    vim.fn.setreg('+', text)
    vim.notify('Copied file diagnostics to clipboard', vim.log.levels.INFO)
end

local function on_attach(_, bufnr)
    -- diagnostic config (use vim.diagnostic.config for signs)
    local severity = vim.diagnostic.severity
    vim.diagnostic.config({
        virtual_text = true, -- shows inline messages
        underline = true,    -- underlines the words
        signs = {
            text = {
                [severity.ERROR] = '✘ ',
                [severity.WARN]  = '▲ ',
                [severity.HINT]  = '⚑ ',
                [severity.INFO]  = ' ',
            },
        },
        update_in_insert = false,
    })

    -- Set up which-key LSP keymap group
    local wk_ok, wk = pcall(require, 'which-key')
    if wk_ok then
        wk.add({
            { '<leader>l',  group = 'Lsp',       mode = { 'n', 'v' } },
            { '<leader>lw', group = 'Workspace', mode = { 'n' } },
        })
    end

    -- keymaps
    local keymap_options = { buffer = bufnr, silent = true }

    local function map(mode, lhs, rhs, desc)
        local lopts = vim.tbl_extend('force', keymap_options, { desc = desc })
        vim.keymap.set(mode, lhs, rhs, lopts)
    end

    -- Try to load telescope for some LSP actions
    local telescope_ok, tbuiltin = pcall(require, 'telescope.builtin')

    -- Try to load actions-preview for code actions
    local actions_preview_ok, actions_preview = pcall(require, 'actions-preview')

    -- LSP core actions
    map('n', '<leader>lh', vim.lsp.buf.hover, 'Display Hover')
    map('n', '<leader>lR', vim.lsp.buf.rename, 'Rename')
    if actions_preview_ok then
        map({ 'v', 'n' }, '<leader>la', actions_preview.code_actions, 'Code Actions')
    else
        map({ 'v', 'n' }, '<leader>la', vim.lsp.buf.code_action, 'Code Actions')
    end

    -- Go to/peek
    map('n', '<leader>ld', vim.lsp.buf.definition, 'Go to Definition')
    map('n', '<leader>lD', vim.lsp.buf.declaration, 'Go to Declaration')
    map('n', '<leader>lt', vim.lsp.buf.type_definition, 'Type Definition')
    map('n', '<leader>li', vim.lsp.buf.implementation, 'Go to Implementation')
    map('n', '<leader>lk', vim.lsp.buf.signature_help, 'Signature Help')

    -- References (Telescope if available)
    if telescope_ok then
        map('n', '<leader>lr', tbuiltin.lsp_references, 'Find References')
    else
        map('n', '<leader>lr', vim.lsp.buf.references, 'Find References')
    end

    -- Diagnostics
    map('n', '<leader>le', vim.diagnostic.open_float, 'Float line Diagnostics')
    map('n', '<leader>l[', function() vim.diagnostic.jump({ count = -1, float = true }) end,
        'Diagnostics: Previous')
    map('n', '<leader>l]', function() vim.diagnostic.jump({ count = 1, float = true }) end,
        'Diagnostics: Next')
    map('n', '<leader>ly', copy_line_diagnostics, 'Copy Line Diagnostics')
    map('n', '<leader>lY', copy_file_diagnostics, 'Copy File Diagnostics')

    -- Symbols (Telescope if available)
    if telescope_ok then
        map('n', '<leader>ls', tbuiltin.lsp_document_symbols, 'Document Symbols')
        map('n', '<leader>lS', tbuiltin.lsp_dynamic_workspace_symbols, 'Workspace Symbols')
    else
        map('n', '<leader>ls', vim.lsp.buf.document_symbol, 'LSP: Document Symbols')
        map('n', '<leader>lS', vim.lsp.buf.workspace_symbol, 'LSP: Workspace Symbols')
    end

    -- Workspace folders
    map('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder')
    map('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder')
    map('n', '<leader>lwl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, 'Workspace List Folders')

    -- Formatting is handled by conform.nvim
    map({ 'n', 'v' }, '<leader>lf', function()
        require('conform').format({ async = true })
    end, 'Format')
end

local function make_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp = pcall(require, 'cmp_nvim_lsp')
    if ok then capabilities = cmp.default_capabilities(capabilities) end
    return capabilities
end

return {
    on_attach = on_attach,
    make_capabilities = make_capabilities,
}
