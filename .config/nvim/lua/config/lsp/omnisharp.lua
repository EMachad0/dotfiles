---@brief
---
--- https://github.com/omnisharp/omnisharp-roslyn
--- OmniSharp server based on Roslyn workspaces
---
--- `omnisharp-roslyn` can be installed by downloading and extracting a release from [here](https://github.com/OmniSharp/omnisharp-roslyn/releases).
--- OmniSharp can also be built from source by following the instructions [here](https://github.com/omnisharp/omnisharp-roslyn#downloading-omnisharp).
---
--- OmniSharp requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.
---
--- For `go_to_definition` to work fully, extended `textDocument/definition` handler is needed, for example see [omnisharp-extended-lsp.nvim](https://github.com/Hoffs/omnisharp-extended-lsp.nvim)
---
---

local util = require 'lspconfig.util'

---@type vim.lsp.Config
return {
    cmd = {
        vim.fn.executable('OmniSharp') == 1 and 'OmniSharp' or 'omnisharp',
        '-z', -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
        '--hostPID',
        tostring(vim.fn.getpid()),
        'DotNet:enablePackageRestore=false',
        '--encoding',
        'utf-8',
        '--languageserver',
    },
    filetypes = { 'cs', 'vb' },
    on_attach = function(_, bufnr)
        local keymap_options = { buffer = bufnr, silent = true }
        local function map(mode, lhs, rhs, desc)
            local lopts = vim.tbl_extend('force', keymap_options, { desc = desc })
            vim.keymap.set(mode, lhs, rhs, lopts)
        end

        local telescope_ok = pcall(require, 'telescope.builtin')
        if not telescope_ok then
            vim.notify(
                'omnisharp extended was not initiated because telescope is missing',
                vim.log.levels.WARN
            )
            return
        end

        -- Override shared LSP navigation only for OmniSharp buffers.
        map('n', '<leader>ld', function() require('omnisharp_extended').telescope_lsp_definition() end,
            'Go to Definition')
        map('n', '<leader>lt', function() require('omnisharp_extended').telescope_lsp_type_definition() end,
            'Type Definition')
        map('n', '<leader>li', function() require('omnisharp_extended').telescope_lsp_implementation() end,
            'Go to Implementation')
        map('n', '<leader>lr', function() require('omnisharp_extended').telescope_lsp_references() end,
            'Find References')
    end,
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        on_dir(
            util.root_pattern '*.slnx' (fname)
            or util.root_pattern '*.sln' (fname)
            or util.root_pattern '*.csproj' (fname)
            or util.root_pattern 'omnisharp.json' (fname)
            or util.root_pattern 'function.json' (fname)
        )
    end,
    init_options = {},
    capabilities = {
        workspace = {
            workspaceFolders = false, -- https://github.com/OmniSharp/omnisharp-roslyn/issues/909
        },
    },
    settings = {
        FormattingOptions = {
            -- Enables support for reading code style, naming convention and analyzer
            -- settings from .editorconfig.
            EnableEditorConfigSupport = true,
            -- Specifies whether 'using' directives should be grouped and sorted during
            -- document formatting.
            OrganizeImports = true,
        },
        MsBuild = {
            -- If true, MSBuild project system will only load projects for files that
            -- were opened in the editor. This setting is useful for big C# codebases
            -- and allows for faster initialization of code navigation features only
            -- for projects that are relevant to code that is being edited. With this
            -- setting enabled OmniSharp may load fewer projects and may thus display
            -- incomplete reference lists for symbols.
            LoadProjectsOnDemand = nil,
        },
        RoslynExtensionsOptions = {
            -- Enables support for roslyn analyzers, code fixes and rulesets.
            EnableAnalyzersSupport = true,
            -- Enables support for showing unimported types and unimported extension
            -- methods in completion lists. When committed, the appropriate using
            -- directive will be added at the top of the current file. This option can
            -- have a negative impact on initial completion responsiveness,
            -- particularly for the first few completion sessions after opening a
            -- solution.
            EnableImportCompletion = true,
            -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
            -- true
            AnalyzeOpenDocumentsOnly = nil,
            -- Enables the possibility to see the code in external nuget dependencies
            EnableDecompilationSupport = true,
        },
        RenameOptions = {
            RenameInComments = nil,
            RenameOverloads = nil,
            RenameInStrings = nil,
        },
        Sdk = {
            -- Specifies whether to include preview versions of the .NET SDK when
            -- determining which version to use for project loading.
            IncludePrereleases = true,
        },
    },
}
