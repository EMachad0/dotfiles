-- Status bar
return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        -- Minimal, custom statusline for Neo-tree buffers only
        local neotree_extension = {
            sections = {
                lualine_a = {},
                lualine_b = { 'filetype' },
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            inactive_sections = {},
            filetypes = { 'neo-tree' },
        }

        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = 'catppuccin',
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = {},
                lualine_b = { 'branch', 'diff' },
                lualine_c = { 'filename' },
                lualine_x = { 'diagnostics' },
                lualine_y = { 'filetype' },
                lualine_z = {},
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = { neotree_extension },
        }
    end
}
