"----------------Vundle--------------
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/nerdtree'
Plugin 'mattn/emmet-vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'rking/ag.vim'
Plugin 'vim-scripts/mru.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'edsono/vim-matchit'
Plugin 'mhinz/vim-startify'
Plugin 'tpope/vim-surround'
Plugin 'digitaltoad/vim-jade'
Plugin 'lambdalisue/vim-fullscreen'
Plugin 'Chiel92/vim-autoformat'
Plugin 'reedes/vim-colors-pencil'
Plugin 'bling/vim-airline'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-colorscheme-switcher'
Plugin 'flazz/vim-colorschemes'
Plugin 'schickling/vim-bufonly'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'easymotion/vim-easymotion'
Plugin 'mbbill/undotree'
Plugin 'yegappan/mru'
Plugin 'tpope/vim-fugitive'
Plugin 'docunext/closetag.vim'
Plugin 'majutsushi/tagbar'
" Plugin 'scrooloose/syntastic'
Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdcommenter'
Plugin 'szw/vim-maximizer'
Plugin 'SirVer/ultisnips'
Plugin 'Crapworks/python_fn.vim'
Plugin 'file:///home/searene/Development/MarkdownToImgur'
"Plugin 'searene/pyvim'
"Plugin 'klen/python-mode'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"---------------------Vundle------------------------


"---------------------My Customization------------------------
if has("gui_running")
	" remove toolbar
	set guioptions-=T
	set guioptions-=r
	set guioptions-=L
	" remove menu
	set guioptions-=m 
	" colorscheme mac_classic
	colorscheme mayansmoke
	set guifont=monaco\ 16
	"set guifont=ubuntu\ mono\ 16
endif
set number
set cul
set tabstop=4
set shiftwidth=4
set smarttab
set cindent
set showmatch
set autoindent
syntax on
set fileencodings=utf-8,gb2312,gbk,ucs-bom,cp936
set nocompatible
set ignorecase
set smartcase
let mapleader=";"
" disable q:, it caused me a lot of trouble
nnoremap q: :q
nnoremap Q :q<CR>

" change the current working directory to the directory which contains the
" current file
nnoremap <Leader>cd :cd %:p:h<CR>:pwd<CR>

"autocmd BufEnter * silent! lcd %:p:h
autocmd BufNewFile,BufRead \*.{md,mdwn,mkd,mkdn,mark\*} set filetype=markdown
nnoremap <c-x> :q<CR>

command! Ctags !cd $HOME&&ctags -R $HOME/Development/languagezone_project $HOME/.virtualenvs/languagezone_dev /usr/lib/python3.4
" change path for languagezone project
set path+=$HOME/.virtualenvs/languagezone_dev,/lib/python3.4/site-packages,$HOME/.local/lib/python3.4/site-packages
" Search the whole project with Ag
command! -nargs=1 AgProject :Ag <args> /home/searene/Development/languagezone_project /home/searene/.virtualenvs/languagezone_dev /usr/lib/python3.4

" add html metadata to readContent.html so it can be read more easily on kindle
au BufEnter * if(expand('%:t') == 'readContent.html') | set cb^=html | else | set cb-=html | endif

noremap <F12> :!xclip -selection clipboard -o -t text/html > /var/www/html/readContent.html<CR>
" save automatically when text is changed
set updatetime=200
"au InsertLeave * silent! write
au CursorHold * silent! update
"inoremap <Esc> <Esc>:silent! update<CR>

" tell it to use an undo file
set undofile
" set a directory to store the undo history
set undodir=$HOME/.vim/.vimundo/

nnoremap , <C-w><C-w>
map <S-H> :update<CR>:bp<CR>
map <S-Y> :update<CR>:b#<CR>
map <S-L> :update<CR>:bn<CR>

set list
set listchars=eol:⏎,tab:␉·,trail:␠,nbsp:⎵
" automatically load the file's change content
set autoread
nnoremap <Leader>s :setlocal spell! spelllang=en_us<CR>

" This will look in the current directory for "tags", and work up the tree towards root until one is found. IOW, you can be anywhere in your source tree instead of just the root of it.
set tags=./tags;/,$HOME/tags
set noswapfile

" toggle QuickFix window
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction
nmap <silent> <Leader>q :QFix<CR>

"---------------------My Customization------------------------


"---------------------ultisnips------------------------
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-l>"
let g:UltiSnipsJumpBackwardTrigger="<c-h>"
let g:UltiSnipsListSnippets="<c-k>"
let g:UltiSnipsSnippetDirectories=["UltiSnips"]
"List possible snippets based on current file

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
"---------------------ultisnips------------------------


"---------------------vim-maximizer------------------------
nnoremap <Leader>m :MaximizerToggle!<CR>
"---------------------vim-maximizer------------------------


"---------------------TagBar------------------------
nmap <Leader>l :TagbarToggle<CR>
let g:tagbar_autofocus = 1
"---------------------TagBar------------------------


"---------------------YouCompleteMe------------------------
" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

let g:ycm_collect_identifiers_from_tags_files = 1 " Let YCM read tags from Ctags file
let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
let g:ycm_complete_in_comments = 1 " Completion in comments
let g:ycm_complete_in_strings = 1 " Completion in string
"let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
"---------------------YouCompleteMe------------------------


"---------------------Syntastic------------------------
"	set statusline+=%#warningmsg#
"	set statusline+=%{SyntasticStatuslineFlag()}
"	set statusline+=%*
"
"	let g:syntastic_always_populate_loc_list = 1
"	let g:syntastic_auto_loc_list = 1
"	let g:syntastic_check_on_open = 1
"	let g:syntastic_check_on_wq = 0
"---------------------Syntastic------------------------


"---------------------Ag------------------------
" run from the project rootdirectory
  let g:ag_working_path_mode='r'
"---------------------Ag------------------------


"---------------------Airline------------------------
  set laststatus=2
  let g:airline#extensions#tabline#enabled = 1
"---------------------Airline------------------------


"---------------------NERDTree------------------------
" open NERDTree when vim starts
" autocmd vimenter * NERDTree
" close vim if the only window left is NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
nnoremap <Leader>n :NERDTreeToggle<CR>
"---------------------NERDTree------------------------


"---------------------Ctrlp------------------------
 	let g:ctrlp_working_path_mode = 'r'
"	let g:ctrlp_by_filename = 1
" ---------------------Ctrlp------------------------

function! HelloVim()
	echo "Hello Vim"
endfunction

function! HelloPython()
python << endPython
print("Hello Python")
endPython
endfunction
