" setlocal nonumber
setlocal nowrap
setlocal nolist
setlocal rulerformat=%30(%=%#UserRuler#\(%l/%{quickfix#length()}%\))
set nobuflisted

execute 'resize' min([ 20, max([ 1, quickfix#length() ]) ])


nnoremap <buffer> n n
nnoremap <buffer> x :Find<space>
nnoremap <silent><buffer> <CR> <CR>:cclose \| :lclose<CR>
nnoremap <silent><buffer> h <CR><C-w>p
nnoremap <silent><buffer> <ESC> :cclose \| :lclose<CR>

nnoremap <silent><buffer><expr> o quickfix#isLocation() ? ":lprevious\<CR>\<C-w>p" : ":cprevious\<CR>\<C-w>p"
nnoremap <silent><buffer><expr> u quickfix#isLocation() ? ":lnext\<CR>\<C-w>p" : ":cnext\<CR>\<C-w>p"

" nnoremap <silent><buffer><expr> , quickfix#isLocation() ? ":lolder\<CR>" : ":colder\<CR>"
" nnoremap <silent><buffer><expr> p quickfix#isLocation() ? ":lnewer\<CR>" : ":cnewer\<CR>"

nnoremap <silent> <buffer> , :call quickfix#older()<CR>
nnoremap <silent> <buffer> p :call quickfix#newer()<CR>


" open entry in a new tab.
nnoremap <silent> <buffer> t :cclose \| cc <C-r>=line(".")<CR> \| call Newsplit() \| bd<CR>

nnoremap <silent><buffer> 1 :1<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 2 :2<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 3 :3<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 4 :4<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 5 :5<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 6 :6<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 7 :7<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 8 :8<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 9 :9<CR><CR>:cclose \| :lclose <CR>
nnoremap <silent><buffer> 0 :10<CR><CR>:cclose \| :lclose <CR>

