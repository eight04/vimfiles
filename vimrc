unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" basic settings
if has('gui_running')
  set guifont=Source_Code_Pro:h11:cANSI:qDRAFT
  colorscheme obsidian
  " autocmd VimEnter * echo ">^.^<"
endif
syntax on
filetype plugin on
set number
set autoread
set ignorecase
set smartcase
set autoindent
set showmatch
set hlsearch
set incsearch
set softtabstop=2
set shiftwidth=2
set expandtab
set grepprg=rg\ -n
let g:vim_indent_cont = 0
set scrolloff=40
set switchbuf+=usetab,newtab
set iskeyword+=-
set dir=$HOME/vimfiles/swp//

" tcomment
let g:tcomment_opleader1 = "<Leader>c"

" CocStop
command! CocStop call coc#rpc#kill()

" ts
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> grn <Plug>(coc-rename)
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" svelte
let g:vim_svelte_plugin_use_typescript = 1
let g:vim_svelte_plugin_has_init_indent = 0
" let g:vim_markdown_conceal = 0

" indent?
" https://github.com/vim/vim/issues/9333
let g:html_indent_script1 = "zero"
let g:pyindent_open_paren = "shiftwidth()"

" prosession
if has('win32')
  let g:prosession_dir = "~/vimfiles/session/"
endif
let g:prosession_last_session_dir = "~"
" set sessionoptions-=options

" text object
autocmd User targets#mappings#user call targets#mappings#extend({
		\ 'a': {'argument': [{'o': '[{([]', 'c': '[])}]', 's': ','}]},
		\ })

" nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1

" user key
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <silent> H :call smarthome#SmartHome('n')<CR> 
nnoremap <silent> L :call smarthome#SmartEnd('n')<CR>
onoremap <silent> F :<C-U>normal! 0f(hviw<CR>
onoremap <silent> i@ :<C-U>execute "normal! B/\\%[\\w\\.]\\+@\\%[\\w\\.]\\+/e\rv??\r"<CR>

" Indent line
let g:indentLine_fileTypeExclude = ['help']
let g:vim_json_conceal = 0

" Emmet
nnoremap <C-y>u :call EmmetUpdateTag()<CR>
let g:user_emmet_settings = {
\ "html": {
\   "inline_elements": ""
\ }}

function! EmmetUpdateTag()
  let old_pos = getpos(".")
  let old_search = @/

  let @/ = '\v\<\w[^>]+\>'
  execute "normal! gN\e"
  let pos2 = getpos("'>")
  if CmpList(old_pos, pos2) > 0
    call setpos(".", old_pos)
    execute "normal! vato\e"
  endif
  execute "normal \<plug>(emmet-update-tag)"
  let @/ = old_search
endfunction

function CmpList(a, b)
  let i = 0
  let length = len(a:a)
  while i < length
    if a:a[i] > a:b[i]
      return 1
    elseif a:a[i] < a:b[i]
      return -1
    endif
    let i += 1
  endwhile
  return 0
endfunction

" Grep operator
nnoremap <silent> <leader>g :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <silent> <leader>g :<C-U>call <SID>GrepOperator(visualmode())<CR>

function! s:GrepOperator(type)
  let oldR = @@
  if a:type ==# "v"
    execute "normal! `<v`>y"
  elseif a:type ==# "char"
    execute "normal! `[v`]y"
  else
    return
  endif
  let word = @@
  if &grepprg =~? "findstr"
    let cmd = "grep! /S " . shellescape(word) . " *"
  elseif &grepprg =~? "grep"
    let cmd = "grep! -r " . shellescape(word) . " ."
  else
    let cmd = "grep! " . shellescape(word)
  endif
  silent execute cmd
  copen
  let @@ = oldR
endfunction

" Align right operator
nnoremap <silent> <leader>r :set operatorfunc=<SID>AlignRightOperator<cr>g@
vnoremap <silent> <leader>r :<C-U>call <SID>AlignRightOperator(visualmode())<CR>

function! s:AlignRightOperator(type)
  let oldR = @@
  if a:type ==# "v"
    execute "normal! `<d0:right\r0R\<C-R>\""
  elseif a:type ==# "char"
    execute "normal! `[d0:right\r0R\<C-R>\""
  else
    return
  endif
  let @@ = oldR
endfunction

" Substitute operator
nnoremap <silent> <leader>s :set operatorfunc=<SID>SubstituteOperator<cr>g@
vnoremap <silent> <leader>s :<C-U>call <SID>SubstituteOperator(visualmode())<CR>

function! s:SubstituteOperator(type)
  let oldR = @@
  if a:type ==# "v"
    execute "normal! `<v`>y"
  elseif a:type ==# "char"
    execute "normal! `[v`]y"
  else
    return
  endif
  let word = @@
  call feedkeys(":%s/" . word . "/")
  let @@ = oldR
endfunction

