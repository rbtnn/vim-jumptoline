
let s:ps = [
    \   { 'type' : 'quickfix', 'regex' : '^\([^|]*\)|\(\(\d\+\)\( col \(\d\+\)\)\?[^|]*\)\?|', 'path_i' : 1, 'lnum_i' : 3, 'col_i' : 5, },
    \   { 'type' : 'msbuild,C#,F#', 'regex' : '^\s*\(.*\)(\(\d\+\),\(\d\+\)):.*$', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 3, },
    \   { 'type' : 'VC', 'regex' : '^\s*\(.*\)(\(\d\+\))\s*:.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Rust', 'regex' : '^\s*--> \(.*\.rs\):\(\d\+\):\(\d\+\)$', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 3, },
    \   { 'type' : 'Python', 'regex' : '^\s*File "\([^"]*\)", line \(\d\+\),.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Ruby', 'regex' : '^\s*\(.*.rb\):\(\d\+\):.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Go,gcc,Clang,ripgrep,', 'regex' : '^\s*\(.\{-}\):\(\d\+\)\(:\(\d\+\):\)\?.*$', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 4, },
    \ ]

let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

let s:NEW_WINDOW = 'new window'
let s:NEW_TABPAGE = 'new tabpage'

function! jumptoline#exec(line) abort
    let found = v:false
    for d in jumptoline#matches(a:line)
        for fullpath in jumptoline#utils#find_thefile(d['path'])
            call s:choose_awin(-1, fullpath, d['lnum'], d['col'])
            let found = v:true
            break
        endfor
    endfor
    if !found && (&filetype == 'qf')
        let x = get(getqflist(), line('.') - 1, {})
        if !empty(x)
            call s:choose_awin(x['bufnr'], '', x['lnum'], x['col'])
        endif
    endif
endfunction

function! jumptoline#matches(line) abort
    let ds = []
    let best_match_point = 0
    for p in s:ps
        let m = matchlist(a:line, p['regex'])
        if !empty(m)
            let path = m[p['path_i']]

            let lnum = 0
            if has_key(p, 'lnum_i')
                let lnum = str2nr(m[p['lnum_i']])
            endif

            let col = 0
            if has_key(p, 'col_i')
                let col = str2nr(m[p['col_i']])
            endif

            let d = {
                \ 'path' : path,
                \ 'lnum' : lnum,
                \ 'col' : col,
                \ }
            if -1 == index(ds, d)
                let point = (0 < lnum) + (0 < col) + filereadable(path)

                if point < best_match_point
                    continue
                elseif best_match_point < point
                    let best_match_point = point
                    let ds = [d]
                else
                    let ds += [d]
                endif
            endif
        endif
    endfor
    return ds
endfunction

