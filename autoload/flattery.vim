" flattery.vim - f/t maps

let s:save_cpo = &cpo
set cpo&vim


"--------------
" Options {{{1
"--------------

let s:gotgcs = exists('*getcharsearch')


" Defaults {{{2
"---------------

let s:flattery_default_maps = {
      \ 'a': 'angle',
      \ 'b': 'paren',
      \ 'c': 'curly',
      \ 'r': 'square',
      \ 'l': 'limit',
      \ 'w': 'word',
      \ 'u': 'upper',
      \ 'z': 'b4eol',
      \ 'd': ['.'],
      \ 'e': ['='],
      \ 'h': ['#'],
      \ 'k': ['`'],
      \ 'p': ['\|'],
      \ 's': ['/'],
      \}

let s:flattery_default_maps_opt = {
      \ 'angle':  {},
      \ 'paren':  {},
      \ 'curly':  {},
      \ 'square': {},
      \ 'limit':  {},
      \ 'word':   {
      \   'to_closing': 0,
      \   'alt_dirs':   0,
      \ },
      \ 'upper':  {},
      \ 'b4eol':  {},
      \}

let s:flattery_default_to_closing = 1
let s:flattery_default_alt_dirs   = 1


" User maps {{{2
"----------------

" maps
let s:flattery_f_map       = get(g:, 'flattery_f_map', 'f')
let s:flattery_t_map       = get(g:, 'flattery_t_map', 't')
let s:flattery_maps        = get(g:, 'flattery_maps', s:flattery_default_maps)
let s:flattery_override_maps = get(g:, 'flattery_override_maps', {})
if !empty(s:flattery_override_maps)
  call extend(s:flattery_maps, s:flattery_override_maps)
endif

" chars (after f/t)
let s:flattery_x_char      = get(g:, 'flattery_x_char', 'x')
let s:flattery_orig_char   = get(g:, 'flattery_orig_char', 'v')
let s:flattery_alt_char    = get(g:, 'flattery_alt_char', 'g')
let s:flattery_redo_char   = get(g:, 'flattery_redo_char', 'j')

" ignore list
let s:flattery_nomap_list  = get(g:, 'flattery_nomap_list', [])
let s:flattery_nomap_ff    = get(g:, 'flattery_nomap_ff', 0)

let s:flattery_all_plugs   = get(g:, 'flattery_all_plugs', 0)

let s:flattery_maps_opt = deepcopy(s:flattery_default_maps_opt)
call extend(s:flattery_maps_opt, get(g:, 'flattery_maps_opt', {}))

let g:flattery_last_plugmap = ''


" Plug maps {{{2
"----------------

let s:plug = '<Plug>(flattery)'
let s:plugredofwd = 'RedoForward'
let s:plugredobak = 'RedoBackward'

let s:target_pair_info = {
      \ 'angle': {
      \   'targets': ['<', '>'],
      \   'name':    'AngleBracket',
      \ },
      \ 'square': {
      \   'targets': ['[', ']'],
      \   'name':    'SquareBracket',
      \ },
      \ 'paren': {
      \   'targets': ['(', ')'],
      \   'name':    'Paren',
      \ },
      \ 'curly': {
      \   'targets': ['{', '}'],
      \   'name':    'Curly',
      \ },
      \}

" pairs without constant, single-char targets
" aka 'virtual target'
let s:virtual_target_pair_info = {
      \ 'word': {
      \   'name': 'Word',
      \   'key':  'w',
      \ },
      \ 'limit': {
      \   'name': 'Limit',
      \   'key':  'l',
      \ },
      \}

" dict of target (or virtual target) to English name
" used for <plug>... maps
let s:single_target_names = {
      \ '.':  'Dot',
      \ '=':  'Equal',
      \ '#':  'Hash',
      \ '`':  'Backtick',
      \ '\|': 'Pipe',
      \ '/':  'Slash',
      \}

" non constant, single-char targets
" aka 'virtual target'
let s:virtual_target_info = {
      \ 'upper': {
      \   'name': 'UpperChar',
      \   'key':  'u',
      \ },
      \ 'b4eol': {
      \   'name': 'B4Eol',
      \   'key':  'z',
      \ },
      \}

" make a copy whose items are deleted on match
if !s:flattery_all_plugs
  let s:flattery_maps_cp = copy(s:flattery_maps)
endif

if s:flattery_all_plugs
  let s:target_names = copy(s:single_target_names)
