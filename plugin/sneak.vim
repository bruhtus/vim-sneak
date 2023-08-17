" sneak.vim - The missing motion
" Author:       Justin M. Keyes
" Version:      1.8
" License:      MIT

if exists('g:loaded_sneak_plugin') || &compatible || v:version < 700
  finish
endif
let g:loaded_sneak_plugin = 1

let s:cpo_save = &cpo
set cpo&vim

" Persist state for repeat.
"     opfunc    : &operatorfunc at g@ invocation.
"     opfunc_st : State during last 'operatorfunc' (g@) invocation.
let s:st = { 'rst':1, 'input':'', 'inputlen':0, 'reverse':0, 'bounds':[0,0],
      \'inclusive':0, 'label':'', 'opfunc':'', 'opfunc_st':{} }

if exists('##OptionSet')
  augroup sneak_optionset
    autocmd!
    autocmd OptionSet operatorfunc let s:st.opfunc = &operatorfunc | let s:st.opfunc_st = {}
  augroup END
endif

func! s:init() abort
  unlockvar g:sneak#opt
  "options                                 v-- for backwards-compatibility
  let g:sneak#opt = {
      \ 's_next'        : get(g:, 'sneak#s_next', 0)
      \ ,'absolute_dir' : get(g:, 'sneak#absolute_dir', 0)
      \ ,'use_ic_scs'   : get(g:, 'sneak#use_ic_scs', 1)
      \ ,'map_netrw'    : get(g:, 'sneak#map_netrw', 0)
      \ ,'label'        : get(g:, 'sneak#label', get(g:, 'sneak#streak', 1)) && (v:version >= 703) && has("conceal")
      \ ,'label_esc'    : get(g:, 'sneak#label_esc', get(g:, 'sneak#streak_esc', "\<space>"))
      \ ,'prompt'       : get(g:, 'sneak#prompt', '>')
      \ }

  lockvar g:sneak#opt
endf

call s:init()

func! SneakState() abort
  return deepcopy(s:st)
endf

onoremap <silent> <Plug>SneakRepeat :<c-u>call sneak#wrap(v:operator, sneak#util#getc(), sneak#util#getc(), sneak#util#getc(), sneak#util#getc())<cr>

" repeat motion (explicit--as opposed to implicit 'clever-s')
nnoremap <silent> <Plug>Sneak_; :<c-u>call sneak#rpt('', 0)<cr>
nnoremap <silent> <Plug>Sneak_, :<c-u>call sneak#rpt('', 1)<cr>
xnoremap <silent> <Plug>Sneak_; :<c-u>call sneak#rpt(visualmode(), 0)<cr>
xnoremap <silent> <Plug>Sneak_, :<c-u>call sneak#rpt(visualmode(), 1)<cr>
onoremap <silent> <Plug>Sneak_; :<c-u>call sneak#rpt(v:operator, 0)<cr>
onoremap <silent> <Plug>Sneak_, :<c-u>call sneak#rpt(v:operator, 1)<cr>

nnoremap <silent> <Plug>SneakLabel_s m':<c-u>call sneak#wrap('', 2, 0, 2, 2)<cr>
nnoremap <silent> <Plug>SneakLabel_S m':<c-u>call sneak#wrap('', 2, 1, 2, 2)<cr>
xnoremap <silent> <Plug>SneakLabel_s m':<c-u>call sneak#wrap(visualmode(), 2, 0, 2, 2)<cr>
xnoremap <silent> <Plug>SneakLabel_S m':<c-u>call sneak#wrap(visualmode(), 2, 1, 2, 2)<cr>
onoremap <silent> <Plug>SneakLabel_s :<c-u>call sneak#wrap(v:operator, 2, 0, 2, 2)<cr>
onoremap <silent> <Plug>SneakLabel_S :<c-u>call sneak#wrap(v:operator, 2, 1, 2, 2)<cr>

if g:sneak#opt.map_netrw && -1 != stridx(maparg("s", "n"), "Sneak")
  func! s:map_netrw_key(key) abort
    let expanded_map = maparg(a:key,'n')
    if !strlen(expanded_map) || expanded_map =~# '_Net\|FileBeagle'
      if strlen(expanded_map) > 0 "else, mapped to <nop>
        silent exe (expanded_map =~# '<Plug>' ? 'nmap' : 'nnoremap').' <buffer> <silent> <leader>'.a:key.' '.expanded_map
      endif
      "unmap the default buffer-local mapping to allow Sneak's global mapping.
      silent! exe 'nunmap <buffer> '.a:key
    endif
  endf

  augroup sneak_netrw
    autocmd!
    autocmd FileType netrw,filebeagle autocmd sneak_netrw CursorMoved <buffer>
          \ call <sid>map_netrw_key('s') | call <sid>map_netrw_key('S') | autocmd! sneak_netrw * <buffer>
  augroup END
endif


let &cpo = s:cpo_save
unlet s:cpo_save
