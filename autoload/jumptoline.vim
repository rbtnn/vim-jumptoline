
if has('vimscript-4')
    scriptversion 4
else
    finish
endif

let s:ps = [
    \   { 'type' : 'quickfix', 'regex' : '^\([^|]*\)|\(\d\+\)\( col \d\+\)\?|', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 3, },
    \   { 'type' : 'msbuild,C#,F#', 'regex' : '^\s*\(.*\)(\(\d\+\),\(\d\+\)):.*$', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 3, },
    \   { 'type' : 'Rust', 'regex' : '^\s*--> \(.*\.rs\):\(\d\+\):\(\d\+\)$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Python', 'regex' : '^\s*File "\([^"]*\)", line \(\d\+\),.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Ruby', 'regex' : '^\s*\(.*.rb\):\(\d\+\):.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Go,gcc,Clang', 'regex' : '^\s*\(.*\.[^.]\+\):\(\d\+\):\(\d\+\):.*$', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 3, },
    \ ]

function! jumptoline#exec() abort
    let line = getline('.')
    for p in s:ps
        let m = matchlist(line, p['regex'])
        if !empty(m)
            for fullpath in s:find_thefile(m[p['path_i']])
                let lnum = str2nr(m[p['lnum_i']])
                let col = str2nr(m[p['col_i']])
                let b = 0
                for x in filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
                    if s:expand2fullpath(bufname(x['bufnr'])) == s:expand2fullpath(fullpath)
                        execute x['winnr'] .. 'wincmd w'
                        let b = 1
                        break
                    endif
                endfor
                if b
                    execute printf('%d', lnum)
                else
                    execute printf('new %s', fullpath)
                endif
                call s:adjust_and_setpos(lnum, col)
                normal! zz
                break
            endfor
        endif
    endfor
endfunction

function! s:adjust_and_setpos(lnum, col)
    let line = getline(a:lnum)
    let s = ''
    let adjust_col = 0
    for c in split(line, '\zs')
        if strdisplaywidth(s) < a:col
            let s ..= c
            let adjust_col += 1
        else
            break
        endif
    endfor
    call setpos('.', [0, a:lnum, adjust_col, 0])
endfunction

function! s:find_thefile(target)
    for info in getwininfo()
        for s in [fnamemodify(bufname(info['bufnr']), ':p:h'), getcwd(info['winnr'], info['tabnr'])]
            let xs = split(s, '[\/]')
            for n in reverse(range(0, len(xs) - 1))
                let path = expand(a:target)
                if filereadable(path)
                    return [path]
                endif
                let path = expand(join(xs[:n] + [(a:target)], '/'))
                if filereadable(path)
                    return [path]
                endif
            endfor
        endfor
    endfor
    return []
endfunction

function! s:expand2fullpath(path)
    return substitute(fnamemodify(expand(a:path), ':p'), '\', '/', 'g')
endfunction

