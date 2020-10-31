
let g:loaded_jumptoline = 1

command! -bang -nargs=0 -bar   JumpToLine     :call jumptoline#exec(getline('.'), <q-bang>)

