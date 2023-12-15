unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" basic settings
if has('gui_running')
  au GUIEnter * simalt ~x
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

" Bullets
let g:bullets_set_mappings = 0 " disable adding default key mappings, default = 1
let g:bullets_custom_mappings = [
  \ ['nmap', 'o', '<Plug>(bullets-newline)'],
  \
  \ ['vmap', 'gN', '<Plug>(bullets-renumber)'],
  \ ['nmap', 'gN', '<Plug>(bullets-renumber)'],
  \
  \ ['nmap', '<leader>x', '<Plug>(bullets-toggle-checkbox)'],
  \
  \ ['imap', '<C-t>', '<Plug>(bullets-demote)'],
  \ ['nmap', '>>', '<Plug>(bullets-demote)'],
  \ ['vmap', '>', '<Plug>(bullets-demote)'],
  \ ['imap', '<C-d>', '<Plug>(bullets-promote)'],
  \ ['nmap', '<<', '<Plug>(bullets-promote)'],
  \ ['vmap', '<', '<Plug>(bullets-promote)'],
  \ ]

" lexima
" https://github.com/cohama/lexima.vim/issues/129
" call lexima#add_rule({'char': '"', 'at': '"\S\{-1,}\%#\|\%#\S\{-1,}"'})
" call lexima#add_rule({'char': "'", 'at': '''\S\{-1,}\%#\|\%#\S\{-1,}'''})
" call lexima#add_rule({'char': '`', 'at': '`\S\{-1,}\%#\|\%#\S\{-1,}`'})
" https://github.com/cohama/lexima.vim/issues/83
inoremap <M-n> <C-r>=lexima#insmode#leave_till_eol("")<CR>

" tcomment
let g:tcomment_opleader1 = "<Leader>c"

" Coc
command! CocStop call coc#rpc#kill()
autocmd FileType text let b:coc_disabled_sources = ['around', 'buffer']
set updatetime=300

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <cr>
  \ coc#pum#visible() ? coc#_select_confirm() :
  \ InBulletList() ? "\<C-g>u\<Plug>(bullets-newline)\<c-r>=coc#on_enter()\<CR>" :
  \ "\<C-g>u\<C-r>=lexima#expand('<LT>CR>', 'i')<CR>\<c-r>=coc#on_enter()\<CR>"
  
function! InBulletList() abort
  let line = getline('.')
  return line =~# '\v^\s*(\*|-|\d+\.)\s+'
endfunction

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> grn <Plug>(coc-rename)

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
" nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
" nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

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
nnoremap <silent> <leader>ev :tab drop $MYVIMRC<CR>
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

nmap <silent> <Leader>k <Plug>SearchNormal
vmap <silent> <Leader>k <Plug>SearchVisual

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

