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
let g:st = { 'rst':1, 'input':'', 'inputlen':0, 'reverse':0, 'bounds':[0,0],
      \'inclusive':0, 'label':'', 'opfunc':'', 'opfunc_st':{} }

if exists('##OptionSet')
  augroup sneak_optionset
    autocmd!
    autocmd OptionSet operatorfunc let g:st.opfunc = &operatorfunc | let g:st.opfunc_st = {}
  augroup END
endif

func! s:sneak_init() abort
  unlockvar g:sneak#opt
  "options                                 v-- for backwards-compatibility
  let g:sneak#opt = { 'f_reset' : get(g:, 'sneak#nextprev_f', get(g:, 'sneak#f_reset', 1))
      \ ,'t_reset'      : get(g:, 'sneak#nextprev_t', get(g:, 'sneak#t_reset', 1))
      \ ,'s_next'       : get(g:, 'sneak#s_next', 0)
      \ ,'absolute_dir' : get(g:, 'sneak#absolute_dir', 0)
      \ ,'use_ic_scs'   : get(g:, 'sneak#use_ic_scs', 0)
      \ ,'map_netrw'    : get(g:, 'sneak#map_netrw', 1)
      \ ,'label'        : get(g:, 'sneak#label', get(g:, 'sneak#streak', 0)) && (v:version >= 703) && has("conceal")
      \ ,'label_esc'    : get(g:, 'sneak#label_esc', get(g:, 'sneak#streak_esc', "\<space>"))
      \ ,'prompt'       : get(g:, 'sneak#prompt', '>')
      \ }

  " for k in ['f', 't'] "if user mapped f/t to Sneak, then disable f/t reset.
  "   if maparg(k, 'n') =~# 'Sneak'
  "     let g:sneak#opt[k.'_reset'] = 0
  "   endif
  " endfor
  lockvar g:sneak#opt
endf

call s:sneak_init()

nnoremap <silent> <Plug>SneakLabel_s m':<C-u>call sneak#wrap('', 2, 0, 2, 2)<CR>
nnoremap <silent> <Plug>SneakLabel_S m':<C-u>call sneak#wrap('', 2, 1, 2, 2)<CR>

xnoremap <silent> <Plug>SneakLabel_s
      \ m':<C-u>call sneak#wrap(visualmode(), 2, 0, 2, 2)<CR>
xnoremap <silent> <Plug>SneakLabel_S
      \ m':<C-u>call sneak#wrap(visualmode(), 2, 1, 2, 2)<CR>

nnoremap <silent> <Plug>Sneak_; m':<c-u>call sneak#rpt('', 0)<cr>
nnoremap <silent> <Plug>Sneak_, m':<c-u>call sneak#rpt('', 1)<cr>
xnoremap <silent> <Plug>Sneak_; m':<c-u>call sneak#rpt(visualmode(), 0)<cr>
xnoremap <silent> <Plug>Sneak_, m':<c-u>call sneak#rpt(visualmode(), 1)<cr>

"if g:sneak#opt.map_netrw && -1 != stridx(maparg("s", "n"), "Sneak")
"  func! s:map_netrw_key(key) abort
"    let expanded_map = maparg(a:key,'n')
"    if !strlen(expanded_map) || expanded_map =~# '_Net\|FileBeagle'
"      if strlen(expanded_map) > 0 "else, mapped to <nop>
"        silent exe (expanded_map =~# '<Plug>' ? 'nmap' : 'nnoremap').' <buffer> <silent> <leader>'.a:key.' '.expanded_map
"      endif
"      "unmap the default buffer-local mapping to allow Sneak's global mapping.
"      silent! exe 'nunmap <buffer> '.a:key
"    endif
"  endf

"  augroup sneak_netrw
"    autocmd!
"    autocmd FileType netrw,filebeagle autocmd sneak_netrw CursorMoved <buffer>
"          \ call <sid>map_netrw_key('s') | call <sid>map_netrw_key('S') | autocmd! sneak_netrw * <buffer>
"  augroup END
"endif


let &cpo = s:cpo_save
unlet s:cpo_save