else
  let s:target_names = {}
  for [k,v] in items(s:flattery_maps_cp)
    if type(v) == type([])
      let t = get(v, 0, '')
      if t != ''
        let tn = get(s:single_target_names, t, '')
        if tn != ''
          let s:target_names[t] = tn
        endif
      endif
      unlet s:flattery_maps_cp[k]
    endif
    " for vim 7.0
    unlet! v
  endfor
endif

" populate target_names with std pairs
if s:flattery_all_plugs
  for opts in values(s:target_pair_info)
    let [opening_target, closing_target] = opts['targets']
    let s:target_names[opening_target] = 'Opening'.opts['name']
    let s:target_names[closing_target] = 'Closing'.opts['name']
  endfor
else
  for [k,v] in items(s:flattery_maps_cp)
    if type(v) == type('')
      let opts = get(s:target_pair_info, v, {})
      if !empty(opts)
        let [opening_target, closing_target] = opts['targets']
        let s:target_names[opening_target] = 'Opening'.opts['name']
        let s:target_names[closing_target] = 'Closing'.opts['name']
        unlet s:flattery_maps_cp[k]
      endif
    endif
  endfor
endif

" all target names (including virtual targets, like u or z)
let s:all_target_names = copy(s:target_names)
if s:flattery_all_plugs
  for opts in values(s:virtual_target_info)
    let s:all_target_names[opts['key']] = opts['name']
  endfor
else
  for [k,v] in items(s:flattery_maps_cp)
    if type(v) == type('')
      let opts = get(s:virtual_target_info, v, {})
      if !empty(opts)
        let s:all_target_names[opts['key']] = opts['name']
        unlet s:flattery_maps_cp[k]
      endif
    endif
  endfor
endif
if s:flattery_all_plugs
  for opts in values(s:virtual_target_pair_info)
    " virtual targets with '</>' appended for direction
    let [opening_target, closing_target] = [opts['key'].'<', opts['key'].'>']
    let s:all_target_names[opening_target] = 'Opening'.opts['name']
    let s:all_target_names[closing_target] = 'Closing'.opts['name']
  endfor
else
  for [k,v] in items(s:flattery_maps_cp)
    if type(v) == type('')
      let opts = get(s:virtual_target_pair_info, v, {})
      if !empty(opts)
        let [opening_target, closing_target] = [opts['key'].'<', opts['key'].'>']
        let s:all_target_names[opening_target] = 'Opening'.opts['name']
        let s:all_target_names[closing_target] = 'Closing'.opts['name']
        unlet s:flattery_maps_cp[k]
      endif
    endif
  endfor
endif


let s:motion_names = {
      \ 'f': 'ForwardTo',
      \ 'F': 'BackwardTo',
      \ 't': 'ForwardBefore',
      \ 'T': 'BackwardBefore',
      \}

let s:virtual_motion_names = {
      \ 'x': 'ForwardAfter',
      \ 'X': 'BackwardAfter',
      \}

let s:all_motion_names = copy(s:motion_names)
if s:flattery_all_plugs || s:flattery_x_char != ''
  call extend(s:all_motion_names, s:virtual_motion_names)
endif

" <plug> sequences, indexed by vnames (virtual motion+target)
let s:plug_map = {}

" reverse of plug_map {<plug> seq. => vname}
" used for redo
let s:plug_vname = {}

" populate plug_map and plug_vname
for [target, target_name] in items(s:all_target_names)
  for [motion, motion_name] in items(s:all_motion_names)
    let s:plug_map[motion.target] = motion_name.target_name
    let s:plug_vname[motion_name.target_name] = motion.target
  endfor
endfor

" dict of {vname => vname}, reverse search according to user settings
" used for redo
let s:reverse_vname = {}


"----------------
" Functions {{{1
"----------------

" FlatterySaveLastPlug() {{{2
function! FlatterySaveLastPlug(plugmap) abort
  let g:flattery_last_plugmap = a:plugmap
  return ''
endfun

