
let s:ps = [
    \   { 'type' : 'quickfix', 'regex' : '^\([^|]*\)|\(\d\+\)\( col \(\d\+\)\)\?|', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 4, },
    \   { 'type' : 'msbuild,C#,F#', 'regex' : '^\s*\(.*\)(\(\d\+\),\(\d\+\)):.*$', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 3, },
    \   { 'type' : 'VC', 'regex' : '^\s*\(.*\)(\(\d\+\))\s*:.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Rust', 'regex' : '^\s*--> \(.*\.rs\):\(\d\+\):\(\d\+\)$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Python', 'regex' : '^\s*File "\([^"]*\)", line \(\d\+\),.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Ruby', 'regex' : '^\s*\(.*.rb\):\(\d\+\):.*$', 'path_i' : 1, 'lnum_i' : 2, },
    \   { 'type' : 'Go,gcc,Clang', 'regex' : '^\s*\(.*\.[^.]\+\):\(\d\+\):\(\d\+\):.*$', 'path_i' : 1, 'lnum_i' : 2, 'col_i' : 3, },
    \ ]

let s:NEW_WINDOW = 'new window'
let s:NEW_TABPAGE = 'new tabpage'

function! jumptoline#exec() abort
    let found = v:false
    let line = getline('.')
    for p in s:ps
        let m = matchlist(line, p['regex'])
        if !empty(m)
            for fullpath in s:find_thefile(m[p['path_i']])
                let lnum = 1
                if has_key(p, 'lnum_i')
                    let lnum = str2nr(m[p['lnum_i']])
                endif

                let col = 1
                if has_key(p, 'col_i')
                    let col = str2nr(m[p['col_i']])
                endif

                call s:open_popup(-1, fullpath, lnum, col)
                let found = v:true
                break
            endfor
        endif
    endfor
    if !found && (&filetype == 'qf')
        let x = get(getqflist(), line('.') - 1, {})
        if !empty(x)
            call s:open_popup(x['bufnr'], '', x['lnum'], x['col'])
        endif
    endif
endfunction

function! s:open_popup(...) abort
    let title = 'Choose a window to open'
    let candidates = s:winnrlist(a:1, a:2) + [s:NEW_WINDOW, s:NEW_TABPAGE]
    if has('popupwin')
        call popup_menu(candidates, #{
            \   title: title,
            \   callback: function('s:callback', a:000),
            \   padding: [1,1,1,1],
            \ })
    else
        let lines = []
        for can in candidates
            let lines += [printf('%d) %s', len(lines) + 1, can)]
        endfor
        let n = inputlist([title] + lines)
        if 0 < n
            call s:callback_sub(candidates[n - 1], a:1, a:2, a:3, a:4)
        endif
    endif
endfunction

function! s:callback(bnr, fullpath, lnum, col, winid, key) abort
    if 0 < a:key
        let line = getbufline(winbufnr(a:winid), a:key)[0]
        call s:callback_sub(line, a:bnr, a:fullpath, a:lnum, a:col)
    endif
endfunction

function! s:callback_sub(line, bnr, fullpath, lnum, col) abort
    if a:line == s:NEW_WINDOW
        new
    elseif a:line == s:NEW_TABPAGE
        tabnew
    else
        let wnr = matchstr(a:line, '^\d\+')
        execute wnr .. 'wincmd w'
    endif
    if !s:same_buffer(bufnr(), a:bnr, a:fullpath)
        if -1 == a:bnr
            execute printf('edit %s', a:fullpath)
        else
            execute printf('%dbuffer', a:bnr)
        endif
    endif
    call s:adjust_and_setpos(a:lnum, a:col)
    normal! zz
endfunction

function! s:same_buffer(target, bnr, fullpath)
    return (a:bnr == a:target) || (bufnr(a:fullpath) == a:target)
endfunction

function! s:winnrlist(bnr, fullpath)
    let ws = []
    for x in getwininfo()
        let x['modified'] = getbufvar(x['bufnr'], '&modified', 0)
        if (x['tabnr'] == tabpagenr()) && (!x['terminal']) && (s:same_buffer(x['bufnr'], a:bnr, a:fullpath) || !x['modified'])
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
        endif
    endfor
    return ws
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