function! jumptoline#run_tests() abort
    if filereadable(s:TEST_LOG)
        call delete(s:TEST_LOG)
    endif

    let v:errors = []

    call assert_equal(
        \ [{ 'lnum': 0, 'col': 0, 'path': 'xxx.vim'}],
        \ jumptoline#matches('xxx.vim||'))
    call assert_equal(
        \ [{ 'lnum': 1006, 'col': 8, 'path': 'xxx.vim'}],
        \ jumptoline#matches('xxx.vim|1006 col 8 error| call system(prog)'))
    call assert_equal(
        \ [{ 'lnum': 1006, 'col': 8, 'path': 'xxx.vim'}],
        \ jumptoline#matches('xxx.vim|1006 col 8| call system(prog)'))
    call assert_equal(
        \ [{ 'lnum': 923, 'col': 21, 'path': 'C:\Users\rbtnn\Desktop\main.vb'}],
        \  jumptoline#matches('C:\Users\rbtnn\Desktop\main.vb(923,21): warning BC42021: ...'))
    call assert_equal(
        \ [{ 'lnum': 923, 'col': 0, 'path': 'C:\Users\rbtnn\Desktop\main.vb'}],
        \  jumptoline#matches('C:\Users\rbtnn\Desktop\main.vb(923): warning BC42021: ...'))
    call assert_equal(
        \ [{ 'lnum': 9, 'col': 10, 'path': 'main.cs'}],
        \  jumptoline#matches('main.cs(9,10): error CS1002: ; expected'))
    call assert_equal(
        \ [{ 'lnum': 1, 'col': 0, 'path': './prog.py'}],
        \  jumptoline#matches('File "./prog.py", line 1, in <module>'))
    call assert_equal(
        \ [{ 'lnum': 1, 'col': 0, 'path': 'prog.rb'}],
        \  jumptoline#matches('prog.rb:1:in `<main>'': undefined local variable or method `aaaa'' for ...'))
    call assert_equal(
        \ [{ 'lnum': 7, 'col': 42, 'path': 'src\main.rs'}],
        \  jumptoline#matches('--> src\main.rs:7:42'))
    call assert_equal(
        \ [{ 'lnum': 1, 'col': 1, 'path': 'prog.go'}],
        \  jumptoline#matches('prog.go:1:1: expected ''package'', found aaaaaa'))
    call assert_equal(
        \ [{ 'lnum': 20, 'col': 0, 'path': 'C:/Go/LICENSE'}],
        \  jumptoline#matches('C:/Go/LICENSE:20 aaaaaa'))
    call assert_equal(
        \ [{ 'lnum': 33, 'col': 0, 'path': 'README.md'}],
        \  jumptoline#matches('README.md:33||'))

    if !empty(v:errors)
        call writefile(v:errors, s:TEST_LOG)
        for err in v:errors
            echohl Error
            echo err
            echohl None
        endfor
    endif
endfunction

function! jumptoline#callback(line, bnr, fullpath, lnum, col) abort
    if a:line == s:NEW_WINDOW
        new
    elseif a:line == s:NEW_TABPAGE
        tabnew
    else
        let wnr = matchstr(a:line, '^\d\+')
        execute wnr .. 'wincmd w'
    endif
    if !jumptoline#utils#same_buffer(bufnr(), a:bnr, a:fullpath)
        if -1 == a:bnr
            execute printf('edit %s', a:fullpath)
        else
            execute printf('%dbuffer', a:bnr)
        endif
    endif
    call jumptoline#utils#adjust_and_setpos(a:lnum, a:col)
    normal! zz
endfunction

function! s:choose_awin(bnr, fullpath, lnum, col) abort
    let title = 'Choose a window to open'
    let candidates = s:winnrlist(a:bnr, a:fullpath) + [s:NEW_WINDOW, s:NEW_TABPAGE]
    if has('popupwin') && !get(g:, 'jumptoline_debug', 0)
        call jumptoline#popupwin#open(title, candidates, a:bnr, a:fullpath, a:lnum, a:col)
    else
        let lines = []
        for can in candidates
            let lines += [printf('%d) %s', len(lines) + 1, can)]
        endfor
        let n = inputlist([title] + lines)
        if 0 < n
            call jumptoline#callback(candidates[n - 1], a:bnr, a:fullpath, a:lnum, a:col)
        endif
    endif
endfunction

function! s:winnrlist(bnr, fullpath)
    let ws = []
    for x in jumptoline#utils#get_target_wininfos(a:bnr, a:fullpath)
        if x['quickfix']
            let name = '[quickfix]'
        elseif x['loclist']
            let name = '[loclist]'
        elseif 'help' == getbufvar(x['bufnr'], '&buftype')
            let name = '[help]'
        else
            let name = bufname(x['bufnr'])
            if empty(name)
                let name = '[No Name]'
            endif
        endif
        let mark = ' '
        if x['winnr'] == winnr('#')
            let mark = '#'
        elseif x['bufnr'] == bufnr()
            let mark = '%'
        endif
        let modified = ''
        if x['modified']
            let modified = '[+]'
        endif
        let ws += [printf('%d %s %s%s', x['winnr'], mark, name, modified)]
    endfor
    return ws
endfunction