" FlatteryRedo() {{{2
" redo last search
" Args:
"   - fwd if >0 (default), bak if <0
function! FlatteryRedo(...) abort
  let redodir = a:0 ? a:1 : 1
  let s = s:gotgcs ? getcharsearch() : {'char':''}
  if s['char'] != ''
    " last f was the default one (eg. 'f<')
    let op1 = s['until']? 't' : 'f'
    let op  = ((s['forward'] && redodir>0) || (!s['forward'] && redodir<0))
          \ ? op1
          \ : toupper(op1)
    exe 'norm!' op.s['char']
  elseif g:flattery_last_plugmap != ''
    " last f was a flattery map
    if redodir<0
      " backward search, need to 'reverse' the plugmap
      let plugmap = ''
      " get virtual name for last plugmap
      if has_key(s:plug_vname, g:flattery_last_plugmap)
        let vname = s:plug_vname[g:flattery_last_plugmap]
      else
        let v:errmsg = "[FlatteryRedo] vname not found: <".
              \ g:flattery_last_plugmap.">"
        return ''
      endif
      if has_key(s:reverse_vname, vname)
        let rev_vname = s:reverse_vname[vname]
      else
        " not a pair, just change case of motion
        let rev_vname = tr(vname[0], "ftFTxX", "FTftXx").strpart(vname, 1)
      endif
      let plugmap = get(s:plug_map, rev_vname, '')
      if plugmap == ''
        " couldn't reverse that plugmap
        let v:errmsg = "[FlatteryRedo] plugmap not found: <".rev_vname.">"
        return ''
      endif
    else
      let plugmap = g:flattery_last_plugmap
    endif
    exe 'norm' "\<Plug>(flattery)Internal".plugmap
  endif
  " restore char search info to avoid side effects
  if s:gotgcs
    call setcharsearch(s)
  endif
  return ''
endfun


