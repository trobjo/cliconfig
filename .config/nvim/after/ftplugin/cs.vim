" The following commands are contextual, based on the cursor position.
" nnoremap <buffer> <Leader>d :OmniSharpGotoDefinition<CR>
nnoremap <buffer> <Leader>fi :OmniSharpFindImplementations<CR>
nnoremap <buffer> <Leader>fs :OmniSharpFindSymbol<CR>

" Finds members in the current buffer
nnoremap <buffer> <Leader>fm :OmniSharpFindMembers<CR>

nnoremap <buffer> <Leader>fx :OmniSharpFixUsings<CR>
nnoremap <buffer> <Leader>cc :OmniSharpDocumentation<CR>
nnoremap <buffer> <C-\> :OmniSharpSignatureHelp<CR>
inoremap <buffer> <C-\> <C-o>:OmniSharpSignatureHelp<CR>

" Navigate up and down by method/property/field
"  nnoremap <buffer> <C-p> :OmniSharpNavigateUp<CR>
"  nnoremap <buffer> <C-n> :OmniSharpNavigateDown<CR>

" Contextual code actions (uses fzf, CtrlP or unite.vim when available)
nnoremap <Leader>o :OmniSharpGetCodeActions<CR>
" Run code actions with text selected in visual mode to extract method
xnoremap <Leader>o :call OmniSharp#GetCodeActions('visual')<CR>

" Rename with dialog
nnoremap <Leader>nm :OmniSharpRename<CR>
nnoremap <F2> :OmniSharpRename<CR>
" Rename without dialog - with cursor on the symbol to rename: `:Rename newname`
command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

nnoremap <Leader>fc :OmniSharpCodeFormat<CR>
let b:vcm_tab_complete = 'omni'
setlocal commentstring=//\ %s

inoremap <buffer> . .<C-X><C-O><C-p>

nnoremap <buffer> fd :OmniSharpGotoDefinition<CR>
nnoremap <buffer> fi :OmniSharpFindImplementations<CR>
nnoremap <buffer> fu :OmniSharpFindUsages<CR>
nnoremap <buffer> ft :OmniSharpTypeLookup<CR>

