-- comment with gc & gcc
return {
    'numToStr/Comment.nvim',
    lazy = false,
    config = function()
        require('Comment').setup()
    end,
}

