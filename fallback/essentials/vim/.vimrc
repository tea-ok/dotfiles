" ============================================================
" ~/.vimrc — minimal-but-usable Vim, mirroring Neovim setup
" ============================================================

" Always load portable vi baseline first
source ~/.exrc

" ============================================================
" 1. Vundle bootstrap
" ============================================================
let vundle_dir = expand('~/.vim/bundle/Vundle.vim')
let vundle_fresh = 0

if !isdirectory(vundle_dir)
  silent execute '!git clone --depth=1 https://github.com/VundleVim/Vundle.vim.git ' . vundle_dir
  let vundle_fresh = 1
endif

set nocompatible
filetype off
execute 'set rtp+=' . vundle_dir
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'catppuccin/vim', {'name': 'catppuccin'}
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'preservim/nerdtree'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'jiangmiao/auto-pairs'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-surround'
Plugin 'itchyny/lightline.vim'

call vundle#end()
filetype plugin indent on
syntax enable

if vundle_fresh
  PluginInstall
endif

" ============================================================
" 2. Options
" ============================================================
set encoding=utf-8

" Appearance
set termguicolors
set number
set relativenumber
set numberwidth=4
set signcolumn=yes
set wrap
set scrolloff=4
set sidescrolloff=4
set laststatus=2
set noshowmode

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Editing
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set smartindent
set autoindent

" Splits
set splitbelow
set splitright

" Persistence
set undofile
set undodir=~/.vim/undo//
set noswapfile
set nobackup
set nowritebackup

" Interaction
set mouse=a
set timeoutlen=1000
set updatetime=300
set hidden
set completeopt=menuone,noselect
set pumheight=10
set clipboard=unnamedplus

" Don't auto-continue comments on newline (mirrors Neovim autocmd)
augroup FormatOptions
  autocmd!
  autocmd BufEnter * if &modifiable | setlocal formatoptions-=cro | endif
augroup END

" Ensure undo directory exists
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p')
endif

" ============================================================
" 3. Colorscheme
" ============================================================
if !empty(glob('~/.vim/bundle/catppuccin'))
  colorscheme catppuccin_frappe
endif

" ============================================================
" 4. Statusline — lightline with catppuccin_frappe
" ============================================================
let g:lightline = {
      \ 'colorscheme': 'catppuccin_frappe',
      \ 'active': {
      \   'left':  [['mode', 'paste'], ['readonly', 'filename', 'modified']],
      \   'right': [['lineinfo'], ['percent'], ['filetype']]
      \ },
      \ }

" ============================================================
" 5. Leader
" ============================================================
let mapleader = " "
let maplocalleader = " "
noremap <Space> <Nop>

" ============================================================
" 6. Keymaps
" ============================================================

" H/L = line start/end (all modes; supersedes .exrc normal-only map)
noremap  H ^
noremap  L $
vnoremap H ^
vnoremap L $
onoremap H ^
onoremap L $

" Disable Ex mode
nnoremap Q <Nop>

" Clear search highlight
nnoremap <silent> <Esc> :nohlsearch<CR>

" Page down/up with cursor centering
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Window navigation (vim-tmux-navigator overrides these when in tmux)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>
nnoremap <leader>x :bdelete<CR>

" Move visual selection up/down
xnoremap J :move '>+1<CR>gv=gv
xnoremap K :move '<-2<CR>gv=gv

" Paste in visual without clobbering unnamed register
xnoremap p "_dP

" Window resize
nnoremap <C-Up>    :resize +1<CR>
nnoremap <C-Down>  :resize -1<CR>
nnoremap <C-Left>  :vertical resize -1<CR>
nnoremap <C-Right> :vertical resize +1<CR>

" File explorer
nnoremap <leader>e :NERDTreeToggle<CR>

" Fuzzy finding
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fw :Rg<CR>

" Git hunk navigation
nnoremap ]c :GitGutterNextHunk<CR>
nnoremap [c :GitGutterPrevHunk<CR>
nnoremap <leader>hp :GitGutterPreviewHunk<CR>
nnoremap <leader>hr :GitGutterUndoHunk<CR>

" ============================================================
" 7. fzf — Homebrew installation
" ============================================================
set rtp+=/opt/homebrew/opt/fzf

" ============================================================
" 8. NERDTree
" ============================================================
let NERDTreeShowHidden = 1
let NERDTreeMinimalUI  = 1
let NERDTreeQuitOnOpen = 0

" Quit Vim if NERDTree is the only window left
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1
      \ && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Direct keybinds matching nvim-tree muscle memory
autocmd FileType nerdtree nnoremap <buffer> a :call NERDTreeAddNode()<CR>
autocmd FileType nerdtree nnoremap <buffer> d :call NERDTreeDeleteNode()<CR>
autocmd FileType nerdtree nnoremap <buffer> r :call NERDTreeRenameNode()<CR>

" ============================================================
" 8b. auto-pairs — disable in non-modifiable buffers (e.g. NERDTree)
" ============================================================
autocmd BufEnter * if !&modifiable | let b:AutoPairs = {} | endif

" ============================================================
" 9. vim-gitgutter
" ============================================================
let g:gitgutter_sign_added            = '+'
let g:gitgutter_sign_modified         = '~'
let g:gitgutter_sign_removed          = '-'
let g:gitgutter_sign_modified_removed = '~-'

" ============================================================
" 10. Filetype-specific indent (html/css/js/lua → 2 spaces)
" ============================================================
augroup FileTypeIndent
  autocmd!
  autocmd FileType html,css,javascript,lua setlocal shiftwidth=2 tabstop=2 softtabstop=2
augroup END

" ============================================================
" 11. Yank highlight
" ============================================================
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! call s:YankHighlight()
augroup END

function! s:YankHighlight() abort
  if exists('*matchaddpos') && v:event['operator'] ==# 'y'
    let m = matchadd('IncSearch',
          \ '\%' . line("'[") . 'l\%' . col("'[") . 'c\_.*\%'
          \ . line("']") . 'l\%' . col("']") . 'c', 10, -1)
    let s:yank_match_id = m
    augroup YankHighlightClear
      autocmd!
      autocmd CursorMoved * call s:ClearYankHighlight()
    augroup END
  endif
endfunction

function! s:ClearYankHighlight() abort
  if exists('s:yank_match_id')
    silent! call matchdelete(s:yank_match_id)
    unlet s:yank_match_id
  endif
  autocmd! YankHighlightClear
endfunction
