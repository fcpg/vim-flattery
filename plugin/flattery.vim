" flattery.vim - f/t maps 
if exists("g:loaded_flattery") || &cp
  finish
endif
let g:loaded_flattery = 1

let s:save_cpo = &cpo
set cpo&vim


"--------------
" Options {{{1
"--------------
"
let s:flattery_f_map = get(g:, 'flattery_f_map', 'f')
let s:flattery_t_map = get(g:, 'flattery_t_map', 't')

let s:flattery_x_char    = get(g:, 'flattery_x_char', 'x')
let s:flattery_orig_char = get(g:, 'flattery_orig_char', 'v')
let s:flattery_alt_char  = get(g:, 'flattery_alt_char', 'g')


"----------------
" Functions {{{1
"----------------

function! FlatteryLoad(o) abort
  call flattery#SetPlugMaps()
  call flattery#SetUserMaps()
  for op in [s:flattery_f_map, s:flattery_t_map]
    for cmd in ['nun', 'xu', 'ou']
      exe cmd op
    endfor
  endfor
  return "\<Plug>(flattery)".a:o
endfun


"-----------
" Init {{{1
"-----------

if get(g:, 'flattery_autoload', 1)
  for op in [s:flattery_f_map, s:flattery_t_map]
    for cmd in ['nm', 'xm', 'om']
      exe cmd '<silent><expr>' op
            \ 'FlatteryLoad("'.op.'")'
      exe cmd '<silent>' '<Plug>(flattery)'.op
            \ op
    endfor
  endfor
else
  call flattery#SetPlugMaps()
  call flattery#SetUserMaps()
endif

let &cpo = s:save_cpo

" vim: et sw=2 ts=2 ft=vim:

