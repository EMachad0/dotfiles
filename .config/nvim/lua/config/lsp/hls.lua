return function()
    require 'lspconfig'.hls.setup {
        settings = {
            haskell = {
                formattingProvider = 'fourmolu'
            }
        }
    }
end
