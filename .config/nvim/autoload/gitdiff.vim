" Populates quickfix with all the files changed
" https://github.com/tpope/vim-fugitive/issues/132#issuecomment-290644034

"Letter to word mapping for git diff output
let s:git_status_dictionary = {
    \ "A ": "Added",
    \ "AM": "Added file with modifications",
    \ "B ": "Broken",
    \ "C ": "Copied",
    \ "D ": "Deleted",
    \ "M ": "All Changes staged",
    \ "MM": "Modified but also changes staged",
    \ "RM": "Renamed and modified changes",
    \ "??": "Untracked file",
    \ " M": "Modified - unstaged changes",
    \ "R ": "Renamed",
    \ "T ": "Changed",
    \ "U ": "Unmerged",
    \ "X ": "Unknown"
    \ }


function! gitdiff#get_diff_files()

    let gitstatus = system('git status -s 2> /dev/null')

    if v:shell_error != 0
        echom getcwd() . " is not a Git dir"
        return
    endif

    let gitbranch = substitute(system('git rev-parse --abbrev-ref HEAD'), "\n", "", "")

    if gitstatus == ''
        echom "Branch ". gitbranch . " is up to date"
        cclose
        return
    endif

    let lines = split(gitstatus, '\n')
    let items = []

    for line in lines
        let filename = matchstr(line, "\\S\\+$")
        let status = s:git_status_dictionary[matchstr(line, "^\\(\\s\\|\\w\\|?\\)\\{2}")]
        let item = { "filename": filename, "text": status }

        call add(items, item)
    endfor

    let list = {'items': items}
    call setqflist([], 'r', list)
    echom "Branch ". gitbranch
    copen

endfunction


