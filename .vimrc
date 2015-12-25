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
Plugin 'scrooloose/syntastic'
Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdcommenter'

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
	colorscheme flatcolor
	" set guifont=AverageMono\ 14
	set guifont=monaco\ 14
endif
set number
set cul
set tabstop=4
set shiftwidth=4
set smarttab
filetype indent on
set filetype=html
set cindent
set showmatch
set autoindent
syntax on
let mapleader = ";"
set fileencodings=utf-8,gb2312,gbk,ucs-bom,cp936
set nocompatible
set ignorecase
autocmd BufEnter * silent! lcd %:p:h
filetype plugin indent on
autocmd BufNewFile,BufRead \*.{md,mdwn,mkd,mkdn,mark\*} set filetype=markdown

" read on kindle
let read_path='/var/www/html/readContent.html'
nnoremap <Space> :call ReadContentProcess()<CR>:w<CR>
autocmd BufEnter *  if (expand('%:p') == read_path) | set cb^=html | else | set cb-=html | endif
function ReadContentProcess()
	if (expand('%:p') == g:read_path)
		call feedkeys("\<C-A>")
		call feedkeys("\<C-V>")
	endif
endfunction

" save automatically when focus is lost
inoremap <Esc> <Esc>:w<CR>
" save on buffer switch
set autowriteall

nnoremap <F2> <C-w><C-w>
nnoremap <Tab> :b#<CR>
nnoremap <S-H> :bp<CR>
nnoremap <S-L> :bn<CR>

" automatically load the file's change content
set autoread

nnoremap <Leader>s :setlocal spell! spelllang=en_us<CR>
"---------------------My Customization------------------------

"---------------------ctags------------------------
" This will look in the current directory for "tags", and work up the tree towards root until one is found. IOW, you can be anywhere in your source tree instead of just the root of it.
set tags=./tags;/
"---------------------ctags------------------------

"---------------------TagBar------------------------
nmap <Leader>l :TagbarToggle<CR>
let g:tagbar_autofocus = 1
"---------------------TagBar------------------------

"---------------------YouCompleteMe------------------------
" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
" autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
"---------------------YouCompleteMe------------------------

"---------------------Syntastic------------------------
	set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
	set statusline+=%*

	let g:syntastic_always_populate_loc_list = 1
	let g:syntastic_auto_loc_list = 1
	let g:syntastic_check_on_open = 1
	let g:syntastic_check_on_wq = 0
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
nmap <leader>n :NERDTreeToggle<CR>
"---------------------NERDTree------------------------

"---------------------Ctrlp------------------------
 	let g:ctrlp_working_path_mode = 'ra'
"	let g:ctrlp_by_filename = 1
"	nnoremap <C-i> :CtrlP <C-r>=working_directory<CR><CR>
"---------------------Ctrlp------------------------
