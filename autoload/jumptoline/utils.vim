
function! jumptoline#utils#same_buffer(target, bnr, fullpath)
  return (a:bnr == a:target) || (bufnr(a:fullpath) == a:target)
endfunction

function! jumptoline#utils#get_target_wininfos(bnr, fullpath) abort
  let xs = []
  for x in getwininfo()
    let x['modified'] = getbufvar(x['bufnr'], '&modified', 0)
    if (x['tabnr'] == tabpagenr()) && (!x['terminal']) && (jumptoline#utils#same_buffer(x['bufnr'], a:bnr, a:fullpath) || !x['modified'])
      let xs += [x]
    endif
  endfor
  return xs
endfunction

function! jumptoline#utils#adjust_and_setpos(lnum, col)
  if (0 < a:lnum) || (0 < a:col)
    call setpos('.', [0, a:lnum, a:col, 0])
  endif
endfunction

function! jumptoline#utils#find_thefile(target)
  try
    let path = expand(a:target, v:true)
    if filereadable(path)
      return [path]
    endif
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
  catch
  endtry
  return []
endfunction

