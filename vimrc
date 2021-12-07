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
nnoremap <silent> <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <silent> H :call smarthome#SmartHome('n')<CR> 
nnoremap <silent> L :call smarthome#SmartEnd('n')<CR>
onoremap <silent> F :<C-U>normal! 0f(hviw<CR>
onoremap <silent> i@ :<C-U>execute "normal! B/\\%[\\w\\.]\\+@\\%[\\w\\.]\\+/e\rv??\r"<CR>

" Live
if !exists("s:timer")
  let s:timer = 0
endif

command Live call <SID>GoLive()
augroup live_reload
  au!
  au BufEnter * call <SID>ToggleTimer()
augroup END

function s:GoLive()
  let b:live_enabled = !get(b:, "live_enabled")
  call s:ToggleTimer()
  echo (b:live_enabled ? "" : "no") . "livereload"
endfunction

function s:LiveTimer(timer)
  if get(b:, "live_enabled")
    let is_last_line = line(".") == line("$")
    execute "checktime" bufnr()
    if is_last_line
      normal! G
    endif
  endif
endfunction

function s:ToggleTimer()
  if get(b:, "live_enabled") && !s:timer
    let s:timer = timer_start(1000, function("<SID>LiveTimer"), {"repeat": -1})
  elseif !get(b:, "live_enabled") && s:timer
    call timer_stop(s:timer)
    let s:timer = 0
  endif
endfunction

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

