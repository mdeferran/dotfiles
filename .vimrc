set nocompatible            " Disable compatibility to old-time vi
set showmatch               " Show matching brackets.
set ignorecase              " Do case insensitive matching
set mouse=v                 " middle-click paste with mouse
set hlsearch                " highlight search results
set tabstop=4               " number of columns occupied by a tab character
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set wildmode=longest,list   " get bash-like tab completions
set cc=80                   " set an 80 column border for good coding style

set noswapfile              " Don't use swapfile
set nobackup		    " Don't create annoying backup files
set nowritebackup
set splitright              " Split vertical windows right to the current windows
set splitbelow              " Split horizontal windows below to the current windows
set encoding=utf-8          " Set default encoding to UTF-8
set autowrite               " Automatically save before :next, :make etc.
set autoread                " Automatically reread changed files without asking me anything

set ttyfast
set lazyredraw                  " Wait to redraw "

" Ignore all kind of junk files or files we would not want to edit
set wildignore+=.DS_Store
set wildignore+=*.jpg,*.jpeg,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
set wildignore+=*.mp3,*.mp4,*.ogg,*.mkv
set wildignore+=*/vendor/*,*/.git/*,*/.hg/*,*/.svn/*,*/log/*,*/tmp/*,*/build/*,*/dist/*

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Copy highligh text to clipboard (CTRL-SHIFT V to paste to term)
vmap <C-c> "*y

" * Plugins vim-plug
" For NeoVim use call plug#begin('~/.local/share/nvim/plugged')
call plug#begin('~/.vim/plugged')

" BROWSE
" Vim-vinegar to navigate the filesystem, we dont really need Nerdtree
Plug 'tpope/vim-vinegar'

" ctrlp find them all
Plug 'ctrlpvim/ctrlp.vim'

" Trailing whitespace
Plug 'ntpeters/vim-better-whitespace'

" Comments
Plug 'tpope/vim-commentary'

" INTERFACE
" colorization
Plug 'iCyMind/NeoSolarized'

" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Start up screen
Plug 'mhinz/vim-startify'

" LANGUAGE HELPERS
" syntax checker
Plug 'w0rp/ale'

" Ansible plugin
Plug 'pearofducks/ansible-vim'

" Markdown support
Plug 'plasticboy/vim-markdown'

" PGP support
Plug 'jamessan/vim-gnupg'

" GIT
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" COMPLETION
" Deoplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Deoplete Python completion
Plug 'zchee/deoplete-jedi'

call plug#end()

" * Customize status line
let g:airline#extensions#tabline#enabled = 2
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#right_sep = ' '
let g:airline#extensions#tabline#right_alt_sep = '|'
let g:airline_left_sep = ' '
let g:airline_left_alt_sep = '|'
let g:airline_right_sep = ' '
let g:airline_right_alt_sep = '|'
let g:airline_theme= 'solarized'

" * Colorization
set termguicolors
silent! colorscheme NeoSolarized
set background=dark

" * Change leader key to ','
let mapleader=","

" * Shortcuts
" Disable Q ex-mode
nnoremap Q <Nop>

" Resume editing from Vim-Vinegar/NetRW
nnoremap <leader>q :Rex<CR>

" Go to next buffer
nnoremap <C-i> :bnext<CR>

" Go to previous buffer
nnoremap <C-u> :bprev<CR>

" Close quickfix easily
nnoremap <leader>c :cclose<CR>

" Move between windows
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Split windows
nnoremap <leader>j :sp<CR>
nnoremap <leader>l :vsp<CR>

" Maximize current window
nnoremap <C-m> <C-W>_

" Super search buffers with ctrlp
nnoremap <C-Home> :CtrlPLine<CR>

" Leader when editing a buffer
" ESC when double leader
inoremap <leader><leader> <Esc>

" Remove search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Fast saving
nmap <leader>w :w!<cr>

" Send the current line to ZSH
nnoremap <leader>r :.w !zsh<CR>

" Delete empty lines
nmap <leader>del :g/^[<C-I> ]*$/d<C-M>

" Delete comments
nmap <leader>cdel :g/^#.*$/d<C-M>

" Underline current line
nmap <leader>udl yyp:.s/./-/<C-M>

" Stay away from the Arrows keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" * ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = ''

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag --literal --files-with-matches --nocolor --hidden -g "" %s'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif

" * abbreviations
iab idate <c-r>=strftime("%F")<cr>

" * vim-markdown
" disable Markdown folding
let g:vim_markdown_folding_disabled=1

" * deoplete
let g:deoplete#enable_at_startup = 1
if !exists('g:deoplete#omni#input_patterns')
  let g:deoplete#omni#input_patterns = {}
endif
let g:deoplete#sources#jedi#python_path = '/usr/bin/python3'
" let g:deoplete#disable_auto_complete = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Python
let g:jedi#squelch_py_warning = 1
let g:jedi#force_py_version=3
autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#smart_auto_mappings = 0
let g:jedi#show_call_signatures = 0

let g:python_version = matchstr(system("python --version 2>&1 | cut -d' ' -f2"), '^[0-9]')
let s:uname = system("echo -n \"$(uname)\"")
if !v:shell_error && s:uname == "Linux"
  let g:has_pyenv = matchstr(system("command -v pyenv >/dev/null 2>&1; echo $?"), '0')
  if g:has_pyenv =~ 0
    if g:python_version =~ 3
      let g:python_host_prog = "/usr/bin/python2"
    else
      let g:python3_host_prog = "/usr/bin/python3"
    endif
  endif
else
  let g:has_pyenv = matchstr(system("command -v pyenv >/dev/null 2>&1; echo $?"), '0')
  if g:has_pyenv =~ 0
    if g:python_version =~ 3
      let g:python_host_prog = "/usr/local/bin/python2"
    else
      let g:python3_host_prog = "/usr/local/bin/python3"
    endif
  endif
endif

" YAML
autocmd FileType yaml set filetype=ansible

" TODO * pyflakes (not installed yet)
highlight SpellBad term=underline gui=undercurl guisp=Red
