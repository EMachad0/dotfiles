-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
-- vim.cmd [[packadd packer.nvim]]

-- automatically :PackerCompile whenever plugins.lua is updated
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Plugins
    
    -- Status Bar
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    require("lualine_config")

    -- Commenting
    use 'tpope/vim-commentary' -- Commenting with gcc & gc

    -- File Explorer
    use 'preservim/nerdtree' -- NerdTree
    use 'ryanoasis/vim-devicons' -- NerdTree Icons
    vim.cmd([[ let g:NERDTreeQuitOnOpen = 1 ]]) -- NerdTree Config

    -- Auto Save
    use 'Pocco81/auto-save.nvim'

    -- Syntax Highlighting
    use { 
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    require("treesitter_config")

    -- Theme
    use {
        "catppuccin/nvim",
        as = "catppuccin",
        config = function() 
            require("catppuccin").setup {
                flavour = "mocha",
                transparent_background = true,
                term_colors = true,
            }
            vim.api.nvim_command "colorscheme catppuccin"
        end
    }
end)

