return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = {
        { "<leader>n", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    init = function()
        if vim.fn.argc(-1) == 1 then
            local stat = vim.uv.fs_stat(vim.fn.argv(0))
            if stat and stat.type == "directory" then
                require("neo-tree")
            end
        end
    end,
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function(_)
                        -- Command to close NeoTree when a file is opened
                        require('neo-tree').close_all()
                    end
                },
            },
            filesystem = {
                filtered_items = {
                    visible = true, -- Show hidden files by default
                },
                use_libuv_file_watcher = true, -- Enable if you want live updates
                follow_current_file = {
                    enabled = true,
                }
            },
        })
    end,
}

