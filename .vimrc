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
Plugin 'vim-scripts/vim-auto-save'
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
Plugin 'oplatek/Conque-Shell'
Plugin 'mbbill/undotree'
Plugin 'yegappan/mru'
Plugin 'vim-scripts/taglist.vim'
Plugin 'tpope/vim-fugitive'

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

set number
set cul
set tabstop=4
set shiftwidth=4
set smarttab
filetype indent on
set filetype=html
set smartindent
set showmatch
set autoindent
syntax on
set fileencodings=utf-8,gb2312,gbk,ucs-bom,cp936
set nocompatible
set ignorecase
autocmd BufEnter * silent! lcd %:p:h
filetype plugin indent on
set tags=tags;
autocmd BufNewFile,BufRead \*.{md,mdwn,mkd,mkdn,mark\*} set filetype=markdown
autocmd BufEnter *  if (expand('%:p') == '/var/www/html/public/read.html') | set cb^=html | else | set cb-=html | endif
nnoremap <F3> <C-w><C-w>
nnoremap <Tab> :b#<CR>


" use system clipboard
" set clipboard=unnamedplus

"  $nnoremap html :set cb^=html<CR>"+p:set cb-=html<CR>
" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
" autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif


" Ag {
" run from the project rootdirectory
  let g:ag_working_path_mode='r'
" }

" airline {
  set laststatus=2
  let g:airline#extensions#tabline#enabled = 1
" }
" NERDTree {
" open NERDTree when vim starts
" autocmd vimenter * NERDTree
" close vim if the only window left is NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
map <F2> :NERDTreeToggle<CR>

" }

" ctrlp {
 	let g:ctrlp_working_path_mode = 'ra'
"	let g:ctrlp_by_filename = 1
"	nnoremap <C-i> :CtrlP <C-r>=working_directory<CR><CR>
" }
" auto_save {
	let g:auto_save = 1  " enable AutoSave on Vim startup
	let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
" }
"setlocal spell spelllang=en_us

"-------------------------------------------------------------------------
" Set options and add mapping such that Vim behaves a lot like MS-Windows
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2006 Apr 02

" bail out if this isn't wanted (mrsvim.vim uses this).
"
" backspace and cursor keys wrap to previous/next line
" CTRL-C and CTRL-Insert are Copy
" CTRL-V and SHIFT-Insert are Paste
" Use CTRL-Q to do what CTRL-V used to do
" Use CTRL-S for saving, also in Insert mode
" Alt-Space is System menu
" CTRL-A is Select all

if exists("g:skip_loading_mswin") && g:skip_loading_mswin
finish
endif

" set the 'cpoptions' to its Vim default
if 1	" only do this when compiled with expression evaluation
let s:save_cpo = &cpoptions
endif
set cpo&vim

" set 'selection', 'selectmode', 'mousemodel' and 'keymodel' for MS-Windows
behave mswin

" backspace and cursor keys wrap to previous/next line
set backspace=indent,eol,start whichwrap+=<,>,[,]

" backspace in Visual mode deletes selection
vnoremap <BS> d

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y

" CTRL-V and SHIFT-Insert are Paste
map <C-V>		"+gP
cmap <C-V>		<C-R>+

" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
" Uses the paste.vim autoload script.

exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']

imap <S-Insert>		<C-V>
vmap <S-Insert>		<C-V>

" Use CTRL-Q to do what CTRL-V used to do
noremap <C-Q>		<C-V>

" For CTRL-V to work autoselect must be off.
" On Unix we have two selections, autoselect can be used.
if !has("unix")
set guioptions-=a
endif

colorscheme desert

" Alt-Space is System menu
if has("gui_running")
" pencil corlorscheme {
"	set background=light
"	let g:pencil_higher_contrast_ui = 1
"}
set guioptions-=T
set guioptions-=r
set guioptions-=L
set guifont=Anonymous\ Pro\ 16
noremap <M-Space> :simalt ~<CR>
inoremap <M-Space> <C-O>:simalt ~<CR>
cnoremap <M-Space> <C-C>:simalt ~<CR>
endif

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G
onoremap <C-A> <C-C>gggH<C-O>G
snoremap <C-A> <C-C>gggH<C-O>G
xnoremap <C-A> <C-C>ggVG

" restore 'cpoptions'
set cpo&
if 1
let &cpoptions = s:save_cpo
unlet s:save_cpo
endif
