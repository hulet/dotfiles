" ~/.vimrc
"
"

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" taglist plugin settings
"let Tlist_Ctags_Cmd = '/apollo/env/envImprovement/bin/ctags'
"let Tlist_Inc_Winwidth = 0
nnoremap <silent> <F8> :TlistToggle<CR>

" toggles
noremap <leader>ts :set spell!<CR>
noremap <leader>tw :set wrap!<CR>
noremap <leader>tp :set paste!<CR>
noremap <leader>tn :set number!<CR>
noremap <leader>tl :TlistToggle<CR>
noremap <leader><space> :noh<CR>

" left align
noremap <leader>l :s/^\s\+//<CR>

" http://items.sjbach.com/319/configuring-vim-right
" Typing 'a will jump to the line in the current file marked with ma.
" However, `a will jump to the line and column marked with ma.
" It's more useful in any case I can imagine, but it's located way off in the
" corner of the keyboard. The best way to handle this is just to swap them:
nnoremap ' `
nnoremap ` '

" colors
highlight DiffAdd term=reverse cterm=bold ctermbg=green ctermfg=black
highlight DiffChange term=reverse cterm=bold ctermbg=cyan ctermfg=black
highlight DiffText term=reverse cterm=bold ctermbg=yellow ctermfg=black
highlight DiffDelete term=reverse cterm=bold ctermbg=red ctermfg=black 
highlight Search term=reverse cterm=bold ctermbg=magenta ctermfg=black 
highlight LineNr term=reverse ctermbg=DarkGray ctermfg=Gray 
"colorscheme Tomorrow-Night
"syntax enable
"set background=dark
"colorscheme solarized

"set autoindent              " always set autoindenting on (do we want this?)
"set smartindent
"set smarttab
set cindent
set backspace=2             " allow backspacing over everything in insert mode
set diffopt=filler,iwhite   " for vimdiff (add scrollbind if needed)
set expandtab               " Get rid of tabs altogether and replace with spaces
"set foldcolumn=2           " set a column incase we need it (err on don't show)
set foldlevel=0             " all folds closed
set foldmethod=indent       " use indentation to detrmine fold location
set guioptions-=m           " Remove menu from the gui
set guioptions-=T           " Remove toolbar
"set hidden                 " hide buffers instead of closing
set history=50              " keep 50 lines of command line history
set ignorecase              " Do case insensitive matching
set incsearch               " show partal match as searching strings are typed
set laststatus=1            " status bar only on multipule windows
"set linebreak               " This displays long lines as wrapped at word boundries (breaks copying long lines from terminal)
set matchtime=2             " Time to flash the brack with showmatch
set modeline                " Look for modelines
set modelines=1000          " Check this many lines for a modeline
"set nobackup               " Don't keep a backup file
set nofen                   " disable folds
"set notimeout              " i like to be pokey
"set nottimeout             " take as long as i like to type commands
set ruler                   " show the cursor position all the time
set scrolloff=4             " dont let the curser get too close to the edge
set shiftwidth=4            " Set indention level to be the same as softtabstop
"set showbreak=+++           " String to put at the start of lines that have been wrapped (breaks copying long lines from terminal)
set showcmd                 " Show (partial) command in status line.
set showmatch               " Show matching brackets.
set softtabstop=4           " Why are tabs so big?  This fixes it
set tabstop=4               " Why are tabs so big?  This fixes it
"set textwidth=0            " Don't wrap words by default
"set textwidth=80           " This wraps a line with a break when you reach 80 chars
"set timeoutlen=10000       " Time to wait for a map sequence to complete
"set ttimeoutlen=10000      " time to wait for a key code to complete
set ttyfast
"set virtualedit=block      " let blocks be in virutal edit mode (not sure what this does)
set wildmenu                " This is used with wildmode(full) to cycle options
set wildmode=list:longest,full      " list all options, match to the longest

set showmode                " display the current mode in the status line
set smartcase               " if search has any caps, do case sensetive search
set matchpairs+=<:>         " have % bounce between <, >, as well as t'other kinds
set hlsearch                " highlight the last used search pattern

set nowrap                  " don't wrap long lines
set sidescroll=10                       " sidescroll this many lines at a time
set listchars=extends:>,precedes:<      " display these when long lines leave the screen
set sidescrolloff=4                     " keep a buffer of this many chars on the sides
set report=0                            " always tell me when something happens, if even to just 1 line

set cinkeys-=0#                     " don't force perl comments to the beginning of the line
au FileType c,cpp set cinkeys+=0#   " except when they're pre-processor directives in c/c++
":inoremap # X#                   " this prolly does the same thing?
set nrformats=              "C-A and C-X should only work on decimal numbers

"Turn on syntax highlighting
syntax on


set viminfo='20,<500,s100,h     " see :help 'viminfo' (with the quotes); default is '20,<50,s10,h

filetype plugin on          " allow plugin files (:h filetype-plugin)
filetype indent on          " allow indent files (:h filetype-indent)

" from https://github.com/johnhamelink/blade.vim/blob/master/ftdetect/blade.vim
"autocmd BufNewFile,BufReadPost *.blade.php set filetype=blade

" mason stuff
"au syntax mason so /usr/share/vim/vim63/syntax/mason.vim
"au BufNewFile,BufRead *.mas set ft=mason
"
au BufNewFile,BufRead *.rthm set ft=eruby
au BufNewFile,BufRead *.rthml set ft=eruby
au BufNewFile,BufRead *.rjs set ft=eruby
au BufNewFile,BufRead *.rxml set ft=eruby
au BufNewFile,BufRead *.rake set ft=ruby

" Use ;c to change the current buffer's local directory to the directory containing the file
map ;c :execute ":lcd ". expand("%:h")<CR>

" Use ;f to capture the current file name's full file name into the buffer f
map ;f :let @f=expand("%:p")<CR>

" Use ,o to open a window in the directory of the file currently being edited.
map ,o :execute ":e " . expand("%:p:h")<CR>
map ,O :execute ":new " . expand("%:p:h")<CR>

" Use ,e to start an execute command to edit a file in the directory of the file currently being edited.
map ,e :let @i = expand("%:p:h"):e <C-R>i/
map ,E :let @i = expand("%:p:h"):new <C-R>i/

" from http://stackoverflow.com/questions/1889596/vim-mappable-unused-shortcut-letters
"imap ,, <ESC>
"

" https://coderwall.com/p/faceag
com! FormatJSON %!python -m json.tool
" https://github.com/elzr/vim-json
let g:vim_json_syntax_conceal = 0


" http://stackoverflow.com/questions/3105307/how-do-you-automatically-remove-the-preview-window-after-autocompletion-in-vim
" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0 && bufname("%") != "[Command Line]"|pclose|endif
autocmd InsertLeave * if pumvisible() == 0 && bufname("%") != "[Command Line]"|pclose|endif
" http://stackoverflow.com/questions/2269005/how-can-i-change-the-keybinding-used-to-autocomplete-in-vim
inoremap <Nul> <C-x><C-o>

" https://github.com/tpope/vim-pathogen
" http://stackoverflow.com/questions/18576651/check-whether-pathogen-is-installed-in-vimrc
if filereadable(expand("~/.vim/autoload/pathogen.vim"))
    execute pathogen#infect()
endif


