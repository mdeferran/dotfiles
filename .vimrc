" Modern Vim/Neovim configuration for Ubuntu 24.04/25.04
" Using lazy.nvim for reproducible plugin management

" Basic settings
set nocompatible
set encoding=utf-8
set mouse=a          " Enable mouse: left-click to select, middle-click to paste
set ttyfast
set lazyredraw

" Display
set number relativenumber
set showmatch
set hlsearch
set cc=100
set signcolumn=yes

" Indentation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

" File handling
set noswapfile
set nobackup
set nowritebackup
set autowrite
set autoread

" Splits
set splitright
set splitbelow

" Search
set ignorecase
set smartcase
set incsearch

" Completion
set wildmode=longest:full,full
set wildmenu
set completeopt=menu,menuone,noselect

" Ignore patterns
set wildignore+=.DS_Store
set wildignore+=*.jpg,*.jpeg,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
set wildignore+=*.mp3,*.mp4,*.ogg,*.mkv
set wildignore+=*/vendor/*,*/.git/*,*/.hg/*,*/.svn/*
set wildignore+=*/log/*,*/tmp/*,*/build/*,*/dist/*,*/node_modules/*

" Performance
filetype plugin indent on
syntax enable

" Leader key
let mapleader=","

" Only load plugins in Neovim
if !has('nvim')
    finish
endif

" Detect server mode (SSH, Docker containers, or no display)
let g:server_mode = 0
if !empty($SSH_CONNECTION) || filereadable('/.dockerenv') || empty($DISPLAY)
    let g:server_mode = 1
endif

" Bootstrap lazy.nvim
lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Determine if we're in server mode
local server_mode = vim.g.server_mode == 1

-- Plugin specification
local plugins = {
  -- Colorscheme
  {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      vim.cmd([[silent! colorscheme gruvbox]])
    end,
  },

  -- Lightweight statusline
  {
    "itchyny/lightline.vim",
    enabled = not server_mode,
    config = function()
      vim.g.lightline = {
        colorscheme = 'gruvbox',
        active = {
          left = {
            { 'mode', 'paste' },
            { 'gitbranch', 'readonly', 'filename', 'modified' }
          }
        },
        component_function = {
          gitbranch = 'FugitiveHead'
        },
      }
      vim.opt.showmode = false
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" },
  },

  {
    "airblade/vim-gitgutter",
    enabled = not server_mode,
    event = { "BufReadPre", "BufNewFile" },
  },

  -- Editing enhancements
  {
    "tpope/vim-commentary",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gcc", mode = "n" },
    },
  },

  {
    "tpope/vim-surround",
    keys = { "ys", "cs", "ds" },
  },

  {
    "ntpeters/vim-better-whitespace",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.strip_whitespace_on_save = 1
      vim.g.strip_whitespace_confirm = 0
    end,
  },

  -- FZF integration (uses system fzf installed via apt)
  {
    "junegunn/fzf.vim",
    enabled = not server_mode,
    cmd = { "Files", "Buffers", "Rg", "Lines" },
    config = function()
      -- Use system fzf
      vim.g.fzf_command_prefix = ''
    end,
  },

  -- Language support (lightweight polyglot alternative)
  {
    "sheerun/vim-polyglot",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- Linting and fixing (disabled in server mode)
  {
    "dense-analysis/ale",
    enabled = not server_mode,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.g.ale_sign_column_always = 1
      vim.g.ale_lint_on_text_changed = 'never'
      vim.g.ale_lint_on_insert_leave = 0
      vim.g.ale_lint_on_enter = 1
      vim.g.ale_lint_on_save = 1
      vim.g.ale_fix_on_save = 1

      vim.g.ale_linters = {
        python = {'flake8', 'pylint'},
        go = {'gopls', 'golint'},
        javascript = {'eslint'},
        typescript = {'eslint', 'tsserver'},
      }

      vim.g.ale_fixers = {
        ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
        python = {'black', 'isort'},
        go = {'gofmt', 'goimports'},
        javascript = {'prettier', 'eslint'},
        typescript = {'prettier', 'eslint'},
      }
    end,
  },

  -- Go support
  {
    "fatih/vim-go",
    enabled = not server_mode,
    ft = "go",
    build = ":GoUpdateBinaries",
    config = function()
      vim.g.go_fmt_command = "goimports"
      vim.g.go_auto_type_info = 1
      vim.g.go_highlight_functions = 1
      vim.g.go_highlight_methods = 1
      vim.g.go_highlight_structs = 1
      vim.g.go_highlight_operators = 1
      vim.g.go_highlight_build_constraints = 1
    end,
  },

  -- Python support
  {
    "vim-python/python-syntax",
    ft = "python",
    config = function()
      vim.g.python_highlight_all = 1
    end,
  },

  -- Markdown
  {
    "plasticboy/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_frontmatter = 1
    end,
  },

  -- GPG support
  {
    "jamessan/vim-gnupg",
    ft = "gpg",
  },

  -- Start screen (disabled in server mode)
  {
    "mhinz/vim-startify",
    enabled = not server_mode,
  },
}

-- Setup lazy.nvim
require("lazy").setup(plugins, {
  -- Lockfile for reproducibility
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",

  -- Performance
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },

  -- UI
  ui = {
    border = "rounded",
  },
})
EOF

" Clipboard configuration with OSC 52 support
" OSC 52 allows clipboard access in remote/container environments with modern terminals
" Works with: Ghostty, WezTerm, Alacritty, kitty, etc.
if g:server_mode
    " Use OSC 52 for clipboard in remote/server mode
    function! Osc52Yank()
        " Get the yanked text from the event
        let text = join(v:event.regcontents, "\n")
        let encoded = system('base64 -w0', text)
        let encoded = substitute(encoded, "\n$", "", "")
        let osc52 = "\e]52;c;" . encoded . "\e\\"
        " Write directly to stderr for better Docker/terminal compatibility
        call system('printf "' . osc52 . '" >&2')
    endfunction

    augroup Osc52Yank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call Osc52Yank() | endif
    augroup END
else
    " Use system clipboard for local sessions
    set clipboard=unnamedplus
endif

" Python configuration
let g:python3_host_prog = '/usr/bin/python3'
autocmd FileType python setlocal colorcolumn=88

" Key mappings
" Disable Ex mode
nnoremap Q <Nop>

" Better window navigation
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-l> <C-W>l

" Split windows
nnoremap <leader>j :sp<CR>
nnoremap <leader>l :vsp<CR>

" Buffer navigation
nnoremap <C-i> :bnext<CR>
nnoremap <C-u> :bprev<CR>
nnoremap <leader>bd :bdelete<CR>

" FZF shortcuts (only if not in server mode)
if !g:server_mode
    nnoremap <C-p> :Files<CR>
    nnoremap <leader>b :Buffers<CR>
    nnoremap <leader>/ :Rg<CR>
    nnoremap <leader>l :Lines<CR>
endif

" Quick save and quit
nmap <leader>w :w!<CR>
nmap <leader>q :q<CR>

" Remove search highlight
nnoremap <leader><space> :nohlsearch<CR>

" ESC with double leader in insert mode
inoremap <leader><leader> <Esc>

" Copy to system clipboard
vmap <C-c> "+y

" Stay in visual mode after indent
vnoremap < <gv
vnoremap > >gv

" Move lines up and down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Disable arrow keys to force good habits
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Close quickfix window
nnoremap <leader>c :cclose<CR>

" Toggle file tree (if using netrw)
nnoremap <leader>e :Explore<CR>

" Abbreviations
iab idate <c-r>=strftime("%Y-%m-%d")<cr>
iab itime <c-r>=strftime("%H:%M:%S")<cr>
iab idatetime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>

" Auto commands
" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" YAML files treated as Ansible
autocmd BufRead,BufNewFile */playbooks/*.yml set filetype=yaml.ansible
autocmd BufRead,BufNewFile */roles/*/tasks/*.yml set filetype=yaml.ansible

" Go key mappings
au FileType go nmap <F5> <Plug>(go-run)
au FileType go nmap <F6> <Plug>(go-build)
au FileType go nmap <F7> <Plug>(go-test)
au FileType go nmap <F8> <Plug>(go-coverage)
au FileType go nmap <leader>gd <Plug>(go-doc)
au FileType go nmap <leader>gi <Plug>(go-info)
