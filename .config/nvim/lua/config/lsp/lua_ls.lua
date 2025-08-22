---@type vim.lsp.Config
return {
    settings = {
        Lua = {
            format = {
                enable = true,
                -- Put format options here
                -- NOTE: the value should be String!
                defaultConfig = {
                    -- example editor config: https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/lua.template.editorconfig
                    -- optional scpace/tab
                    indent_style = 'space',
                    -- if indent_style is tab, this is valid
                    indent_size = '4',
                    -- none/single/double
                    quote_style = 'single',
                }
            },
            ['diagnostics.neededFileStatus'] = {
                ['codestyle-check'] = 'Any',
            }
        }
    }
}
