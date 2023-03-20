" Show line numbers
set number
set relativenumber

" Blink cursor on error instead of beeping (grr)
set belloff=all

" Encoding
set encoding=utf-8

" Whitespace
set nowrap
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch

" Ident
filetype plugin indent on
set autoindent

" Plugins
lua require('plugins')

" Vibrant Colors
set termguicolors

" Remap
nnoremap <C-f> :NERDTreeToggle<CR>

" unmap f1
:nmap <F1> <nop>

" Go to last position when opening file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" NerdTree Config

