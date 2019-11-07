
if has('vimscript-4')
    scriptversion 4
else
    finish
endif

let g:loaded_jumptoline = 1

command! -nargs=0 -bar   JumpToLine     :call jumptoline#exec()