" flattery#SetPlugMaps() {{{2
" create all <plug> maps
function! flattery#SetPlugMaps() abort
  " non-virtual targets
  for mapcmd in ['nnoremap', 'xnoremap', 'onoremap']
    for target in keys(s:target_names)
      for op in keys(s:all_motion_names)
        if has_key(s:plug_map, op.target)
          let plugmap  = s:plug_map[op.target]
          if mapcmd ==# 'onoremap'
            let pre = 'v:exe "norm!" '
                  \ . 'v:count1.'''
            let post = '''<Bar>call FlatterySaveLastPlug('''.plugmap.''')'
                  \ .(s:gotgcs?'<Bar>'."call setcharsearch({'char':''})":"")
                  \ ."<cr>"
          else
            let pre = ''
            let post = "@=FlatterySaveLastPlug('".plugmap."')<cr>"
                  \  .(s:gotgcs
                  \     ? "@=strpart(setcharsearch({'char':''}), 9999)<cr>"
                  \     : "")
          endif
          if op is# 'x'
            let rhs = 'f'.target.'l' 
          elseif op is# 'X'
            let rhs = 'F'.target.'h' 
          else
            let rhs = op.target
          endif
          silent! exe mapcmd '<unique><silent>'  s:plug.plugmap
                \ pre.rhs.post
          silent! exe mapcmd '<unique><silent>'  s:plug.'Internal'.plugmap
                \ rhs
        else
          echoerr "[FlatterySetPlugMaps] Keys not found: <".op.target.">"
        endif
      endfor
    endfor
  endfor

  " redo maps
  for mapcmd in ['nnoremap', 'xnoremap', 'onoremap']
    silent! exe mapcmd '<unique><silent>'  s:plug.s:plugredofwd
          \ "@=FlatteryRedo(1)<cr>"
    " silent! exe mapcmd '<unique><silent>'  s:plug.s:plugredobak
    silent! exe mapcmd  s:plug.s:plugredobak
          \ "@=FlatteryRedo(-1)<cr>"
  endfor

  " Notice: size of matched text matters!
  " eg. '.\u' is _not_ equivalent to '.\u\@=' for those searches

  " to uppercase
  if s:flattery_all_plugs || has_key(s:all_target_names, 'u')
    let opts = {'fwd': {}, 'bak': {}, 'type': 'search'}
    let opts['fwd']['f'] = '"\\u", ""'
    let opts['fwd']['t'] = '".\\u\\@=", "z"'
    let opts['fwd']['x'] = '"\\u\\@1<=.", "z"'
    let opts['bak']['f'] = '"\\u", "b"'
    let opts['bak']['t'] = '"\\u\\@1<=.", "b"'
    let opts['bak']['x'] = '".\\u\\@=", "b"'
    call s:FlatterySetPlugMap('u', opts)
  endif

  " just before bol/eol
  if s:flattery_all_plugs || has_key(s:all_target_names, 'z')
    let opts = {'fwd': {}, 'bak': {}, 'type': 'search'}
    let opts['fwd']['f'] = '".\\S\\s*$", ""'
    let opts['fwd']['t'] = '"..\\S\\s*$", "z"'
    let opts['fwd']['x'] = '"\\S\\s*$", ""'
    let opts['bak']['f'] = '"^\\s*\\S\\zs.", "b"'
    let opts['bak']['t'] = '"^\\s*\\S.\\zs.", "b"'
    let opts['bak']['x'] = '"^\\s*\\zs\\S", "b"'
    call s:FlatterySetPlugMap('z', opts)
  endif

  " to non-letter
  if s:flattery_all_plugs || has_key(s:all_target_names, 'l<')
    let opts = {'fwd': {}, 'bak': {}, 'type': 'search'}
    let opts['fwd']['f'] = '"[^[:alnum:]][[:alnum:]]", "z"'
    let opts['fwd']['t'] = '".[^[:alnum:]][[:alnum:]]", "z"'
    let opts['fwd']['x'] = '"[^[:alnum:]]\\zs[[:alnum:]]", "z"'
    let opts['bak']['f'] = '"[^[:alnum:]][[:alnum:]]", "b"'
    let opts['bak']['t'] = '"\\([^[:alnum:]]\\\|^\\)\\zs[[:alnum:]]", "b"'
    let opts['bak']['x'] = '".[^[:alnum:]][[:alnum:]]", "b"'
    call s:FlatterySetPlugMap('l<', opts)
    let opts = {'fwd': {}, 'bak': {}, 'type': 'search'}
    let opts['fwd']['f'] = '"[[:alnum:]]\\zs[^[:alnum:]]", "z"'
    let opts['fwd']['t'] = '"[[:alnum:]]\\([^[:alnum:]]\\\|$\\)", "z"'
    let opts['fwd']['x'] = '"[[:alnum:]][^[:alnum:]]\\zs.", "z"'
    let opts['bak']['f'] = '"[[:alnum:]]\\zs[^[:alnum:]]", "b"'
    let opts['bak']['t'] = '"\\([[:alnum:]][^[:alnum:]]\\\|^\\)\\zs.", "b"'
    let opts['bak']['x'] = '"[[:alnum:]][^[:alnum:]]", "b"'
    call s:FlatterySetPlugMap('l>', opts)
  endif

  " to next word
  if s:flattery_all_plugs || has_key(s:all_target_names, 'w<')
    let opts = {'fwd': {}, 'bak': {}, 'type': 'search'}
    let opts['fwd']['f'] = '"[[:alnum:]]\\+", ""'
    let opts['fwd']['t'] = '"[^[:alnum:]][[:alnum:]]\\+", ""'
    let opts['fwd']['x'] =
          \ '"\\%#[[:alnum:]]*[^[:alnum:]]\\+' .
          \ '[[:alnum:]]\\zs[[:alnum:]]\\+", ""'
    let opts['bak']['f'] =
          \ '"[[:alnum:]]\\+' .
          \ '\\%([^[:alnum:]]*\\%#[^[:alnum:]]\\\|' .
          \ '[^[:alnum:]]\\+[[:alnum:]]*\\%#[[:alnum:]]\\)", "b"'
    let opts['bak']['t'] =
          \ '"[[:alnum:]]\\zs[[:alnum:]]\\+' .
          \ '\\%([^[:alnum:]]*\\%#[^[:alnum:]]\\\|' .
          \ '[^[:alnum:]]\\+[[:alnum:]]*\\%#[[:alnum:]]\\)", "b"'
    let opts['bak']['x'] =
          \ '"[^[:alnum:]][[:alnum:]]\\+' .
          \ '\\%([^[:alnum:]]*\\%#[^[:alnum:]]\\\|' .
          \ '[^[:alnum:]]\\+[[:alnum:]]*\\%#[[:alnum:]]\\)", "b"'
    call s:FlatterySetPlugMap('w<', opts)
    let opts = {'fwd': {}, 'bak': {}, 'type': 'search'}
    let opts['fwd']['f'] =
          \ '"\\%#[[:alnum:]]*[^[:alnum:]]\\+[[:alnum:]]*' .
          \ '\\zs[[:alnum:]]\\%([^[:alnum:]]\\\|$\\)", ""'
    let opts['fwd']['t'] =
          \ '"\\%#[[:alnum:]]*[^[:alnum:]]\\+[[:alnum:]]*' .
          \ '\\zs[[:alnum:]][[:alnum:]]\\%([^[:alnum:]]\\\|$\\)", ""'
    let opts['fwd']['x'] =
          \ '"\\%#[[:alnum:]]*[^[:alnum:]]\\+[[:alnum:]]*' .
          \ '[[:alnum:]]\\zs[^[:alnum:]]", ""'
    let opts['bak']['f'] = '"[[:alnum:]][^[:alnum:]]", "b"'
    let opts['bak']['t'] = '"[[:alnum:]]\\zs[^[:alnum:]]", "b"'
    let opts['bak']['x'] = '"[[:alnum:]][[:alnum:]][^[:alnum:]]", "b"'
    call s:FlatterySetPlugMap('w>', opts)
  endif
endfun


" s:FlatterySetPlugMap {{{2
" create the <plug>... maps for fchar
" Args:
"   - fchar: virtual target, used to build <plug>Name
"   - opts:  dict of options, used to build the map value
"            contains normal cmds or regexps, depending on 'type' key
function! s:FlatterySetPlugMap(fchar, opts) abort
  let targets = has_key(s:all_motion_names, 'x')
        \ ? ['f', 't', 'x']
        \ : ['f', 't']
  for mapcmd in ['nnoremap', 'xnoremap', 'onoremap']
    for op in targets
      " dict of {vname => rhs}
      let rhs_map = {}
      if has_key(a:opts['fwd'], op)
        let rhs_map[op.a:fchar] = a:opts['fwd'][op]
      endif
      if has_key(a:opts['bak'], op)
        let rhs_map[toupper(op).a:fchar] = a:opts['bak'][op]
      endif
      " set rhs format according to type
      let type = get(a:opts, 'type', '')
      if type ==? "search"
        if mapcmd[0] ==# 'o'
          let fmt = 'v:exe "norm!" '
                \ . 'v:count1.''@=search(%s, line("."))''."\<lt>cr>"%s<cr>'
          let postfmt = "<Bar>call FlatterySaveLastPlug('%s')"
                \ . (s:gotgcs?"<Bar>call setcharsearch({'char':''})":"")
        else
          let fmt = '@=strpart(search(%s, line(".")), 9999)<cr>%s'
          let postfmt = "@=FlatterySaveLastPlug('%s')<cr>"
                \ . (s:gotgcs
                \   ? "@=strpart(setcharsearch({'char':''}), 9999)<cr>"
                \   : "")
        endif
      else
        echoerr "[FlatterySetPlugMap] Unknown type: <".type.">"
        continue
      endif
      for [vname, rhs] in items(rhs_map)
        if has_key(s:plug_map, vname)
          let plugmap = s:plug_map[vname]
          let post  = printf(postfmt, plugmap)
          silent! exe mapcmd '<unique><silent>' s:plug.plugmap
                \ printf(fmt, rhs, post)
          silent! exe mapcmd '<unique><silent>' s:plug.'Internal'.plugmap
                \ printf(fmt, rhs, '')
        else
          echoerr "[FlatterySetPlugMap] vname not found: <".vname.">"
          continue
        endif
      endfor
    endfor
  endfor
endfun


" flattery#SetUserMaps {{{2
" bind user keys to <plug> maps
function! flattery#SetUserMaps() abort
  let f = s:flattery_f_map
  let t = s:flattery_t_map
  let x = s:flattery_x_char
  let g = s:flattery_alt_char
  let v = s:flattery_orig_char
  let j = s:flattery_redo_char
  let user_map = {
        \ 'f': f,
        \ 't': t,
        \ 'x': x,
        \ 'g': g,
        \ 'v': v,
        \ 'j': j,
        \}

  if !s:flattery_nomap_ff && index(s:flattery_nomap_list, f) == -1
    silent! exe 'map <unique>'  f.f  'F'
    silent! exe 'sunmap'        f.f
    silent! exe 'map <unique>'  t.t  'T'
    silent! exe 'sunmap'        t.t
  endif

  " orig f/t on v
  if v != '' && index(s:flattery_nomap_list, v) == -1
    for mapcmd in ['nnoremap', 'xnoremap', 'onoremap']
      for op in [f, t]
        silent! exe mapcmd '<unique>'  op.v           op
        silent! exe mapcmd '<unique>'  toupper(op).v  toupper(op)
      endfor
    endfor
  endif

  " redo map
  if j != '' && index(s:flattery_nomap_list, j) == -1
    for mapcmd in ['nmap', 'xmap', 'omap']
      silent! exe mapcmd '<unique><silent>'  f.j
            \ s:plug.s:plugredofwd
      silent! exe mapcmd '<unique><silent>'  toupper(f).j
            \ s:plug.s:plugredobak
    endfor
  endif

  " bind user to plug maps
  for [fchar, targets] in items(s:flattery_maps)
    if index(s:flattery_nomap_list, fchar) != -1
      unlet! fchar targets
      continue
    endif
    " induce type of mapping from option dict
    let is_single  = 0
    let is_virtual = 0
    if type(targets) is type([]) && len(targets) == 1 
      let is_single = 1
    elseif type(targets) is type('') && has_key(s:virtual_target_info, targets)
      let is_single  = 1
      let is_virtual = 1
    endif
    for mapcmd in ['nmap', 'xmap', 'omap']
      " loop on virtual motions used in 'plug_map' keys
      let vmotions = (x == '' || index(s:flattery_nomap_list, x) != -1)
            \ ? ['f', 't']
            \ : ['f', 't', 'x']
      for op in vmotions
        if is_single
          " single target
          let target = is_virtual
                  \ ? s:virtual_target_info[targets]['key']
                  \ : targets[0]
          " dict of {user_lhs => vname}
          let vnames = {}
          let uop = op ==# 'x' ? user_map['f'] : user_map[op]
          let after_uop = op ==# 'x' ? x.fchar : fchar
          let vnames[uop.after_uop] = op.target
          let vnames[toupper(uop).after_uop] = toupper(op).target
          for [lhs, vname] in items(vnames)
            if has_key(s:plug_map, vname)
              let rhs = s:plug_map[vname]
              silent! exe mapcmd '<unique>'  lhs  s:plug.rhs
            endif
          endfor
        else
          " pairs
          if type(targets) is type('')
            " virtual pair target
            if has_key(s:target_pair_info, targets)
              let info = s:target_pair_info[targets]
              let [o, c] = info['targets']
            elseif has_key(s:virtual_target_pair_info, targets)
              let info = s:virtual_target_pair_info[targets]
              let [o, c] = [info['key'].'<', info['key'].'>']
            else
              echoerr "[FlatterySetUserMaps] Bad setting for ".fchar.
                    \ ": <".string(targets).">"
              unlet! fchar targets
              continue
            endif
          elseif type(targets) is type([]) && len(targets) == 2
            " normal pair
            let [o, c] = targets
          else
            echoerr "[FlatterySetUserMaps] Bad setting for ".fchar.
                  \ ": <".string(targets).">"
            unlet! fchar targets
            continue
          endif
          let opts       = get(s:flattery_maps_opt, targets, {})
          let uop        = op ==# 'x' ? user_map['f'] : user_map[op]
          let after_uop  = op ==# 'x' ? x.fchar : fchar
          " dict of {user_lhs => vname}
          let vnames = {}
          let to_closing = get(opts,'to_closing',s:flattery_default_to_closing)
          let alt_dirs   = get(opts,'alt_dirs',s:flattery_default_alt_dirs)
          if to_closing
            if alt_dirs
              " [fwd, bak, altfwd, altbak]
              let vtargets = [c, o, o, c]
            else
              let vtargets = [c, c, o, o]
            endif
          else
            if alt_dirs
              let vtargets = [o, c, c, o]
            else
              let vtargets = [o, o, c, c]
            endif
          endif
          " remember reverse motion for redo
          let vn0 = op.vtargets[0]
          let vn1 = toupper(op).vtargets[1]
          let vn2 = op.vtargets[1]
          let vn3 = toupper(op).vtargets[2]
          let s:reverse_vname[vn0] = vn1
          let s:reverse_vname[vn1] = vn0
          let s:reverse_vname[vn2] = vn3
          let s:reverse_vname[vn3] = vn2
          "
          if g != ''
            let lhs_list = [uop.after_uop, toupper(uop).after_uop,
                          \ uop.g.after_uop, toupper(uop).g.after_uop]
          else
            let lhs_list = [uop.after_uop, toupper(uop).after_uop]
          endif
          " populate vnames dict, indexed by user lhs
          for i in range(len(lhs_list))
            let vop = i%2 ? toupper(op) : op
            let vnames[lhs_list[i]] = vop.vtargets[i]
          endfor
          for [lhs, vname] in items(vnames)
            if has_key(s:plug_map, vname)
              let rhs = s:plug_map[vname]
              silent! exe mapcmd '<unique>'  lhs  s:plug.rhs
            endif
          endfor
        endif
      endfor
    endfor
    unlet! fchar targets
  endfor
endfun

let &cpo = s:save_cpo

" vim: et sw=2 ts=2 ft=vim:
