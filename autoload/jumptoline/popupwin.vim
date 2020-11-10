
if !has('popupwin')
    finish
endif

let s:jumptoline_border_winnr = -1

function! jumptoline#popupwin#open(title, candidates, bnr, fullpath, lnum, col) abort
  call popup_menu(a:candidates, #{
    \   title: a:title,
    \   callback: function('s:callback', [(a:bnr), (a:fullpath), (a:lnum), (a:col)]),
    \   filter: function('s:filter'),
    \   padding: [1,1,1,1],
    \ })
  let xs = jumptoline#utils#get_target_wininfos(a:bnr, a:fullpath)
  if 0 < len(xs)
    call s:set_border(xs[0]['winnr'])
  endif
endfunction

function! jumptoline#popupwin#hide_popupwin_term() abort
  if exists('*popup_list') && exists('*popup_close')
    for winid in popup_list()
      if getwininfo(winid)[0]['terminal']
        call popup_close(winid)
      endif
    endfor
  endif
endfunction

function! s:clear_border() abort
  if -1 != s:jumptoline_border_winnr
    call popup_close(s:jumptoline_border_winnr)
    let s:jumptoline_border_winnr = -1
  endif
endfunction

function! s:callback(bnr, fullpath, lnum, col, winid, key) abort
  call s:clear_border()
  if 0 < a:key
    let line = getbufline(winbufnr(a:winid), a:key)[0]
    call jumptoline#callback(line, a:bnr, a:fullpath, a:lnum, a:col)
  endif
endfunction

function! s:set_border(winnr) abort
  let ws = filter(getwininfo(), { i,x -> (x['tabnr'] == tabpagenr()) && (a:winnr == x['winnr']) })
  if 1 == len(ws)
    let winfo = ws[0]
    let b = 2
    let w = winfo['width'] - b
    let h = winfo['height'] - b
    let s:jumptoline_border_winnr = popup_create('', #{
      \   line: winfo['winrow'],
      \   col: winfo['wincol'],
      \   mask: [[b, w + 1, b, h + 1]],
      \   minwidth: w,
      \   minheight: h,
      \   border: [],
      \   borderchars: [' ',' ',' ',' ',' ',' ',' ',' '],
      \   borderhighlight: ['Error'],
      \ })
  endif
endfunction

function! s:filter(winid, key) abort
  call s:clear_border()
  let lnum = line('.', a:winid)
  let maxlnum =  line('$', a:winid)
  if a:key == 'j'
    let lnum += 1
    if maxlnum < lnum
      let lnum = maxlnum
    endif
  endif
  if a:key == 'k'
    let lnum -= 1
    if lnum < 1
      let lnum = 1
    endif
  endif
  let line = getbufline(winbufnr(a:winid), lnum, lnum)[0]
  let wnr = matchstr(line, '^\d\+')
  if 0 < wnr
    call s:set_border(wnr)
  endif
  return popup_filter_menu(a:winid, a:key)
endfunction

