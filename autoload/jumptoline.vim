
let s:ps = [
    \   { 'type' : 'Rust', 'regex' : '^\s*--> \(.*\.rs\):\(\d\+\):\(\d\+\)$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'C#', 'regex' : '^\s*\(.*\.cs\)(\(\d\+\),\(\d\+\)):.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Python', 'regex' : '^\s*File "\([^"]*\)", line \(\d\+\),.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Ruby', 'regex' : '^\s*\(.*.rb\):\(\d\+\):.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Go', 'regex' : '^\s*\(.*.go\):\(\d\+\):\(\d\+\):.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \ ]

function! jumptoline#exec() abort
    let line = getline('.')
    for p in s:ps
        let m = matchlist(line, p['regex'])
        if !empty(m)
            for fullpath in s:find_thefile(m[p['path_i']])
                let lnum = str2nr(m[p['lnum_i']])
                let b = 0
                for x in filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
                    if s:expand2fullpath(bufname(x['bufnr'])) == s:expand2fullpath(fullpath)
                        execute x['winnr'] . 'wincmd w'
                        let b = 1
                        break
                    endif
                endfor
                if b
                    execute printf('%d', lnum)
                else
                    if 0 < lnum
                        execute printf('new +%d %s', lnum, fullpath)
                    else
                        execute printf('new %s', fullpath)
                    endif
                endif
                normal! zz
                break
            endfor
        endif
    endfor
endfunction

function! s:find_thefile(target)
    for info in getwininfo()
        for s in [fnamemodify(bufname(info['bufnr']), ':p:h'), getcwd(info['winnr'], info['tabnr'])]
            let xs = split(s, '[\/]')
            for n in reverse(range(0, len(xs) - 1))
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

