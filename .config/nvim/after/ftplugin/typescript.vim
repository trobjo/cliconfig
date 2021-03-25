setlocal omnifunc=ale#completion#OmniFunc
setlocal et ts=2 sw=2 formatprg=prettier\ --parser\ typescript
" inoremap <buffer> . .<C-X><C-O>


nnoremap <silent> fd :ALEGoToDefinition<CR>

