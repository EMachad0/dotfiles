-- Detect if the workspace contains a Svelte project
local function is_svelte_project(root_dir)
    local util = require('lspconfig.util')
    if util.root_pattern('svelte.config.js', 'svelte.config.ts')(root_dir) then
        return true
    end
    return false
end

---@type vim.lsp.Config
return {
    cmd = { 'vtsls', '--stdio' },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    -- Plugins will be added dynamically in before_init
                },
            }
        },
    },
    root_dir = function(bufnr, on_dir)
        -- The project root is where the LSP can be started from
        -- this LSP supports monorepos and simple projects.
        -- We select then from the project root, which is identified by the presence of a package
        -- manager lock file.
        local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
        -- Give the root markers equal priority by wrapping them in a table
        root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers } or root_markers
        local project_root = vim.fs.root(bufnr, root_markers)
        if not project_root then
            return
        end

        on_dir(project_root)
    end,
    before_init = function(_, config)
        local mason_regisry = require('mason-registry')
        local mason_pkg_path = vim.fn.expand('$MASON') .. '/packages'

        local root_dir = config.root_dir
        if not root_dir or root_dir == '' then return end

        local plugins = {}
        if is_svelte_project(root_dir) then
            if mason_regisry.is_installed('svelte-language-server') then
                table.insert(plugins, {
                    name = 'typescript-svelte-plugin',
                    location = mason_pkg_path .. '/svelte-language-server/node_modules/typescript-svelte-plugin',
                    enableForWorkspaceTypeScriptVersions = true,
                })
            end
        end

        config.settings.vtsls['tsserver'].globalPlugins = plugins
    end,
}
