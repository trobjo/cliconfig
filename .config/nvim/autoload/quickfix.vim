function! quickfix#find(args)
    set errorformat=%f
    call feedkeys(":silent match NonText /||/ \| echo \<CR>", 'n')
    return system('fd --type f ' . substitute(a:args, ',\?\(\.\w\{1,4}\)', ' --extension \1 ', "g"))
endfunction


function! quickfix#grep(args)
    let args = split(a:args, ' \(\(\!\(,\?\.\?\w\+\*\?\)\+\)\|\(,\?\w*\.\w\{1,4}\)\+$\)\@=')

    let @q = args[0]
    if len(args) == 1
        " call feedkeys(":match Type /\\(|\\d\\{1,5} col \\d\\{1,5}| .*\\)\\@<=" . substitute(a:args, '\\b\|\\\([(){]\)\@=', '', 'g') . "\\c\\v/ \| echo \<CR>", 'n')
        return system(&grepprg . shellescape(a:args))
    endif

    call feedkeys(":silent match Type /\\(|\\d\\{1,5} col \\d\\{1,5}| .*\\)\\@<=" . substitute(args[0], '\\b\|\\\([(){]\)\@=', '', 'g') . "\\c/ \| echo \<CR>", 'n')

    if len(args) == 2
        if args[1] =~ '^\!.*'
            return system(&grepprg . shellescape(args[0]) . substitute(args[1], '\!\?,\?\(\.\?\w\+\*\?\)', ' --iglob "!*\1"', "g"))
        else
            return system(&grepprg . shellescape(args[0]) . substitute(args[1], '\(^\|,\)\(\(\w\+\*\?\)\?\.\w\{1,4}\)', ' --iglob "*\2"', "g"))
        endif
    elseif len(args) == 3
        return system(&grepprg . shellescape(args[0]) . substitute(args[2], '\(^\|,\)\(\(\w\+\*\?\)\?\.\w\{1,4}\)', ' --iglob "*\2"', "g")   . substitute(args[1], '\!\?,\?\(\w\+\*\?\)', ' --iglob "!*\1"', "g"))
    endif

    echom "Could not parse " . a:args
    return 0
endfunction


function! quickfix#visualgrep(args)
        " call feedkeys(":silent match Type /\\(|\\d\\{1,5} col \\d\\{1,5}| .*\\)\\@<=" . escape(a:args, "/[]*") . "\\V/ \| echo \<CR>", 'n')
        return system("rg --vimgrep --glob '!*{.git,node_modules,build,bin,obj,README.md,tags}' --fixed-strings " . shellescape(a:args))
endfunction


function! quickfix#buffers()
    redir => output
        silent! execute 'buffers'
    redir END

    set errorformat=%f\ %l\ %m
    let lines = split(output, '\n')
    let items = []

    for line in lines
        let s = substitute(line, '\s*\d\+\ ..\=\s*\(+\=\)\s*"\(.*\)"\s*line\s\(\d*\)', '\2 \3 S:\1', 'g')
        call add(items, s)
    endfor

    return items
endfunction


function! quickfix#oldfiles(args)
    set errorformat=%f
    return filter(filter(copy(v:oldfiles), 'v:val =~ a:args'), "v:val !~ '^gitgutter\\|\\[Preview]\\|^/tmp/\\|.git/'")
endfunction


function! quickfix#isLocation()
  " Get dictionary of properties of the current window
  let wininfo = filter(getwininfo(), {i,v -> v.winnr == winnr()})[0]
  return wininfo.loclist
endfunction


function! quickfix#length()
  " Get the size of the current quickfix/location list
  return len(quickfix#isLocation() ? getloclist(0) : getqflist())
endfunction


function! s:getProperty(key, ...)
  " getqflist() and getloclist() expect a dictionary argument
  " If a 2nd argument has been passed in, use it as the value, else 0
  let l:what = {a:key : a:0 ? a:1 : 0}
  let l:listdict = quickfix#isLocation() ? getloclist(0, l:what) : getqflist(l:what)
  return get(l:listdict, a:key)
endfunction

function! s:isFirst()
  return s:getProperty('nr') <= 1
endfunction

function! s:isLast()
  return s:getProperty('nr') == s:getProperty('nr', '$')
endfunction

function! s:history(goNewer)
  " Build the command: one of colder/cnewer/lolder/lnewer
  let l:cmd = (quickfix#isLocation() ? 'l' : 'c') . (a:goNewer ? 'newer' : 'older')

  " Apply the cmd repeatedly until we hit a non-empty list, or first/last list
  " is reached
  while 1
    if (a:goNewer && s:isLast()) || (!a:goNewer && s:isFirst()) | break | endif
    " Run the command. Use :silent to suppress message-history output.
    " Note that the :try wrapper is no longer necessary
    silent execute l:cmd
    if quickfix#length() | break | endif
  endwhile

  " Set the height of the quickfix window to the size of the list, max-height 10
  " execute 'resize' min([ 15, max([ 1, quickfix#length() ]) ])

  " Echo a description of the new quickfix / location list.
  " And make it look like a rainbow.
  let l:nr = s:getProperty('nr')
  let l:last = s:getProperty('nr', '$')
  echohl MoreMsg | echon '('
  echohl Identifier | echon l:nr
  if l:last > 1
    echohl LineNr | echon ' of '
    echohl Identifier | echon l:last
  endif
  echohl MoreMsg | echon ') '
  " echohl MoreMsg | echon '['
  " echohl Identifier | echon quickfix#length()
  " echohl MoreMsg | echon '] '
  echohl Normal | echon s:getProperty('title')
  " echohl None
endfunction

function! quickfix#older()
  call s:history(0)
endfunction

function! quickfix#newer()
  call s:history(1)
endfunction

