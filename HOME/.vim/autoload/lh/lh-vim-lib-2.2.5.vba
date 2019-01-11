" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/lh/askvim.vim	[[[1
147
"=============================================================================
" $Id: askvim.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		autoload/lh/askvim.vim                                    {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	17th Apr 2007
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $ (17th Apr 2007)
"------------------------------------------------------------------------
" Description:	
" 	Defines functions that asks vim what it is relinquish to tell us
" 	- menu
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	
" 	v2.0.0:
" TODO:		«missing features»
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#askvim#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#askvim#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Public {{{2
" Function: lh#askvim#exe(command) {{{3
function! lh#askvim#Exe(command)
  echomsg 'lh#askvim#Exe() is deprecated, use lh#askvim#exe()'
  return lh#askvim#exe(a:command)
endfunction

function! lh#askvim#exe(command)
  let save_a = @a
  try 
    silent! redir @a
    silent! exe a:command
    redir END
  finally
    " Always restore everything
    let res = @a
    let @a = save_a
    return res
  endtry
endfunction


" Function: lh#askvim#menu(menuid) {{{3
function! s:AskOneMenu(menuact, res)
  let sKnown_menus = lh#askvim#exe(a:menuact)
  let lKnown_menus = split(sKnown_menus, '\n')
  " echo string(lKnown_menus)

  " 1- search for the menuid
  " todo: fix the next line to correctly interpret "stuff\.stuff" and
  " "stuff\\.stuff".
  let menuid_parts = split(a:menuact, '\.')

  let simplifiedKnown_menus = deepcopy(lKnown_menus)
  call map(simplifiedKnown_menus, 'substitute(v:val, "&", "", "g")')
  " let idx = lh#list#match(simplifiedKnown_menus, '^\d\+\s\+'.menuid_parts[-1])
  let idx = match(simplifiedKnown_menus, '^\d\+\s\+'.menuid_parts[-1])
  if idx == -1
    " echo "not found"
    return
  endif
  " echo "l[".idx."]=".lKnown_menus[idx]

  if empty(a:res)
    let a:res.priority = matchstr(lKnown_menus[idx], '\d\+\ze\s\+.*')
    let a:res.name     = matchstr(lKnown_menus[idx], '\d\+\s\+\zs.*')
    let a:res.actions  = {}
  " else
  "   what if the priority isn't the same?
  endif

  " 2- search for the menu definition
  let idx += 1
  while idx != len(lKnown_menus)
    echo "l[".idx."]=".lKnown_menus[idx]
    " should not happen
    if lKnown_menus[idx] =~ '^\d\+' | break | endif

    " :h showing-menus
    " -> The format of the result of the call to Exe() seems to be:
    "    ^ssssMns-sACTION$
    "    s == 1 whitespace
    "    M == mode (inrvcs)
    "    n == noremap(*)/script(&)
    "    - == disable(-)/of not
    let act = {}
    let menu_def = matchlist(lKnown_menus[idx],
	  \ '^\s*\([invocs]\)\([&* ]\) \([- ]\) \(.*\)$')
    if len(menu_def) > 4
      let act.mode        = menu_def[1]
      let act.nore_script = menu_def[2]
      let act.disabled    = menu_def[3]
      let act.action      = menu_def[4]
    else
      echomsg string(menu_def)
      echoerr "lh#askvim#menu(): Cannot decode ``".lKnown_menus[idx]."''"
    endif
    
    let a:res.actions["mode_" . act.mode] = act

    let idx += 1
  endwhile

  " n- Return the result
  return a:res
endfunction

function! lh#askvim#menu(menuid, modes)
  let res = {}
  let i = 0
  while i != strlen(a:modes)
    call s:AskOneMenu(a:modes[i].'menu '.a:menuid, res)
    let i += 1
  endwhile
  return res
endfunction
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/buffer.vim	[[[1
97
"=============================================================================
" $Id: buffer.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		autoload/lh/buffer.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	23rd Jan 2007
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	
" 	Defines functions that help finding windows and handling buffers.
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	
"	v 1.0.0 First Version
" 	(*) Functions moved from searchInRuntimeTime  
" 	v 2.2.0
" 	(*) new function: lh#buffer#list()
" TODO:	
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim

" ## Functions {{{1
"------------------------------------------------------------------------
" # Debug {{{2
function! lh#buffer#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#buffer#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Public {{{2

" Function: lh#buffer#find({filename}) {{{3
" If {filename} is opened in a window, jump to this window, otherwise return -1
" Moved from searchInRuntimeTime.vim
function! lh#buffer#find(filename)
  let b = bufwinnr(a:filename)
  if b == -1 | return b | endif
  exe b.'wincmd w'
  return b
endfunction
function! lh#buffer#Find(filename)
  return lh#buffer#find(a:filename)
endfunction

" Function: lh#buffer#jump({filename},{cmd}) {{{3
function! lh#buffer#jump(filename, cmd)
  if lh#buffer#find(a:filename) != -1 | return | endif
  exe a:cmd . ' ' . a:filename
endfunction
function! lh#buffer#Jump(filename, cmd)
  return lh#buffer#jump(a:filename, a:cmd)
endfunction

" Function: lh#buffer#scratch({bname},{where}) {{{3
function! lh#buffer#scratch(bname, where)
  try
    silent exe a:where.' sp '.a:bname
  catch /.*/
    throw "Can't open a buffer named '".a:bname."'!"
  endtry
  setlocal bt=nofile bh=wipe nobl noswf ro
endfunction
function! lh#buffer#Scratch(bname, where)
  return lh#buffer#scratch(a:bname, a:where)
endfunction

" Function: lh#buffer#list() {{{3
function! lh#buffer#list()
  let all = range(0, bufnr('$'))
  " let res = lh#list#transform_if(all, [], 'v:1_', 'buflisted')
  let res = lh#list#copy_if(all, [], 'buflisted')
  return res
endfunction
" Ex: echo lh#list#transform(lh#buffer#list(), [], "bufname")
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/buffer/dialog.vim	[[[1
268
"=============================================================================
" $Id: dialog.vim 253 2010-12-01 00:02:53Z luc.hermitte $
" File:		autoload/lh/buffer/dialog.vim                            {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.2
" Created:	21st Sep 2007
" Last Update:	$Date: 2010-12-01 01:02:53 +0100 (mer., 01 dÃ©c. 2010) $
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	
"	v 1.0.0 First Version
" 	(*) Functions imported from Mail_mutt_alias.vim
" TODO:		
" 	(*) --abort-- line
" 	(*) custom messages
" 	(*) do not mess with search history
" 	(*) support any &magic
" 	(*) syntax
" 	(*) add number/letters
" 	(*) tag with '[x] ' instead of '* '
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim



"=============================================================================
" ## Globals {{{1
let s:LHdialog = {}

"=============================================================================
" ## Functions {{{1
" # Debug {{{2
function! lh#buffer#dialog#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#buffer#dialog#debug(expr)
  return eval(a:expr)
endfunction


"=============================================================================
" # Dialog functions {{{2
"------------------------------------------------------------------------
function! s:Mappings(abuffer)
  " map <enter> to edit a file, also dbl-click
  exe "nnoremap <silent> <buffer> <esc>         :silent call ".a:abuffer.action."(-1, ".a:abuffer.id.")<cr>"
  exe "nnoremap <silent> <buffer> q             :call lh#buffer#dialog#select(-1, ".a:abuffer.id.")<cr>"
  exe "nnoremap <silent> <buffer> <cr>          :call lh#buffer#dialog#select(line('.'), ".a:abuffer.id.")<cr>"
  " nnoremap <silent> <buffer> <2-LeftMouse> :silent call <sid>GrepEditFileLine(line("."))<cr>
  " nnoremap <silent> <buffer> Q	  :call <sid>Reformat()<cr>
  " nnoremap <silent> <buffer> <Left>	  :set tabstop-=1<cr>
  " nnoremap <silent> <buffer> <Right>	  :set tabstop+=1<cr>
  if a:abuffer.support_tagging
    nnoremap <silent> <buffer> t	  :silent call <sid>ToggleTag(line("."))<cr>
    nnoremap <silent> <buffer> <space>	  :silent call <sid>ToggleTag(line("."))<cr>
  endif
  nnoremap <silent> <buffer> <tab>	  :silent call <sid>NextChoice('')<cr>
  nnoremap <silent> <buffer> <S-tab>	  :silent call <sid>NextChoice('b')<cr>
  exe "nnoremap <silent> <buffer> h	  :silent call <sid>ToggleHelp(".a:abuffer.id.")<cr>"
endfunction

"----------------------------------------
" Tag / untag the current choice {{{
function! s:ToggleTag(lineNum)
   if a:lineNum > s:Help_NbL()
      " If tagged
      if (getline(a:lineNum)[0] == '*')
	let b:NbTags = b:NbTags - 1
	silent exe a:lineNum.'s/^\* /  /e'
      else
	let b:NbTags = b:NbTags + 1
	silent exe a:lineNum.'s/^  /* /e'
      endif
      " Move after the tag ; there is something with the two previous :s. They
      " don't leave the cursor at the same position.
      silent! normal! 3|
      call s:NextChoice('') " move to the next choice
    endif
endfunction
" }}}

function! s:Help_NbL()
  " return 1 + nb lines of BuildHelp
  return 2 + len(b:dialog['help_'.b:dialog.help_type])
endfunction
"----------------------------------------
" Go to the Next (/previous) possible choice. {{{
function! s:NextChoice(direction)
  " echomsg "next!"
  call search('^[ *]\s*\zs\S\+', a:direction)
endfunction
" }}}

"------------------------------------------------------------------------

function! s:RedisplayHelp(dialog)
  silent! 2,$g/^@/d_
  normal! gg
  for help in a:dialog['help_'.a:dialog.help_type]
    silent put=help
  endfor
endfunction

function! lh#buffer#dialog#update(dialog)
  set noro
  exe (s:Help_NbL()+1).',$d_'
  for choice in a:dialog.choices
    silent $put='  '.choice
  endfor
  set ro
endfunction

function! s:Display(dialog, atitle)
  set noro
  0 put = a:atitle
  call s:RedisplayHelp(a:dialog)
  for choice in a:dialog.choices
    silent $put='  '.choice
  endfor
  set ro
  exe s:Help_NbL()+1
endfunction

function! s:ToggleHelp(bufferId)
  call lh#buffer#find(a:bufferId)
  call b:dialog.toggle_help()
endfunction

function! lh#buffer#dialog#toggle_help() dict
  let self.help_type 
	\ = (self.help_type == 'short')
	\ ? 'long'
	\ : 'short'
  call s:RedisplayHelp(self)
endfunction

function! lh#buffer#dialog#new(bname, title, where, support_tagging, action, choices)
  " The ID will be the buffer id
  let res = {}
  let where_it_started = getpos('.')
  let where_it_started[0] = bufnr('%')
  let res.where_it_started = where_it_started

  try
    call lh#buffer#scratch(a:bname, a:where)
  catch /.*/
    echoerr v:exception
    return res
  endtry
  let res.id              = bufnr('%')
  let b:NbTags            = 0
  let b:dialog            = res
  let s:LHdialog[res.id]  = res
  let res.help_long       = []
  let res.help_short      = []
  let res.help_type       = 'short'
  let res.support_tagging = a:support_tagging
  let res.action	  = a:action
  let res.choices	  = a:choices

  " Long help
  call lh#buffer#dialog#add_help(res, '@| <cr>, <double-click>    : select this', 'long')
  call lh#buffer#dialog#add_help(res, '@| <esc>, q                : Abort', 'long')
  if a:support_tagging
    call lh#buffer#dialog#add_help(res, '@| <t>, <space>            : Tag/Untag the current item', 'long')
  endif
  call lh#buffer#dialog#add_help(res, '@| <up>/<down>, <tab>, +/- : Move between entries', 'long')
  call lh#buffer#dialog#add_help(res, '@|', 'long')
  " call lh#buffer#dialog#add_help(res, '@| h                       : Toggle help', 'long')
  call lh#buffer#dialog#add_help(res, '@+'.repeat('-', winwidth(bufwinnr(res.id))-3), 'long')
  " Short Help
  " call lh#buffer#dialog#add_help(res, '@| h                       : Toggle help', 'short')
  call lh#buffer#dialog#add_help(res, '@+'.repeat('-', winwidth(bufwinnr(res.id))-3), 'short')

  let res.toggle_help = function("lh#buffer#dialog#toggle_help")
  let title = '@  ' . a:title
  let helpstr = '| Toggle (h)elp'
  let title = title 
	\ . repeat(' ', winwidth(bufwinnr(res.id))-lh#encoding#strlen(title)-lh#encoding#strlen(helpstr)-1)
	\ . helpstr
  call s:Display(res, title)
 
  call s:Mappings(res)
  return res
endfunction

function! lh#buffer#dialog#add_help(abuffer, text, help_type)
  call add(a:abuffer['help_'.a:help_type],a:text)
endfunction

"=============================================================================
function! lh#buffer#dialog#quit()
  let bufferId = b:dialog.where_it_started[0]
  echohl WarningMsg
  echo "Abort"
  echohl None
  quit
  call lh#buffer#find(bufferId)
endfunction

" Function: lh#buffer#dialog#select(line, bufferId [,overriden-action])
function! lh#buffer#dialog#select(line, bufferId, ...)
  if a:line == -1
    call lh#buffer#dialog#quit()
    return
  " elseif a:line <= s:Help_NbL() + 1
  elseif a:line <= s:Help_NbL() 
    echoerr "Unselectable item"
    return 
  else
    let dialog = s:LHdialog[a:bufferId]
    let results = { 'dialog' : dialog, 'selection' : []  }

    if b:NbTags == 0
      " -1 because first index is 0
      " let results = [ dialog.choices[a:line - s:Help_NbL() - 1] ]
      let results.selection = [ a:line - s:Help_NbL() - 1 ]
    else
      silent g/^* /call add(results.selection, line('.')-s:Help_NbL()-1)
    endif
  endif

  if a:0 > 0 " action overriden
    exe 'call '.dialog.action.'(results, a:000)'
  else
    exe 'call '.dialog.action.'(results)'
  endif
endfunction
function! lh#buffer#dialog#Select(line, bufferId, ...)
  echomsg "lh#buffer#dialog#Select() is deprecated, use lh#buffer#dialog#select() instead"
  if a:0 > 0 " action overriden
    exe 'call lh#buffer#dialog#select(a:line,  a:bufferId, a:1)'
  else
    exe 'call lh#buffer#dialog#select(a:line,  a:bufferId)'
  endif
endfunction

function! Action(results)
  let dialog = a:results.dialog
  let choices = dialog.choices
  for r in a:results.selection
    echomsg '-> '.choices[r]
  endfor
endfunction


"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/command.vim	[[[1
224
"=============================================================================
" $Id: command.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		autoload/lh/command.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	08th Jan 2007
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $ (08th Jan 2007)
"------------------------------------------------------------------------
" Description:	
" 	Helpers to define commands that:
" 	- support subcommands
" 	- support autocompletion
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	
" 	v2.0.0:
" 		Code move from other plugins
" TODO:		«missing features»
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim

" ## Debug {{{1
function! lh#command#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#command#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Functions {{{1

" Tool functions {{{2
" Function: lh#command#Fargs2String(aList) {{{3
" @param[in,out] aList list of params from <f-args>
" @see tests/lh/test-Fargs2String.vim
function! lh#command#Fargs2String(aList)
  if empty(a:aList) | return '' | endif

  let quote_char = a:aList[0][0] 
  let res = a:aList[0]
  call remove(a:aList, 0)
  if quote_char !~ '["'."']"
    return res
  endif
  " else
  let end_string = '[^\\]\%(\\\\\)*'.quote_char.'$'
  while !empty(a:aList) && res !~ end_string 
    let res .= ' ' . a:aList[0]
    call remove(a:aList, 0)
  endwhile
  return res
endfunction

"------------------------------------------------------------------------
" ## Experimental Functions {{{1

" Internal functions        {{{2
" Function: s:SaveData({Data})                             {{{3
" @param Data Command definition
" Saves {Data} as s:Data{s:data_id++}. The definition will be used by
" automatically generated commands.
" @return s:data_id
let s:data_id = 0
function! s:SaveData(Data)
  if has_key(a:Data, "command_id")
    " Avoid data duplication
    return a:Data.command_id
  else
    let s:Data{s:data_id} = a:Data
    let id = s:data_id
    let s:data_id += 1
    let a:Data.command_id = id
    return id
  endif
endfunction

" BTWComplete(ArgLead, CmdLine, CursorPos):      Auto-complete {{{3
function! lh#command#complete(ArgLead, CmdLine, CursorPos)
  let tmp = substitute(a:CmdLine, '\s*\S*', 'Z', 'g')
  let pos = strlen(tmp)
  if 0
    call confirm( "AL = ". a:ArgLead."\nCL = ". a:CmdLine."\nCP = ".a:CursorPos
	  \ . "\ntmp = ".tmp."\npos = ".pos
	  \, '&Ok', 1)
  endif

  if     2 == pos
    " First argument: a command
    return s:commands
  elseif 3 == pos
    " Second argument: first arg of the command
    if     -1 != match(a:CmdLine, '^BTW\s\+echo')
      return s:functions . "\n" . s:variables
    elseif -1 != match(a:CmdLine, '^BTW\s\+\%(help\|?\)')
    elseif -1 != match(a:CmdLine, '^BTW\s\+\%(set\|add\)\%(local\)\=')
      " Adds a filter
      " let files =         globpath(&rtp, 'compiler/BT-*')
      " let files = files . globpath(&rtp, 'compiler/BT_*')
      " let files = files . globpath(&rtp, 'compiler/BT/*')
      let files = s:FindFilter('*')
      let files = substitute(files,
	    \ '\(^\|\n\).\{-}compiler[\\/]BTW[-_\\/]\(.\{-}\)\.vim\>\ze\%(\n\|$\)',
	    \ '\1\2', 'g')
      return files
    elseif -1 != match(a:CmdLine, '^BTW\s\+remove\%(local\)\=')
      " Removes a filter
      return substitute(s:FiltersList(), ',', '\n', 'g')
    endif
  endif
  " finally: unknown
  echoerr 'BTW: unespected parameter ``'. a:ArgLead ."''"
  return ''
endfunction

function! s:BTW(command, ...)
  " todo: check a:0 > 1
  if     'set'      == a:command | let g:BTW_build_tool = a:1
    if exists('b:BTW_build_tool')
      let b:BTW_build_tool = a:1
    endif
  elseif 'setlocal'     == a:command | let b:BTW_build_tool = a:1
  elseif 'add'          == a:command | call s:AddFilter('g', a:1)
  elseif 'addlocal'     == a:command | call s:AddFilter('b', a:1)
    " if exists('b:BTW_filters_list') " ?????
    " call s:AddFilter('b', a:1)
    " endif
  elseif 'remove'       == a:command | call s:RemoveFilter('g', a:1)
  elseif 'removelocal'  == a:command | call s:RemoveFilter('b', a:1)
  elseif 'rebuild'      == a:command " wait for s:ReconstructToolsChain()
  elseif 'echo'         == a:command | exe "echo s:".a:1
    " echo s:{a:f1} ## don't support «echo s:f('foo')»
  elseif 'reloadPlugin' == a:command
    let g:force_reload_BuildToolsWrapper = 1
    let g:BTW_BTW_in_use = 1
    exe 'so '.s:sfile
    unlet g:force_reload_BuildToolsWrapper
    unlet g:BTW_BTW_in_use
    return
  elseif a:command =~ '\%(help\|?\)'
    call s:Usage()
    return
  endif
  call s:ReconstructToolsChain()
endfunction

" ##############################################################
" Public functions          {{{2

function! s:FindSubcommand(definition, subcommand)
  for arg in a:definition.arguments
    if arg.name == a:subcommand
      return arg
    endif
  endfor
  throw "NF"
endfunction

function! s:execute_function(definition, params)
    if len(a:params) < 1
      throw "(lh#command) Not enough arguments"
    endif
  let l:Fn = a:definition.action
  echo "calling ".string(l:Fn)
  echo "with ".string(a:params)
  " call remove(a:params, 0)
  call l:Fn(a:params)
endfunction

function! s:execute_sub_commands(definition, params)
  try
    if len(a:params) < 1
      throw "(lh#command) Not enough arguments"
    endif
    let subcommand = s:FindSubcommand(a:definition, a:params[0])
    call remove(a:params, 0)
    call s:int_execute(subcommand, a:params)
  catch /NF.*/
    throw "(lh#command) Unexpected subcommand `".a:params[0]."'."
  endtry
endfunction

function! s:int_execute(definition, params)
  echo "params=".string(a:params)
  call s:execute_{a:definition.arg_type}(a:definition, a:params)
endfunction

function! s:execute(definition, ...)
  try
    let params = copy(a:000)
    call s:int_execute(a:definition, params)
  catch /(lh#command).*/
    echoerr v:exception . " in `".a:definition.name.' '.join(a:000, ' ')."'"
  endtry
endfunction

function! lh#command#new(definition)
  let cmd_name = a:definition.name
  " Save the definition as an internal script variable
  let id = s:SaveData(a:definition)
  exe "command! -nargs=* ".cmd_name." :call s:execute(s:Data".id.", <f-args>)"
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/common.vim	[[[1
93
"=============================================================================
" $Id: common.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		autoload/lh/common.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	07th Oct 2006
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $ (08th Feb 2008)
"------------------------------------------------------------------------
" Description:	
" 	Some common functions for:
" 	- displaying error messages
" 	- checking dependencies
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	
" 	v2.1.1
" 		- New function: lh#common#echomsg_multilines()
" 		- lh#common#warning_msg() supports multilines messages
"
" 	v2.0.0:
" 		- Code moved from other plugins
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" Functions {{{1

" Function: lh#common#echomsg_multilines {{{2
function! lh#common#echomsg_multilines(text)
  let lines = split(a:text, "[\n\r]")
  for line in lines
    echomsg line
  endfor
endfunction
function! lh#common#echomsgMultilines(text)
  return lh#common#echomsg_multilines(a:text)
endfunction

" Function: lh#common#error_msg {{{2
function! lh#common#error_msg(text)
  if has('gui_running')
    call confirm(a:text, '&Ok', '1', 'Error')
  else
    " echohl ErrorMsg
    echoerr a:text
    " echohl None
  endif
endfunction 
function! lh#common#ErrorMsg(text)
  return lh#common#error_msg(a:text)
endfunction

" Function: lh#common#warning_msg {{{2
function! lh#common#warning_msg(text)
  echohl WarningMsg
  " echomsg a:text
  call lh#common#echomsg_multilines(a:text)
  echohl None
endfunction 
function! lh#common#WarningMsg(text)
  return lh#common#warning_msg(a:text)
endfunction

" Dependencies {{{2
function! lh#common#check_deps(Symbol, File, path, plugin) " {{{3
  if !exists(a:Symbol)
    exe "runtime ".a:path.a:File
    if !exists(a:Symbol)
      call lh#common#error_msg( a:plugin.': Requires <'.a:File.'>')
      return 0
    endif
  endif
  return 1
endfunction

function! lh#common#CheckDeps(Symbol, File, path, plugin) " {{{3
  echomsg "lh#common#CheckDeps() is deprecated, use lh#common#check_deps() instead."
  return lh#common#check_deps(a:Symbol, a:File, a:path, a:plugin)
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/encoding.vim	[[[1
74
"=============================================================================
" $Id: encoding.vim 405 2011-06-24 09:14:09Z luc.hermitte $
" File:		autoload/lh/encoding.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.2
" Created:	21st Feb 2008
" Last Update:	$Date: 2011-06-24 11:14:09 +0200 (ven., 24 juin 2011) $
"------------------------------------------------------------------------
" Description:	
" 	Defines functions that help managing various encodings
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	
" 	v2.2.2:
" 	(*) new mb_strings functions: strlen, strpart, at
" 	v2.0.7:
" 	(*) lh#encoding#Iconv() copied from map-tools
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" Exported functions {{{2
" Function: lh#encoding#iconv(expr, from, to)  " {{{3
" Unlike |iconv()|, this wrapper returns {expr} when we know no convertion can
" be acheived.
function! lh#encoding#iconv(expr, from, to)
  " call Dfunc("s:ICONV(".a:expr.','.a:from.','.a:to.')')
  if has('multi_byte') && 
	\ ( has('iconv') || has('iconv/dyn') ||
	\ ((a:from=~'latin1\|utf-8') && (a:to=~'latin1\|utf-8')))
    " call confirm('encoding: '.&enc."\nto:".a:to, "&Ok", 1)
    " call Dret("s:ICONV convert=".iconv(a:expr, a:from, a:to))
    return iconv(a:expr,a:from,a:to)
  else
    " Cannot convert
    " call Dret("s:ICONV  no convert=".a:expr)
    return a:expr
  endif
endfunction


" Function: lh#encoding#at(mb_string, i) " {{{3
" @return i-th character in a mb_string
" @parem mb_string multi-bytes string
" @param i 0-indexed position
function! lh#encoding#at(mb_string, i)
  return matchstr(a:mb_string, '.', 0, a:i+1)
endfunction

" Function: lh#encoding#strpart(mb_string, pos, length) " {{{3
" @return {length} extracted characters from {position} in multi-bytes string.
" @parem mb_string multi-bytes string
" @param p 0-indexed position
" @param l length of the string to extract
function! lh#encoding#strpart(mb_string, p, l)
  return matchstr(a:mb_string, '.\{'.a:l.'}', 0, a:p+1)
endfunction

" Function: lh#encoding#strlen(mb_string) " {{{3
" @return the length of the multi-bytes string.
function! lh#encoding#strlen(mb_string)
  return strlen(substitute(a:mb_string, '.', 'a', 'g'))
endfunction
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/env.vim	[[[1
75
"=============================================================================
" $Id: env.vim 244 2010-09-19 22:38:24Z luc.hermitte $
" File:         autoload/lh/env.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.1
" Created:      19th Jul 2010
" Last Update:  $Date: 2010-09-20 00:38:24 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:
"       Functions related to environment (variables)
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
" History:      
" 	v2.2.1 First Version
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 221
function! lh#env#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#env#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#env#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
function! lh#env#expand_all(string)
  let res = ''
  let tail = a:string
  while !empty(tail)
    let [ all, head, var, tail; dummy ] = matchlist(tail, '\(.\{-}\)\%(${\(.\{-}\)}\)\=\(.*\)')
    if empty(var)
      let res .= tail
      break
    else
      let res .= head
      let val = eval('$'.var)
      let res .= val
    endif
  endwhile
  return res
endfunction
"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/event.vim	[[[1
68
"=============================================================================
" $Id: event.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		autoload/lh/event.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	15th Feb 2008
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	
" 	Function to help manage vim |autocommand-events|
" 
"------------------------------------------------------------------------
" Installation:
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:
" 	v2.0.6:
" 		Creation
" TODO:		
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#event#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#event#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Event Registration {{{2
function! s:RegisteredOnce(cmd, group)
  " We can't delete the current augroup autocommand => increment a counter
  if !exists('s:'.a:group) || s:{a:group} == 0 
    let s:{a:group} = 1
    exe a:cmd
  endif
endfunction

function! lh#event#register_for_one_execution_at(event, cmd, group)
  let group = a:group.'_once'
  let s:{group} = 0
  exe 'augroup '.group
  au!
  exe 'au '.a:event.' '.expand('%:p').' call s:RegisteredOnce('.string(a:cmd).','.string(group).')'
  augroup END
endfunction
function! lh#event#RegisterForOneExecutionAt(event, cmd, group)
  return lh#event#register_for_one_execution_at(a:event, a:cmd, a:group)
endfunction
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/float.vim	[[[1
117
"=============================================================================
" $Id: float.vim 258 2010-12-01 00:06:52Z luc.hermitte $
" File:         autoload/lh/float.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.2
" Created:      16th Nov 2010
" Last Update:  $Date: 2010-12-01 01:06:52 +0100 (mer., 01 dÃ©c. 2010) $
"------------------------------------------------------------------------
" Description:
"       Defines functions related to |expr-float| numbers
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
" History:     
"       v2.0.0: first version
" TODO:
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 222
function! lh#float#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#float#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#float#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # lh#float#min(list) {{{2
function! lh#float#min(list)
  let am = lh#float#arg_min(a:list)
  return a:list[am]
endfunction

function! lh#float#arg_min(list)
  if empty(a:list) | return -1 | endif
  let m = type(a:list[0]) == type(0.0) ? a:list[0] : str2float(a:list[0])
  let p = 0
  let i = 1
  while i != len(a:list)
    let e = a:list[i]
    if type(e) != type(0.0) |
      let v = str2float(e)
    else
      let v = e
    endif
    if v < m
      let m = v
      let p = i
    endif
    let i += 1
  endwhile
  return p
endfunction


" # lh#float#max(list) {{{2
function! lh#float#max(list)
  let am = lh#float#arg_max(a:list)
  return a:list[am]
endfunction

function! lh#float#arg_max(list)
  if empty(a:list) | return -1 | endif
  let m = type(a:list[0]) == type(0.0) ? a:list[0] : str2float(a:list[0])
  let p = 0
  let i = 1
  while i != len(a:list)
    let e = a:list[i]
    if type(e) != type(0.0) |
      let v = str2float(e)
    else
      let v = e
    endif
    if v > m
      let m = v
      let p = i
    endif
    let i += 1
  endwhile
  return p
endfunction



"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/graph/tsort.vim	[[[1
177
"=============================================================================
" $Id: tsort.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		autoload/lh/tsort.vim                        {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	21st Apr 2008
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	Library functions for Topological Sort
" 
"------------------------------------------------------------------------
" 	Drop the file into {rtp}/autoload/lh/graph
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
" ## Debug {{{1
function! lh#graph#tsort#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#graph#tsort#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
"## Helper functions                         {{{1
"# s:Successors_fully_defined(node)          {{{2
function! s:Successors_fully_defined(node) dict
  if has_key(self.table, a:node)
    return self.table[a:node]
  else
    return []
  endif
endfunction

"# s:Successors_lazy(node)                   {{{2
function! s:Successors_lazy(node) dict
  if !has_key(self.table, a:node)
    let nodes = self.fetch(a:node)
    let self.table[a:node] = nodes
    " if len(nodes) > 0
      " let self.nb += 1
    " endif
    return nodes
  else
    return self.table[a:node]
  endif
endfunction

"# s:PrepareDAG(dag)                         {{{2
function! s:PrepareDAG(dag)
  if type(a:dag) == type(function('has_key'))
    let dag = { 
	  \ 'successors': function('s:Successors_lazy'),
	  \ 'fetch'     : a:dag,
	  \ 'table' 	: {}
	  \}
  else
    let dag = { 
	  \ 'successors': function('s:Successors_fully_defined'),
	  \ 'table' 	: deepcopy(a:dag)
	  \}
  endif
  return dag
endfunction

"## Depth-first search (recursive)           {{{1
" Do not detect cyclic graphs

"# lh#graph#tsort#depth(dag, start_nodes)    {{{2
function! lh#graph#tsort#depth(dag, start_nodes)
  let dag = s:PrepareDAG(a:dag)
  let results = []
  let visited_nodes = { 'Visited':function('s:Visited')}
  call s:RecursiveDTSort(dag, a:start_nodes, results, visited_nodes)
  call reverse(results)
  return results
endfunction

"# The real, recursive, T-Sort               {{{2
"see boost.graph for a non recursive implementation
function! s:RecursiveDTSort(dag, start_nodes, results, visited_nodes)
  for node in a:start_nodes
    let visited = a:visited_nodes.Visited(node)
    if     visited == 1 | continue " done
    elseif visited == 2 | throw "Tsort: cyclic graph detected: ".node
    endif
    let a:visited_nodes[node] = 2 " visiting
    let succs = a:dag.successors(node)
    try
      call s:RecursiveDTSort(a:dag, succs, a:results, a:visited_nodes)
    catch /Tsort:/
      throw v:exception.'>'.node
    endtry
    let a:visited_nodes[node] = 1 " visited
    call add(a:results, node)
  endfor
endfunction

function! s:Visited(node) dict 
  return has_key(self, a:node) ? self[a:node] : 0
endfunction

"## Breadth-first search (non recursive)     {{{1
"# lh#graph#tsort#breadth(dag, start_nodes)  {{{2
" warning: This implementation does not work with lazy dag, but only with fully
" defined ones
function! lh#graph#tsort#breadth(dag, start_nodes)
  let result = []
  let dag = s:PrepareDAG(a:dag)
  let queue = deepcopy(a:start_nodes)

  while len(queue) > 0
    let node = remove(queue, 0)
    " echomsg "result <- ".node
    call add(result, node)
    let successors = dag.successors(node)
    while len(successors) > 0
      let m = s:RemoveEdgeFrom(dag, node)
      " echomsg "graph loose ".node."->".m
      if !s:HasIncomingEgde(dag, m)
	" echomsg "queue <- ".m
        call add(queue, m)
      endif
    endwhile
  endwhile
  if !s:Empty(dag)
    throw "Tsort: cyclic graph detected: "
  endif
  return result
endfunction

function! s:HasIncomingEgde(dag, node)
  for node in keys(a:dag.table)
    if type(a:dag.table[node]) != type([])
      continue
    endif
    if index(a:dag.table[node], a:node) != -1
      return 1
    endif
  endfor
  return 0
endfunction
function! s:RemoveEdgeFrom(dag, node)
  let successors = a:dag.successors(a:node)
  if len(successors) > 0
    let successor = remove(successors, 0)
    if len(successors) == 0
      " echomsg "finished with ->".a:node
      call remove(a:dag.table, a:node)
    endif
    return successor
  endif
  throw "No more edges from ".a:node
endfunction
function! s:Empty(dag)
  " echomsg "len="len(a:dag.table)
  return len(a:dag.table) == 0
endfunction
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker
autoload/lh/icomplete.vim	[[[1
92
"=============================================================================
" $Id$
" File:         autoload/lh/icomplete.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.4
" Created:      03rd Jan 2011
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Helpers functions to build |ins-completion-menu|
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
" History:
" 	v2.2.4: first version
" TODO:
" 	- We are not able to detect the end of the completion mode. As a
" 	consequence we can't prevent c/for<space> to trigger an abbreviation
" 	instead of the right template file.
" 	In an ideal world, there would exist an event post |complete()|
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 224
function! lh#icomplete#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#icomplete#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#icomplete#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#icomplete#run(startcol, matches, Hook) {{{2
function! lh#icomplete#run(startcol, matches, Hook)
  call lh#icomplete#_register_hook(a:Hook)
  call complete(a:startcol, a:matches)
  return ''
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" Function: lh#icomplete#_clear_key_bindings() {{{2
function! lh#icomplete#_clear_key_bindings()
  iunmap <cr>
  iunmap <c-y>
  iunmap <esc>
  " iunmap <space>
  " iunmap <tab>
endfunction

" Function: lh#icomplete#_register_hook(Hook) {{{2
function! lh#icomplete#_register_hook(Hook)
  exe 'inoremap <silent> <cr> <cr><c-\><c-n>:call' .a:Hook . '()<cr>'
  exe 'inoremap <silent> <c-y> <c-y><c-\><c-n>:call' .a:Hook . '()<cr>'
  " <c-o><Nop> doesn't work as expected... 
  " To stay in INSERT-mode:
  " inoremap <silent> <esc> <c-e><c-o>:<cr>
  " To return into NORMAL-mode:
  inoremap <silent> <esc> <c-e><esc>

  call lh#event#register_for_one_execution_at('InsertLeave',
	\ ':call lh#icomplete#_clear_key_bindings()', 'CompleteGroup')
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/list.vim	[[[1
372
"=============================================================================
" $Id: list.vim 405 2011-06-24 09:14:09Z luc.hermitte $
" File:         autoload/lh/list.vim                                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.2
" Created:      17th Apr 2007
" Last Update:  $Date: 2011-06-24 11:14:09 +0200 (ven., 24 juin 2011) $ (17th Apr 2007)
"------------------------------------------------------------------------
" Description:  
"       Defines functions related to |Lists|
" 
"------------------------------------------------------------------------
" Installation: 
"       Drop it into {rtp}/autoload/lh/
"       Vim 7+ required.
" History:      
"       v2.2.2:
"       (*) new functions: lh#list#remove(), lh#list#matches(),
"           lh#list#not_found().
"       v2.2.1:
"       (*) use :unlet in :for loop to support heterogeneous lists
"       (*) binary search algorithms (upper_bound, lower_bound, equal_range)
"       v2.2.0:
"       (*) new functions: lh#list#accumulate, lh#list#transform,
"           lh#list#transform_if, lh#list#find_if, lh#list#copy_if,
"           lh#list#subset, lh#list#intersect
"       (*) the functions are compatible with lh#function functors
"       v2.1.1: 
"       (*) unique_sort
"       v2.0.7:
"       (*) Bug fix: lh#list#Match()
"       v2.0.6:
"       (*) lh#list#Find_if() supports search predicate, and start index
"       (*) lh#list#Match() supports start index
"       v2.0.0:
" TODO:         «missing features»
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#list#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#list#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Public {{{2
" Function: lh#list#Transform(input, output, action) {{{3
" deprecated version
function! lh#list#Transform(input, output, action)
  let new = map(copy(a:input), a:action)
  let res = extend(a:output,new)
  return res

  for element in a:input
    let action = substitute(a:action, 'v:val','element', 'g')
    let res = eval(action)
    call add(a:output, res)
    unlet element " for heterogeneous lists
  endfor
  return a:output
endfunction

function! lh#list#transform(input, output, action)
  for element in a:input
    let res = lh#function#execute(a:action, element)
    call add(a:output, res)
    unlet element " for heterogeneous lists
  endfor
  return a:output
endfunction

function! lh#list#transform_if(input, output, action, predicate)
  for element in a:input
    if lh#function#execute(a:predicate, element)
      let res = lh#function#execute(a:action, element)
      call add(a:output, res)
    endif
    unlet element " for heterogeneous lists
  endfor
  return a:output
endfunction

function! lh#list#copy_if(input, output, predicate)
  for element in a:input
    if lh#function#execute(a:predicate, element)
      call add(a:output, element)
    endif
    unlet element " for heterogeneous lists
  endfor
  return a:output
endfunction

function! lh#list#accumulate(input, transformation, accumulator)
  let transformed = lh#list#transform(a:input, [], a:transformation)
  let res = lh#function#execute(a:accumulator, transformed)
  return res
endfunction

" Function: lh#list#match(list, to_be_matched [, idx]) {{{3
function! lh#list#match(list, to_be_matched, ...)
  let idx = (a:0>0) ? a:1 : 0
  while idx < len(a:list)
    if match(a:list[idx], a:to_be_matched) != -1
      return idx
    endif
    let idx += 1
  endwhile
  return -1
endfunction
function! lh#list#Match(list, to_be_matched, ...)
  let idx = (a:0>0) ? a:1 : 0
  return lh#list#match(a:list, a:to_be_matched, idx)
endfunction

" Function: lh#list#matches(list, to_be_matched [,idx]) {{{3
" Return the list of indices that match {to_be_matched}
function! lh#list#matches(list, to_be_matched, ...)
  let res = []
  let idx = (a:0>0) ? a:1 : 0
  while idx < len(a:list)
    if match(a:list[idx], a:to_be_matched) != -1
      let res += [idx]
    endif
    let idx += 1
  endwhile
  return res
endfunction

" Function: lh#list#Find_if(list, predicate [, predicate-arguments] [, start-pos]) {{{3
function! lh#list#Find_if(list, predicate, ...)
  " Parameters
  let idx = 0
  let args = []
  if a:0 == 2
    let idx = a:2
    let args = a:1
  elseif a:0 == 1
    if type(a:1) == type([])
      let args = a:1
    elseif type(a:1) == type(42)
      let idx = a:1
    else
      throw "lh#list#Find_if: unexpected argument type"
    endif
  elseif a:0 != 0
      throw "lh#list#Find_if: unexpected number of arguments: lh#list#Find_if(list, predicate [, predicate-arguments] [, start-pos])"
  endif

  " The search loop
  while idx != len(a:list)
    let predicate = substitute(a:predicate, 'v:val', 'a:list['.idx.']', 'g')
    let predicate = substitute(predicate, 'v:\(\d\+\)_', 'args[\1-1]', 'g')
    let res = eval(predicate)
    " echomsg string(predicate) . " --> " . res
    if res | return idx | endif
    let idx += 1
  endwhile
  return -1
endfunction

" Function: lh#list#find_if(list, predicate [, predicate-arguments] [, start-pos]) {{{3
function! lh#list#find_if(list, predicate, ...)
  " Parameters
  let idx = 0
  let args = []
  if a:0 == 1
    let idx = a:1
  elseif a:0 != 0
      throw "lh#list#find_if: unexpected number of arguments: lh#list#find_if(list, predicate [, start-pos])"
  endif

  " The search loop
  while idx != len(a:list)
    " let predicate = substitute(a:predicate, 'v:val', 'a:list['.idx.']', 'g')
    let res = lh#function#execute(a:predicate, a:list[idx])
    if res | return idx | endif
    let idx += 1
  endwhile
  return -1
endfunction

" Function: lh#list#lower_bound(sorted_list, value  [, first[, last]]) {{{3
function! lh#list#lower_bound(list, val, ...)
  let first = 0
  let last = len(a:list)
  if a:0 >= 1     | let first = a:1
  elseif a:0 >= 2 | let last = a:2
  elseif a:0 > 2
      throw "lh#list#lower_bound: unexpected number of arguments: lh#list#lower_bound(sorted_list, value  [, first[, last]])"
  endif

  let len = last - first

  while len > 0
    let half = len / 2
    let middle = first + half
    if a:list[middle] < a:val
      let first = middle + 1
      let len -= half + 1
    else
      let len = half
    endif
  endwhile
  return first
endfunction

" Function: lh#list#upper_bound(sorted_list, value  [, first[, last]]) {{{3
function! lh#list#upper_bound(list, val, ...)
  let first = 0
  let last = len(a:list)
  if a:0 >= 1     | let first = a:1
  elseif a:0 >= 2 | let last = a:2
  elseif a:0 > 2
      throw "lh#list#upper_bound: unexpected number of arguments: lh#list#upper_bound(sorted_list, value  [, first[, last]])"
  endif

  let len = last - first

  while len > 0
    let half = len / 2
    let middle = first + half
    if a:val < a:list[middle]
      let len = half
    else
      let first = middle + 1
      let len -= half + 1
    endif
  endwhile
  return first
endfunction

" Function: lh#list#equal_range(sorted_list, value  [, first[, last]]) {{{3
" @return [f, l], where
"   f : First position where {value} could be inserted
"   l : Last position where {value} could be inserted
function! lh#list#equal_range(list, val, ...)
  let first = 0
  let last = len(a:list)

  " Parameters
  if a:0 >= 1     | let first = a:1
  elseif a:0 >= 2 | let last  = a:2
  elseif a:0 > 2
      throw "lh#list#equal_range: unexpected number of arguments: lh#list#equal_range(sorted_list, value  [, first[, last]])"
  endif

  " The search loop ( == STLPort's equal_range)

  let len = last - first
  while len > 0
    let half = len / 2
    let middle = first + half
    if a:list[middle] < a:val
      let first = middle + 1
      let len -= half + 1
    elseif a:val < a:list[middle]
      let len = half
    else
      let left = lh#list#lower_bound(a:list, a:val, first, middle)
      let right = lh#list#upper_bound(a:list, a:val, middle+1, first+len)
      return [left, right]
    endif

    " let predicate = substitute(a:predicate, 'v:val', 'a:list['.idx.']', 'g')
    " let res = lh#function#execute(a:predicate, a:list[idx])
  endwhile
  return [first, first]
endfunction

" Function: lh#list#not_found(range) {{{3
" @return the range returned from equal_range is empty (i.e. element not fount)
function! lh#list#not_found(range)
  return a:range[0] == a:range[1]
endfunction

" Function: lh#list#unique_sort(list [, func]) {{{3
" See also http://vim.wikia.com/wiki/Unique_sorting
"
" Works like sort(), optionally taking in a comparator (just like the
" original), except that duplicate entries will be removed.
" todo: support another argument that act as an equality predicate
function! lh#list#unique_sort(list, ...)
  let dictionary = {}
  for i in a:list
    let dictionary[string(i)] = i
  endfor
  let result = []
  " echo join(values(dictionary),"\n")
  if ( exists( 'a:1' ) )
    let result = sort( values( dictionary ), a:1 )
  else
    let result = sort( values( dictionary ) )
  endif
  return result
endfunction

function! lh#list#unique_sort2(list, ...)
  let list = copy(a:list)
  if ( exists( 'a:1' ) )
    call sort(list, a:1 )
  else
    call sort(list)
  endif
  if len(list) <= 1 | return list | endif
  let result = [ list[0] ]
  let last = list[0]
  let i = 1
  while i < len(list)
    if last != list[i]
      let last = list[i]
      call add(result, last)
    endif
    let i += 1
  endwhile
  return result
endfunction

" Function: lh#list#subset(list, indices) {{{3
function! lh#list#subset(list, indices)
  let result=[]
  for e in a:indices
    call add(result, a:list[e])
  endfor
  return result
endfunction

" Function: lh#list#remove(list, indices) {{{3
function! lh#list#remove(list, indices)
  " assert(is_sorted(indices))
  let idx = reverse(copy(a:indices))
  for i in idx
    call remove(a:list, i)
  endfor
  return a:list
endfunction

" Function: lh#list#intersect(list1, list2) {{{3
function! lh#list#intersect(list1, list2)
  let result = copy(a:list1)
  call filter(result, 'index(a:list2, v:val) >= 0')
  return result

  for e in a:list1
    if index(a:list2, e) > 0
      call result(result, e)
    endif
  endfor
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/menu.vim	[[[1
456
"=============================================================================
" $Id: menu.vim 311 2010-12-10 00:07:10Z luc.hermitte $
" File:		autoload/lh/menu.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.3
" Created:	13th Oct 2006
" Last Update:	$Date: 2010-12-10 01:07:10 +0100 (ven., 10 dÃ©c. 2010) $ (07th Dec 2010)
"------------------------------------------------------------------------
" Description:	
" 	Defines the global function lh#menu#def_menu
" 	Aimed at (ft)plugin writers.
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop this file into {rtp}/autoload/lh/
" 	Requires Vim 7+
" History:	
" 	v2.0.0:	Moving to vim7
" 	v2.0.1:	:Toggle echoes the new value
" 	v2.2.0: Support environment variables
" 	        Only one :Toggle command is defined.
" 	v2.2.3: :Toggle can directly set the final value
" 	       (prefer this way of proceeding to update the menu to the new
" 	       value)
" 	       :Toggle suports auto-completion on possible values
" TODO:		
" 	* Should the argument to :Toggle be simplified to use the variable name
" 	instead ? May be a banged :Toggle! could work on the real variable
" 	name, and on the real value.
" 	* show all possible values in a sub menu (on demand)
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Internal Variables {{{1
let s:k_Toggle_cmd = 'Toggle'
if !exists('s:toggle_commands')
  let s:toggle_commands = {}
endif

"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#menu#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#menu#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Common stuff       {{{2
" Function: lh#menu#text({text})                             {{{3
" @return a text to be used in menus where "\" and spaces have been escaped.
function! lh#menu#text(text)
  return escape(a:text, '\ ')
endfunction

" # Toggling menu item {{{2
" Function: s:Fetch({Data},{key})                          {{{3
" @param[in] Data Menu-item definition
" @param[in] key  Table table from which the result will be fetched
" @return the current value, or text, whose index is Data.idx_crt_value.
function! s:Fetch(Data, key)
  let len = len(a:Data[a:key])
  if a:Data.idx_crt_value >= len | let a:Data.idx_crt_value = 0 | endif
  let value = a:Data[a:key][a:Data.idx_crt_value]
  return value
endfunction

" Function: s:Search({Data},{value})                       {{{3
" Searches for the index of {value} in {Data.values} list. Return 0 if not
" found.
function! s:Search(Data, value)
  let idx = index(a:Data.values, a:value)
  " echo a:Data.variable . "[".idx."] == " . a:value
  return idx > 0 ? idx : 0 " default is first element
endfunction

" Function: s:SearchText({Data},{value})                   {{{3
" Searches for the index of {value} in {Data.values/text} list.
" Returns -1 if not found.
function! s:SearchText(Data, value)
  let labels_key = s:MenuKey(a:Data)
  let list = a:Data[labels_key]
  let idx = index(list, a:value)
  return idx
endfunction

" Function: s:Set({Data})                                  {{{3
" @param[in,out] Data Menu item definition
"
" Sets the global variable associated to the menu item according to the item's
" current value.
function! s:Set(Data)
  let value = a:Data.values[a:Data.idx_crt_value]
  let variable = a:Data.variable
  if variable[0] == '$' " environment variabmes
    exe "let ".variable." = ".string(value)
  else
    let g:{variable} = value
  endif
  if has_key(a:Data, "actions")
    let l:Action = a:Data.actions[a:Data.idx_crt_value]
    if type(l:Action) == type(function('tr'))
      call l:Action()
    else
      exe l:Action
    endif
  endif
  if has_key(a:Data, "hook")
    let l:Action = a:Data.hook
    if type(l:Action) == type(function('tr'))
      call a:Data.hook()
    else
      exe l:Action
    endif
  endif
  return value
endfunction

" Function: s:MenuKey({Data})                              {{{3
" @return the table name from which the current value name (to dsplay in the
" menu) must be fetched. 
" Priority is given to the optional "texts" table over the madatory "values" table.
function! s:MenuKey(Data)
  if has_key(a:Data, "texts")
    let menu_id = "texts"
  else
    let menu_id = "values"
  endif
  return menu_id
endfunction

" Function: s:SetTextValue({Data},{TextValue})             {{{3
" Force the value of the variable to the one associated to the {TextValue}
" The menu, and the variable are updated in consequence.
function! s:SetTextValue(Data, text)
  " Where the texts for values must be fetched
  let labels_key = s:MenuKey(a:Data)
  " Fetch the old current value 
  let old = s:Fetch(a:Data, labels_key)
  let new_idx = s:SearchText(a:Data, a:text)
  if -1 == new_idx
    throw "toggle-menu: unsupported value for {".(a:Data.variable)."}"
  endif
  if a:Data.idx_crt_value == new_idx
    " value unchanged => abort
    return 
  endif

  " Remove the entry from the menu
  call s:ClearMenu(a:Data.menu, old)

  " Cycle/increment the current value
  let a:Data.idx_crt_value = new_idx
  " Fetch it
  let new = s:Fetch(a:Data,labels_key)
  " Add the updated entry in the menu
  call s:UpdateMenu(a:Data.menu, new, a:Data.command)
  " Update the binded global variable
  let value = s:Set(a:Data)
  echo a:Data.variable.'='.value
endfunction

" Function: s:NextValue({Data})                            {{{3
" Change the value of the variable to the next in the list of value.
" The menu, and the variable are updated in consequence.
function! s:NextValue(Data)
  " Where the texts for values must be fetched
  let labels_key = s:MenuKey(a:Data)
  " Fetch the old current value 
  let old = s:Fetch(a:Data, labels_key)

  " Remove the entry from the menu
  call s:ClearMenu(a:Data.menu, old)

  " Cycle/increment the current value
  let a:Data.idx_crt_value += 1
  " Fetch it
  let new = s:Fetch(a:Data,labels_key)
  " Add the updated entry in the menu
  call s:UpdateMenu(a:Data.menu, new, a:Data.command)
  " Update the binded global variable
  let value = s:Set(a:Data)
  echo a:Data.variable.'='.value
endfunction

" Function: s:ClearMenu({Menu}, {text})                    {{{3
" Removes a menu item
"
" @param[in] Menu.priority Priority of the new menu-item
" @param[in] Menu.name     Name of the new menu-item
" @param[in] text          Text of the previous value of the variable binded
function! s:ClearMenu(Menu, text)
  if has('gui_running')
    let name = substitute(a:Menu.name, '&', '', 'g')
    let cmd = 'unmenu '.lh#menu#text(name.'<tab>('.a:text.')')
    silent! exe cmd
  endif
endfunction

" Function: s:UpdateMenu({Menu}, {text}, {command})        {{{3
" Adds a new menu item, with the text associated to the current value in
" braces.
"
" @param[in] Menu.priority Priority of the new menu-item
" @param[in] Menu.name     Name of the new menu-item
" @param[in] text          Text of the current value of the variable binded to
"                          the menu-item
" @param[in] command       Toggle command to execute when the menu-item is selected
function! s:UpdateMenu(Menu, text, command)
  if has('gui_running')
    let cmd = 'nnoremenu <silent> '.a:Menu.priority.' '.
	  \ lh#menu#text(a:Menu.name.'<tab>('.a:text.')').
	  \ ' :silent '.s:k_Toggle_cmd.' '.a:command."\<cr>"
    silent! exe cmd
  endif
endfunction

" Function: s:SaveData({Data})                             {{{3
" @param Data Menu-item definition
" Saves {Data} as s:Data{s:data_id++}. The definition will be used by
" automatically generated commands.
" @return s:data_id
let s:data_id = 0
function! s:SaveData(Data)
  let s:Data{s:data_id} = a:Data
  let id = s:data_id
  let s:data_id += 1
  return id
endfunction

" Function: lh#menu#def_toggle_item({Data})                  {{{3
" @param Data.idx_crt_value
" @param Data.definitions == [ {value:, menutext: } ]
" @param Data.menu        == { name:, position: }
"
" Sets a toggle-able menu-item defined by {Data}.
"
function! lh#menu#def_toggle_item(Data)
  " Save the menu data as an internal script variable
  let id = s:SaveData(a:Data)

  " If the index of the current value hasn't been set, fetch it from the
  " associated variable
  if !has_key(a:Data, "idx_crt_value")
    " Fetch the value of the associated variable
    let value = lh#option#get(a:Data.variable, 0, 'g')
    " echo a:Data.variable . " <- " . value
    " Update the index of the current value
    let a:Data.idx_crt_value  = s:Search(a:Data, value)
  endif

  " Name of the auto-matically generated toggle command
  let cmdName = substitute(a:Data.menu.name, '[^a-zA-Z_]', '', 'g')
  " Lazy definition of the command
  if 2 != exists(':'.s:k_Toggle_cmd) 
    exe 'command! -nargs=+ -complete=custom,lh#menu#_toggle_complete '
	  \ . s:k_Toggle_cmd . ' :call s:Toggle(<f-args>)'
  endif
  " silent exe 'command! -nargs=0 '.cmdName.' :call s:NextValue(s:Data'.id.')'
  let s:toggle_commands[cmdName] = eval('s:Data'.id)
  let a:Data["command"] = cmdName

  " Add the menu entry according to the current value
  call s:UpdateMenu(a:Data.menu, s:Fetch(a:Data, s:MenuKey(a:Data)), cmdName)
  " Update the associated global variable
  call s:Set(a:Data)
endfunction


"------------------------------------------------------------------------
function! s:Toggle(cmdName, ...)
  if !has_key(s:toggle_commands, a:cmdName)
    throw "toggle-menu: unknown toggable variable ".a:cmdName
  endif
  let data = s:toggle_commands[a:cmdName]
  if a:0 > 0
    call s:SetTextValue(data, a:1)
  else
    call s:NextValue(data)
  endif
endfunction

function! lh#menu#_toggle_complete(ArgLead, CmdLine, CursorPos)
  let cmdline = split(a:CmdLine)
  " echomsg "cmd line: " . string(cmdline)." # ". (a:CmdLine =~ ' $')
  let nb_args = len(cmdline)
  if (a:CmdLine !~ ' $')
    let nb_args -= 1
  endif
  " echomsg "nb args: ". nb_args
  if nb_args < 2 
    return join(keys(s:toggle_commands),"\n")
  elseif nb_args == 2
    let variable = cmdline[1]
    if !has_key(s:toggle_commands, variable)
      throw "toggle-menu: unknown toggable variable ".variable
    endif
    let data = s:toggle_commands[variable]
    let labels_key = s:MenuKey(data)
    " echomsg "keys: ".string(data[labels_key])
    return join(data[labels_key], "\n")
  else
    return ''
  endif
endfunction

"------------------------------------------------------------------------
" # IVN Menus          {{{2
" Function: s:CTRL_O({cmd})                                {{{3
" Build the command (sequence of ':ex commands') to be executed from
" INSERT-mode.
function! s:CTRL_O(cmd)
  return substitute(a:cmd, '\(^\|<CR>\):', '\1\<C-O>:', 'g')
endfunction

" Function: lh#menu#is_in_visual_mode()                    {{{3
function! lh#menu#is_in_visual_mode()
  return exists('s:is_in_visual_mode') && s:is_in_visual_mode
endfunction

" Function: lh#menu#_CMD_and_clear_v({cmd})                 {{{3
" Internal function that executes the command and then clears the @v buffer
" todo: save and restore @v, 
function! lh#menu#_CMD_and_clear_v(cmd)
  try 
    let s:is_in_visual_mode = 1
    exe a:cmd
  finally
    let @v=''
    silent! unlet s:is_in_visual_mode
  endtry
endfunction

" Function: s:Build_CMD({prefix},{cmd})                    {{{3
" build the exact command to execute regarding the mode it is dedicated
function! s:Build_CMD(prefix, cmd)
  if a:cmd[0] != ':' | return ' ' . a:cmd
  endif
  if     a:prefix[0] == "i"  | return ' ' . <SID>CTRL_O(a:cmd)
  elseif a:prefix[0] == "n"  | return ' ' . a:cmd
  elseif a:prefix[0] == "v" 
    if match(a:cmd, ":VCall") == 0
      return substitute(a:cmd, ':VCall', ' :call', ''). "\<cr>gV"
      " gV exit select-mode if we where in it!
    else
      return
	    \ " \"vy\<C-C>:call lh#menu#_CMD_and_clear_v('" . 
	    \ substitute(a:cmd, "<CR>$", '', '') ."')\<cr>"
    endif
  elseif a:prefix[0] == "c"  | return " \<C-C>" . a:cmd
  else                       | return ' ' . a:cmd
  endif
endfunction

" Function: lh#menu#map_all({map_type}, [{map args}...)   {{{3
" map the command to all the modes required
function! lh#menu#map_all(map_type,...)
  let nore   = (match(a:map_type, '[aincv]*noremap') != -1) ? "nore" : ""
  let prefix = matchstr(substitute(a:map_type, nore, '', ''), '[aincv]*')
  if a:1 == "<buffer>" | let i = 3 | let binding = a:1 . ' ' . a:2
  else                 | let i = 2 | let binding = a:1
  endif
  let binding = '<silent> ' . binding
  let cmd = a:{i}
  let i +=  1
  while i <= a:0
    let cmd .=  ' ' . a:{i}
    let i +=  1
  endwhile
  let build_cmd = nore . 'map ' . binding
  while strlen(prefix)
    if prefix[0] == "a" | let prefix = "incv"
    else
      execute prefix[0] . build_cmd . <SID>Build_CMD(prefix[0],cmd)
      let prefix = strpart(prefix, 1)
    endif
  endwhile
endfunction

" Function: lh#menu#make({prefix},{code},{text},{binding},...) {{{3
" Build the menu and map its associated binding to all the modes required
function! lh#menu#make(prefix, code, text, binding, ...)
  let nore   = (match(a:prefix, '[aincv]*nore') != -1) ? "nore" : ""
  let prefix = matchstr(substitute(a:prefix, nore, '', ''), '[aincv]*')
  let b = (a:1 == "<buffer>") ? 1 : 0
  let i = b + 1 
  let cmd = a:{i}
  let i += 1
  while i <= a:0
    let cmd .=  ' ' . a:{i}
    let i += 1
  endwhile
  let build_cmd = nore . "menu <silent> " . a:code . ' ' . lh#menu#text(a:text) 
  if strlen(a:binding) != 0
    let build_cmd .=  '<tab>' . 
	  \ substitute(lh#menu#text(a:binding), '&', '\0\0', 'g')
    if b != 0
      call lh#menu#map_all(prefix.nore."map", ' <buffer> '.a:binding, cmd)
    else
      call lh#menu#map_all(prefix.nore."map", a:binding, cmd)
    endif
  endif
  if has("gui_running")
    while strlen(prefix)
      execute <SID>BMenu(b).prefix[0].build_cmd.<SID>Build_CMD(prefix[0],cmd)
      let prefix = strpart(prefix, 1)
    endwhile
  endif
endfunction

" Function: s:BMenu({b})                                   {{{3
" If <buffermenu.vim> is installed and the menu should be local, then the
" apropriate string is returned.
function! s:BMenu(b)
  let res = (a:b && exists(':Bmenu') 
	\     && (1 == lh#option#get("want_buffermenu_or_global_disable", 1, "bg"))
	\) ? 'B' : ''
  " call confirm("BMenu(".a:b.")=".res, '&Ok', 1)
  return res
endfunction

" Function: lh#menu#IVN_make(...)                          {{{3
function! lh#menu#IVN_make(code, text, binding, i_cmd, v_cmd, n_cmd, ...)
  " nore options
  let nore_i = (a:0 > 0) ? ((a:1 != 0) ? 'nore' : '') : ''
  let nore_v = (a:0 > 1) ? ((a:2 != 0) ? 'nore' : '') : ''
  let nore_n = (a:0 > 2) ? ((a:3 != 0) ? 'nore' : '') : ''
  " 
  call lh#menu#make('i'.nore_i,a:code,a:text, a:binding, '<buffer>', a:i_cmd)
  call lh#menu#make('v'.nore_v,a:code,a:text, a:binding, '<buffer>', a:v_cmd)
  if strlen(a:n_cmd) != 0
    call lh#menu#make('n'.nore_n,a:code,a:text, a:binding, '<buffer>', a:n_cmd)
  endif
endfunction

"
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/option.vim	[[[1
107
"=============================================================================
" $Id: option.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		autoload/lh/option.vim                                    {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	24th Jul 2004
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $ (07th Oct 2006)
"------------------------------------------------------------------------
" Description:
" 	Defines the global function lh#option#get().
"       Aimed at (ft)plugin writers.
" 
"------------------------------------------------------------------------
" Installation:
" 	Drop this file into {rtp}/autoload/lh/
" 	Requires Vim 7+
" History:	
" 	v2.0.5
" 	(*) lh#option#get_non_empty() manages Lists and Dictionaries
" 	(*) lh#option#get() doesn't test emptyness anymore
" 	v2.0.0
" 		Code moved from {rtp}/macros/ 
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#option#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#option#debug(expr)
  return eval(a:expr)
endfunction

" # Public {{{2
" Function: lh#option#get(name, default [, scope])            {{{3
" @return b:{name} if it exists, or g:{name} if it exists, or {default}
" otherwise
" The order of the variables checked can be specified through the optional
" argument {scope}
function! lh#option#get(name,default,...)
  let scope = (a:0 == 1) ? a:1 : 'bg'
  let name = a:name
  let i = 0
  while i != strlen(scope)
    if exists(scope[i].':'.name)
      " \ && (0 != strlen({scope[i]}:{name}))
      return {scope[i]}:{name}
    endif
    let i += 1
  endwhile 
  return a:default
endfunction
function! lh#option#Get(name,default,...)
  let scope = (a:0 == 1) ? a:1 : 'bg'
  return lh#option#get(a:name, a:default, scope)
endfunction

function! s:IsEmpty(variable)
  if     type(a:variable) == type('string') | return 0 == strlen(a:variable)
  elseif type(a:variable) == type(42)       | return 0 == a:variable
  elseif type(a:variable) == type([])       | return 0 == len(a:variable)
  elseif type(a:variable) == type({})       | return 0 == len(a:variable)
  else                                      | return false
  endif
endfunction

" Function: lh#option#get_non_empty(name, default [, scope])            {{{3
" @return of b:{name}, g:{name}, or {default} the first which exists and is not empty 
" The order of the variables checked can be specified through the optional
" argument {scope}
function! lh#option#get_non_empty(name,default,...)
  let scope = (a:0 == 1) ? a:1 : 'bg'
  let name = a:name
  let i = 0
  while i != strlen(scope)
    if exists(scope[i].':'.name) && !s:IsEmpty({scope[i]}:{name})
      return {scope[i]}:{name}
    endif
    let i += 1
  endwhile 
  return a:default
endfunction
function! lh#option#GetNonEmpty(name,default,...)
  let scope = (a:0 == 1) ? a:1 : 'bg'
  return lh#option#get_non_empty(a:name, a:default, scope)
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/path.vim	[[[1
335
"=============================================================================
" $Id: path.vim 402 2011-06-24 09:11:36Z luc.hermitte $
" File:		autoload/lh/path.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.5
" Created:	23rd Jan 2007
" Last Update:	$Date
"------------------------------------------------------------------------
" Description:	
"       Functions related to the handling of pathnames
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop this file into {rtp}/autoload/lh
" 	Requires Vim7+
" History:	
"	v 1.0.0 First Version
" 	(*) Functions moved from searchInRuntimeTime  
" 	v 2.0.1
" 	(*) lh#path#Simplify() becomes like |simplify()| except for trailing
" 	v 2.0.2
" 	(*) lh#path#SelectOne() 
" 	(*) lh#path#ToRelative() 
" 	v 2.0.3
" 	(*) lh#path#GlobAsList() 
" 	v 2.0.4
" 	(*) lh#path#StripStart()
" 	v 2.0.5
" 	(*) lh#path#StripStart() interprets '.' as getcwd()
" 	v 2.2.0
" 	(*) new functions: lh#path#common(), lh#path#to_dirname(),
" 	    lh#path#depth(), lh#path#relative_to(), lh#path#to_regex(),
" 	    lh#path#find()
" 	(*) lh#path#simplify() fixed
" 	(*) lh#path#to_relative() use simplify()
" 	v 2.2.2
" 	(*) lh#path#strip_common() fixed
" 	(*) lh#path#simplify() new optional parameter: make_relative_to_pwd
" 	v 2.2.5
" 	(*) fix lh#path#to_dirname('') -> return ''
" TODO:
"       (*) Decide what #depth('../../bar') shall return
"       (*) Fix #simplify('../../bar')
" }}}1
"=============================================================================


"=============================================================================
" Avoid global reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim

"=============================================================================
" ## Functions {{{1
" # Version {{{2
let s:k_version = 222
function! lh#path#version()
  return s:k_version
endfunction

" # Debug {{{2
let s:verbose = 0
function! lh#path#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#path#debug(expr)
  return eval(a:expr)
endfunction

"=============================================================================
" # Public {{{2
" Function: lh#path#simplify({pathname}, [make_relative_to_pwd=true]) {{{3
" Like |simplify()|, but also strip the leading './'
" It seems unable to simplify '..\' when compiled without +shellslash
function! lh#path#simplify(pathname, ...)
  let make_relative_to_pwd = a:0 == 0 || a:1 == 1
  let pathname = simplify(a:pathname)
  let pathname = substitute(pathname, '^\%(\.[/\\]\)\+', '', '')
  let pathname = substitute(pathname, '\([/\\]\)\%(\.[/\\]\)\+', '\1', 'g')
  if make_relative_to_pwd
    let pwd = getcwd().'/'
    let pathname = substitute(pathname, '^'.lh#path#to_regex(pwd), '', 'g')
  endif
  return pathname
endfunction
function! lh#path#Simplify(pathname)
  return lh#path#simplify(a:pathname)
endfunction

" Function: lh#path#common({pathnames}) {{{3
" Find the common leading path between all pathnames
function! lh#path#common(pathnames)
  " assert(len(pathnames)) > 1
  let common = a:pathnames[0]
  let i = 1
  while i < len(a:pathnames)
    let fcrt = a:pathnames[i]
    " pathnames should not contain @
    " let common = matchstr(common.'@@'.fcrt, '^\zs\(.*[/\\]\)\ze.\{-}@@\1.*$')
    let common = matchstr(common.'@@'.fcrt, '^\zs\(.*\>\)\ze.\{-}@@\1\>.*$')
    if strlen(common) == 0
      " No need to further checks
      break
    endif
    let i += 1
  endwhile
  return common
endfunction

" Function: lh#path#strip_common({pathnames}) {{{3
" Find the common leading path between all pathnames, and strip it
function! lh#path#strip_common(pathnames)
  " assert(len(pathnames)) > 1
  let common = lh#path#common(a:pathnames)
  let common = lh#path#to_dirname(common)
  let l = strlen(common)
  if l == 0
    return a:pathnames
  else
  let pathnames = a:pathnames
  call map(pathnames, 'strpart(v:val, '.l.')' )
  return pathnames
  endif
endfunction
function! lh#path#StripCommon(pathnames)
  return lh#path#strip_common(a:pathnames)
endfunction

" Function: lh#path#is_absolute_path({path}) {{{3
function! lh#path#is_absolute_path(path)
  return a:path =~ '^/'
	\ . '\|^[a-zA-Z]:[/\\]'
	\ . '\|^[/\\]\{2}'
  "    Unix absolute path 
  " or Windows absolute path
  " or UNC path
endfunction
function! lh#path#IsAbsolutePath(path)
  return lh#path#is_absolute_path(a:path)
endfunction

" Function: lh#path#is_url({path}) {{{3
function! lh#path#is_url(path)
  " todo: support UNC paths and other urls
  return a:path =~ '^\%(https\=\|s\=ftp\|dav\|fetch\|file\|rcp\|rsynch\|scp\)://'
endfunction
function! lh#path#IsURL(path)
  return lh#path#is_url(a:path)
endfunction

" Function: lh#path#select_one({pathnames},{prompt}) {{{3
function! lh#path#select_one(pathnames, prompt)
  if len(a:pathnames) > 1
    let simpl_pathnames = deepcopy(a:pathnames) 
    let simpl_pathnames = lh#path#strip_common(simpl_pathnames)
    let simpl_pathnames = [ '&Cancel' ] + simpl_pathnames
    " Consider guioptions+=c is case of difficulties with the gui
    let selection = confirm(a:prompt, join(simpl_pathnames,"\n"), 1, 'Question')
    let file = (selection == 1) ? '' : a:pathnames[selection-2]
    return file
  elseif len(a:pathnames) == 0
    return ''
  else
    return a:pathnames[0]
  endif
endfunction
function! lh#path#SelectOne(pathnames, prompt)
  return lh#path#select_one(a:pathnames, a:prompt)
endfunction

" Function: lh#path#to_relative({pathname}) {{{3
function! lh#path#to_relative(pathname)
  let newpath = fnamemodify(a:pathname, ':p:.')
  let newpath = simplify(newpath)
  return newpath
endfunction
function! lh#path#ToRelative(pathname)
  return lh#path#to_relative(a:pathname)
endfunction

" Function: lh#path#to_dirname({dirname}) {{{3
" todo: use &shellslash
function! lh#path#to_dirname(dirname)
  let dirname = a:dirname . (empty(a:dirname) || a:dirname[-1:] =~ '[/\\]' ? '' : '/')
  return dirname
endfunction

" Function: lh#path#depth({dirname}) {{{3
" todo: make a choice about "negative" paths like "../../foo"
function! lh#path#depth(dirname)
  if empty(a:dirname) | return 0 | endif
  let dirname = lh#path#to_dirname(a:dirname)
  let dirname = lh#path#simplify(dirname)
  if lh#path#is_absolute_path(dirname)
    let dirname = matchstr(dirname, '.\{-}[/\\]\zs.*')
  endif
  let depth = len(substitute(dirname, '[^/\\]\+[/\\]', '#', 'g'))
  return depth
endfunction

" Function: lh#path#relative_to({from}, {to}) {{{3
" @param two directories
" @return a directories delta that ends with a '/' (may depends on
" &shellslash)
function! lh#path#relative_to(from, to)
  " let from = fnamemodify(a:from, ':p')
  " let to   = fnamemodify(a:to  , ':p')
  let from = lh#path#to_dirname(a:from)
  let to   = lh#path#to_dirname(a:to  )
  let [from, to] = lh#path#strip_common([from, to])
  let nb_up =  lh#path#depth(from)
  return repeat('../', nb_up).to

  " cannot rely on :cd (as it alters things, and doesn't work with
  " non-existant paths)
  let pwd = getcwd()
  exe 'cd '.a:to
  let res = lh#path#to_relative(a:from)
  exe 'cd '.pwd
  return res
endfunction

" Function: lh#path#glob_as_list({pathslist}, {expr}) {{{3
function! s:GlobAsList(pathslist, expr)
  let sResult = globpath(a:pathslist, a:expr)
  let lResult = split(sResult, '\n')
  " workaround a non feature of wildignore: it does not ignore directories
  for ignored_pattern in split(&wildignore,',')
    if stridx(ignored_pattern,'/') != -1
      call filter(lResult, 'v:val !~ '.string(ignored_pattern))
    endif
  endfor
  return lResult
endfunction

function! lh#path#glob_as_list(pathslist, expr)
  if type(a:expr) == type('string')
    return s:GlobAsList(a:pathslist, a:expr)
  elseif type(a:expr) == type([])
    let res = []
    for expr in a:expr
      call extend(res, s:GlobAsList(a:pathslist, expr))
    endfor
    return res
  else
    throw "Unexpected type for a:expression"
  endif
endfunction
function! lh#path#GlobAsList(pathslist, expr)
  return lh#path#glob_as_list(a:pathslist, a:expr)
endfunction

" Function: lh#path#strip_start({pathname}, {pathslist}) {{{3
" Strip occurrence of paths from {pathslist} in {pathname}
" @param[in] {pathname} name to simplify
" @param[in] {pathslist} list of pathname (can be a |string| of pathnames
" separated by ",", of a |List|).
function! lh#path#strip_start(pathname, pathslist)
  if type(a:pathslist) == type('string')
    " let strip_re = escape(a:pathslist, '\\.')
    " let strip_re = '^' . substitute(strip_re, ',', '\\|^', 'g')
    let pathslist = split(a:pathslist, ',')
  elseif type(a:pathslist) == type([])
    let pathslist = deepcopy(a:pathslist)
  else
    throw "Unexpected type for a:pathname"
  endif

  " apply a realpath like operation
  let nb_paths = len(pathslist) " set before the loop
  let i = 0
  while i != nb_paths
    if pathslist[i] =~ '^\.\%(/\|$\)'
      let path2 = getcwd().pathslist[i][1:]
      call add(pathslist, path2)
    endif
    let i += 1
  endwhile
  " replace path separators by a regex that can match them
  call map(pathslist, 'substitute(v:val, "[\\\\/]", "[\\\\/]", "g")')
  " echomsg string(pathslist)
  " escape .
  call map(pathslist, '"^".escape(v:val, ".")')
  " build the strip regex
  let strip_re = join(pathslist, '\|')
  " echomsg strip_re
  let res = substitute(a:pathname, '\%('.strip_re.'\)[/\\]\=', '', '')
  return res
endfunction
function! lh#path#StripStart(pathname, pathslist)
  return lh#path#strip_start(a:pathname, a:pathslist)
endfunction

" Function: lh#path#to_regex({pathname}) {{{3
function! lh#path#to_regex(path)
  let regex = substitute(a:path, '[/\\]', '[/\\\\]', 'g')
  return regex
endfunction

" Function: lh#path#find({pathname}, {regex}) {{{3
function! lh#path#find(paths, regex)
  let paths = (type(a:paths) == type([]))
	\ ? (a:paths) 
	\ : split(a:paths,',')
  for path in paths
    if match(path ,a:regex) != -1
      return path
    endif
  endfor
  return ''
endfunction

" Function: lh#path#vimfiles() {{{3
function! lh#path#vimfiles()
  let expected_win = $HOME . '/vimfiles'
  let expected_nix = $HOME . '/.vim'
  let what =  lh#path#to_regex($HOME.'/').'\(vimfiles\|.vim\)'
  " Comment what
  let z = lh#path#find(&rtp,what)
  return z
endfunction
" }}}1
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/position.vim	[[[1
93
"=============================================================================
" $Id: position.vim 321 2011-01-06 01:13:56Z luc.hermitte $
" File:		autoload/lh/position.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.4
" Created:	05th Sep 2007
" Last Update:	$Date: 2011-01-06 02:13:56 +0100 (jeu., 06 janv. 2011) $ (05th Sep 2007)
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	«history»
" 	v1.0.0:
" 		Creation
" TODO:		
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#position#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#position#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" # Public {{{2
" Function: lh#position#is_before {{{3
" @param[in] positions as those returned from |getpos()|
" @return whether lhs_pos is before rhs_pos
function! lh#position#is_before(lhs_pos, rhs_pos)
  if a:lhs_pos[0] != a:rhs_pos[0]
    throw "Positions from incompatible buffers can't be ordered"
  endif
  "1 test lines
  "2 test cols
  let before 
	\ = (a:lhs_pos[1] == a:rhs_pos[1])
	\ ? (a:lhs_pos[2] < a:rhs_pos[2])
	\ : (a:lhs_pos[1] < a:rhs_pos[1])
  return before
endfunction
function! lh#position#IsBefore(lhs_pos, rhs_pos)
  return lh#position#is_before(a:lhs_pos, a:rhs_pos)
endfunction


" Function: lh#position#char_at_mark {{{3
" @return the character at a given mark (|mark|)
function! lh#position#char_at_mark(mark)
  let c = getline(a:mark)[col(a:mark)-1]
  return c
endfunction
function! lh#position#CharAtMark(mark)
return lh#position#char_at_mark(a:mark)
endfunction

" Function: lh#position#char_at_pos {{{3
" @return the character at a given position (|getpos()|)
function! lh#position#char_at_pos(pos)
  let c = getline(a:pos[1])[(a:pos[2])-1]
  return c
endfunction
function! lh#position#CharAtPos(pos)
  return  lh#position#char_at_pos(a:pos)
endfunction



" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/syntax.vim	[[[1
139
"=============================================================================
" $Id: syntax.vim 310 2010-12-10 00:05:03Z luc.hermitte $
" File:		autoload/lh/syntax.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.3
" Created:	05th Sep 2007
" Last Update:	$Date: 2010-12-10 01:05:03 +0100 (ven., 10 dÃ©c. 2010) $ (05th Sep 2007)
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	«history»
" 	v1.0.0:
" 		Creation ;
" 		Functions moved from lhVimSpell
" TODO:
" 	function, to inject "contained", see lhVimSpell approach
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#syntax#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#syntax#debug(expr)
  return eval(a:expr)
endfunction

" # Public {{{2
" Functions: Show name of the syntax kind of a character {{{3
function! lh#syntax#name_at(l,c, ...)
  let what = a:0 > 0 ? a:1 : 0
  return synIDattr(synID(a:l, a:c, what),'name')
endfunction
function! lh#syntax#NameAt(l,c, ...)
  let what = a:0 > 0 ? a:1 : 0
  return lh#syntax#name_at(a:l, a:c, what)
endfunction

function! lh#syntax#name_at_mark(mark, ...)
  let what = a:0 > 0 ? a:1 : 0
  return lh#syntax#name_at(line(a:mark), col(a:mark), what)
endfunction
function! lh#syntax#NameAtMark(mark, ...)
  let what = a:0 > 0 ? a:1 : 0
  return lh#syntax#name_at_mark(a:mark, what)
endfunction

" Functions: skip string, comment, character, doxygen {{{3
func! lh#syntax#skip_at(l,c)
  return lh#syntax#name_at(a:l,a:c) =~? 'string\|comment\|character\|doxygen'
endfun
func! lh#syntax#SkipAt(l,c)
  return lh#syntax#skip_at(a:l,a:c)
endfun

func! lh#syntax#skip()
  return lh#syntax#skip_at(line('.'), col('.'))
endfun
func! lh#syntax#Skip()
  return lh#syntax#skip()
endfun

func! lh#syntax#skip_at_mark(mark)
  return lh#syntax#skip_at(line(a:mark), col(a:mark))
endfun
func! lh#syntax#SkipAtMark(mark)
  return lh#syntax#skip_at_mark(a:mark)
endfun

" Function: Show current syntax kind {{{3
command! SynShow echo 'hi<'.lh#syntax#name_at_mark('.',1).'> trans<'
      \ lh#syntax#name_at_mark('.',0).'> lo<'.
      \ synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name').'>   ## '
      \ lh#list#transform(synstack(line("."), col(".")), [], 'synIDattr(v:1_, "name")')


" Function: lh#syntax#list_raw(name) : string                     {{{3
function! lh#syntax#list_raw(name)
  let a_save = @a
  try
    redir @a
    exe 'silent! syn list '.a:name
    redir END
    let res = @a
  finally
    let @a = a_save
  endtry
  return res
endfunction

" Function: lh#syntax#list(name) : List                     {{{3
function! lh#syntax#list(name)
  let raw = lh#syntax#list_raw(a:name)
  let res = [] 
  let lines = split(raw, '\n')
  let started = 0
  for l in lines
    if started
      let li = (l =~ 'links to') ? '' : l
    elseif l =~ 'xxx'
      let li = matchstr(l, 'xxx\s*\zs.*')
      let started = 1
    else
      let li = ''
    endif
    if strlen(li) != 0
      let li = substitute(li, 'contained\S*\|transparent\|nextgroup\|skipwhite\|skipnl\|skipempty', '', 'g')
      let kinds = split(li, '\s\+')
      call extend(res, kinds)
    endif
  endfor
  return res
endfunction



" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
autoload/lh/visual.vim	[[[1
55
"=============================================================================
" $Id$
" File:		autoload/lh/visual.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.5
" Created:	08th Sep 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" 	Helpers functions releated to the visual mode
" 
"------------------------------------------------------------------------
" 	Drop it into {rtp}/autoload/lh/
" 	Vim 7+ required.
" History:	
" 	v2.2.5: lh#visual#cut()
" 	v2.0.6: First appearance
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" Functions {{{1

" Function: lh#visual#selection()                              {{{3
" @return the text currently selected
function! lh#visual#selection()
  try
    let a_save = @a
    normal! gv"ay
    return @a
  finally
    let @a = a_save
  endtry
endfunction

" Function: lh#visual#cut()                                    {{{3
" @return and delete the text currently selected
function! lh#visual#cut()
  try
    let a_save = @a
    normal! gv"ad
    return @a
  finally
    let @a = a_save
  endtry
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
doc/lh-vim-lib.txt	[[[1
1359
*lh-vim-lib.txt*        Vim common libraries (v2.2.5)
                        For Vim version 7+      Last change: $Date: 2011-06-24 11:12:43 +0200 (ven., 24 juin 2011) $

                        By Luc Hermitte
                        hermitte {at} free {dot} fr


==============================================================================
CONTENTS                                      *lhvl-contents*      {{{1
|lhvl-presentation|     Presentation
|lhvl-functions|        Functions
    
|add-local-help|        Instructions on installing this help file


------------------------------------------------------------------------------
PRESENTATION                                  *lhvl-presentation*  {{{1

|lh-vim-lib| is a library that defines some common VimL functions I use in my
various plugins and ftplugins.
This library has been conceived as a suite of |autoload| plugins, and a few
|macros| plugins. As such, it requires Vim 7+.


==============================================================================
FUNCTIONS                                     *lhvl-functions*     {{{1
{{{2Functions list~
Miscellanous functions:                                 |lhvl#misc|
- |lh#askvim#exe()|
- |lh#common#check_deps()|
- |lh#common#error_msg()|
- |lh#common#warning_msg()|
- |lh#common#echomsg_multilines()|
- |lh#encoding#iconv()|
- |lh#encoding#strlen()|
- |lh#encoding#strpart()|
- |lh#event#register_for_one_execution_at()|
- |lh#option#get()|
- |lh#option#get_non_empty()|
- |lh#position#char_at_mark()|
- |lh#position#char_at_pos()|
- |lh#position#is_before()|
- |lh#visual#selection()|
- |lh#visual#cut()|
Functors related functions:                             |lhvl#function|
- |lh#function#bind()|
- |lh#function#execute()|
- |lh#function#prepare()|
Lists related functions:                                |lhvl#list|
- |lh#list#accumulate()|
- |lh#list#at()|
- |lh#list#copy_if()|
- |lh#list#equal_range()|, 
- |lh#list#Find_if()| and |lh#list#find_if()|
- |lh#list#intersect()|
- |lh#list#lower_bound()| and |lh#list#upper_bound()| 
- |lh#list#match()|
- |lh#list#matches()|
- |lh#list#not_found()|
- |lh#list#remove()|
- |lh#list#subset()|
- |lh#list#Transform()| and |lh#list#transform()|
- |lh#list#transform_if()|
- |lh#list#unique_sort()| and |lh#list#unique_sort2()|
Graphs related functions:                               |lhvl#graph|
- |lh#graph#tsort#depth()|
- |lh#graph#tsort#breadth()|
Paths related functions:                                |lhvl#path|
- |lh#path#common()|
- |lh#path#depth()|
- |lh#path#glob_as_list()|
- |lh#path#is_absolute_path()|
- |lh#path#is_url()|
- |lh#path#select_one()|
- |lh#path#simplify()|
- |lh#path#strip_common()|
- |lh#path#strip_start()|
- |lh#path#to_dirname()|
- |lh#path#to_relative()|
- |lh#path#relative_to()|
- |lh#path#to_regex()|
Commands related functions:                             |lhvl#command|
- |lh#command#new()| (alpha version)
- |lh#command#Fargs2String()| (alpha version)
- |lh#command#complete()| (alpha version)
Menus related functions:                                |lhvl#menu|
- |lh#menu#def_toggle_item()|
- |lh#menu#text()|
- |lh#menu#make()|
- |lh#menu#IVN_make()|
- |lh#menu#is_in_visual_mode()|
- |lh#menu#map_all()|
- |lh#askvim#menu()| (beta version)
Buffers related functions:                              |lhvl#buffer|
- |lh#buffer#list()|
- |lh#buffer#find()|
- |lh#buffer#jump()|
- |lh#buffer#scratch()|
- |lh#buffer#dialog#| functions for building interactive dialogs
    - |lh#buffer#dialog#new()|
    - |lh#buffer#dialog#add_help()|
    - |lh#buffer#dialog#select()|
    - |lh#buffer#dialog#quit()|
    - |lh#buffer#dialog#update()|
Syntax related functions:                               |lhvl#syntax|
- |lh#syntax#name_at()|
- |lh#syntax#name_at_mark()|
- |lh#syntax#skip()|
- |lh#syntax#skip_at()|
- |lh#syntax#skip_at_mark()|
- |lh#syntax#list_raw()|
- |lh#syntax#list()|
Completion related functions				|lhvl#completion|

}}}2
------------------------------------------------------------------------------
MISCELLANOUS FUNCTIONS                                *lhvl#misc*       {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                       *lh#common#echomsgMultilines()*  {{{3
lh#common#echomsgMultilines()({text}) (*deprecated*)~
                                      *lh#common#echomsg_multilines()*
lh#common#echomsg_multilines()({text})~
@param  {text}      Message to display on several lines
@return             Nothing

This function executes |:echomsg| as many times as required as there are lines
in the original {text}.
This is a workaround |:echomsg| that is unable to handle correctly multi-lines
messages.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#common#ErrorMsg()*  {{{3
lh#common#ErrorMsg({text}) (*deprecated*)~
                                               *lh#common#error_msg()*
lh#common#error_msg({text})~
@param  {text}      Error message to display
@return             Nothing

This function displays an error message in a |confirm()| box if gvim is being
used, or as a standard vim error message through |:echoerr| otherwise. 

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#common#WarningMsg()* {{{3
lh#common#WarningMsg({text}) (*deprecated*)~
                                              *lh#common#warning_msg()*
lh#common#warning_msg({text})~
@param  {text}      Error message to display
@return             Nothing

This function displays a warning message highlighted with |WarningMsg| syntax.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#common#CheckDeps()* {{{3
lh#common#CheckDeps({symbol},{file},{path},{requester}) (*deprecated*)~
                                               *lh#common#check_deps()*
lh#common#check_deps({symbol},{file},{path},{requester})~
@param  {symbol}    Symbol required, see |exists()| for symbol format.
@param  {file}      File in which the symbol is expected to be defined
@param  {path}      Path where the file can be found
@param  {requester} Name of the script in need of this symbol
@return 0/1 whether the {symbol} exists

Checks if {symbol} exists in vim. If not, this function first tries
to |:source| the {file} in which the {symbol} is expected to be defined. If the
{symbol} is still not defined, an error message is issued (with
|lh#common#error_msg()|, and 0 is returned.

Example: >
    if   
          \    !lh#common#check_deps('*Cpp_CurrentScope', 
          \                     'cpp_FindContextClass.vim', 'ftplugin/cpp/',
          \                     'cpp#GotoFunctionImpl.vim')
          \ || !lh#common#check_deps(':CheckOptions',
          \                     'cpp_options-commands.vim', 'ftplugin/cpp/',
          \                     'cpp#GotoFunctionImpl.vim')
      let &cpo=s:cpo_save
      finish
    endif

Note: Since the introduction of |autoload| plugins in Vim 7, this function has
lost most of its interrest.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#option#Get()*       {{{3
lh#option#Get({name},{default}[,{scopes}])  (*deprecated*)~
                                                *lh#option#get()*
lh#option#get({name},{default}[,{scopes}])~
@param {name}       Name of the option to fetch
@param {default}    Default value in case the option is not defined
@param {scopes}     Vim scopes in which the options must be searched,
                    default="bg".
@return             b:{name} if it exists, or g:{name} if it exists, or
                    {default} otherwise.
@see                For development oriented options, |lh-dev| provides a
                    dedicated function: |lh#dev#option#get()|.

This function fetches the value of an user defined option (not Vim |options|).
The option can be either a |global-variable|, a |buffer-variable|, or even
a|window-variable|.

The order of the variables checked can be specified through the optional
argument {scopes}. By default, buffer-local options have the priority over
global options.


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                              *lh#option#GetNonEmpty()* {{{3
lh#option#GetNonEmpty({name},{default}[,{scopes}])  (*deprecated*)~
                                              *lh#option#get_non_empty()*
lh#option#get_non_empty({name},{default}[,{scopes}])~
@param {name}       Name of the option to fetch
@param {default}    Default value in case the option is not defined, nor empty
@param {scopes}     Vim scopes in which the options must be searched,
                    default="bg".
@return b:{name}    If it exists, of g:{name} if it exists, or {default}
                    otherwise.

This function works exactly like |lh#option#get()| except that a defined
variable with an empty value will be ignored as well.
An |expr-string| will be considered empty if its |strlen()| is 0, an
|expr-number| when it values 0, |Lists| and |Dictionaries| when their |len()|
is 0.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#askvim#Exe()*       {{{3
lh#askvim#Exe({command}) (*deprecated*)~
                                                *lh#askvim#exe()*
lh#askvim#exe({command})~
@param {command}    Command to execute from vim.
@return             What the command echoes while executed.
@note               This function encapsultates |redir| without altering any
                    register.

Some information aren't directly accessible (yet) through vim API
(|functions|).  However, they can be obtained by executing some commands, and
redirecting the result of these commands.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#askvim#menu()*      {{{3
lh#askvim#menu({menuid},{modes})~
@param {menuid}     Menu identifier.
@param {modes}      List of modes
@return             Information related to the {menuid}
@todo               Still bugged

This function provides a way to obtain information related to a menu entry in
Vim.

The format of the result being «to be stabilized»

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#position#IsBefore()* {{{3
lh#position#IsBefore({lhs_pos},{rhs_pos})  (*deprecated*)~
                                               *lh#position#is_before()*
lh#position#is_before({lhs_pos},{rhs_pos})~
@param[in]          Positions as those returned from |getpos()|
@return             Whether {lhs_pos} is before {rhs_pos}

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                             *lh#position#CharAtMark()* {{{3
lh#position#CharAtMark({mark})  (*deprecated*)~
                                             *lh#position#char_at_mark()*
lh#position#char_at_mark({mark})~
@return             The character at a given |mark|.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                              *lh#position#CharAtPos()* {{{3
lh#position#CharAtPos({pos})  (*deprecated*)~
                                              *lh#position#char_at_pos()* {{{3
lh#position#char_at_pos({pos})~
@return             The character at a position (see |getpos()|).

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#visual#selection()* {{{3
lh#visual#selection()~
@return             The current visual selection
@post              |registers| are not altered by this function

                                                *lh#visual#cut()*       {{{3
lh#visual#cut()~
@return             The current visual selection
@post              |registers| are not altered by this function ; 
                    selection is deleted.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                 *lh#event#RegisterForOneExecutionAt()* {{{3
lh#event#RegisterForOneExecutionAt({event}, {cmd}, {group})  (*deprecated*)~
                                 *lh#event#register_for_one_execution_at()*
lh#event#register_for_one_execution_at({event}, {cmd}, {group})~
Registers a command to be executed once (and only once) when {event} is
triggered on the current file.

@param {event}  Event that will trigger the execution of {cmd}|autocmd-events|
@param   {cmd} |expression-command| to execute
@param {group} |autocmd-groups| under which the internal autocommand will be
                registered.
@todo possibility to specify the file pattern

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#encoding#iconv()*   {{{3
lh#encoding#iconv({expr}, {from}, {to})~
This function just calls |iconv()| with the same arguments. The only
difference is that it return {expr} when we know that |iconv()| will return an
empty string.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#encoding#strlen()*  {{{3
lh#encoding#strlen({mb_string})~
This function returns the length of the multi-bytes string.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#encoding#at()*      {{{3
lh#encoding#at({mb_string}, {i})~
Returns the i-th character in a multi-bytes string.
@param {i} 0-indexed offset.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#encoding#strpart()* {{{3
lh#encoding#strpart({mb_string}, {position}, {length})~
Returns {length} extracted characters from {position} in a multi-bytes string.
@param {position} 0-indexed offset.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                               *lh#float#max()*     *lh#float#min()*    {{{3
                               *lh#float#arg_max()* *lh#float#arg_min()*
lh#float#min({list})~
lh#float#arg_min({list})~
lh#float#min({list})~
lh#float#arg_min({list})~
Returns The minimum, /arg-minimum, /maximum, /arg-maximum of a |List| of
|expr-float|. 


------------------------------------------------------------------------------
FUNCTORS RELATED FUNCTIONS                            *lhvl#function*   {{{2

This sub-library helps defining functors-like variables, and execute them.

NB: C++ developpers may be already familiar with boost.bind
(/std(::tr1)::bind) function that inspired by feature.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                                                      *lhvl#functor*    {{{3
A functor is implemented as a |Dictionary| that has the following fields:
- {execute}  is the |Funcref| that will be actually executed by
             |lh#function#execute()|. Its only argument is a |List| of
              arguments for {function}.
- {function} that identifies the function to execute, 
              internals: it could be either a |Funcref|or a |expr-string|, or
              whatever is compatible with the {execute} |FuncRef| field.
- {args}     will contain the binded arguments as defined by
             |lh#function#bind()|. If you attach a {execute} function of your
              own to a functor, you don't need to fill "args".

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                                                *lh#function#bind()*    {{{3
lh#function#bind({fn} [, {arguments} ...])~
This function creates a new |lhvl#functor| based on a given function {fn}, and
where some arguments are binded to the ones from {arguments}.
The result is a new function-like data having for parameter v:1_, v:2_, ...
that were specified in |lh#function#bind()| {arguments} list.

Examples:~
   See tests/lh/function.vim

Let's suppose Print(...) a VimL variadic function that echoes the arguments it
receives, i.e. >
   call Print(1,2,"text", ['foo', 'bar'])
will echo: >
   1 ## 2 ## 'text' ## ['foo', 'bar']

* Binding a |FuncRef|:~
  and reverse the arguments given to it when it will be executed >
   >:let func = lh#function#bind(function('Print'), 'v:3_', 'v:2_', 'v:1_')
   >:echo lh#function#execute(func, 1, 'two', [3])
   [3] ## 'two' ## 1

* Binding a named function:~
  the new function has 3 parameters and calls the named function with its 3rd
  parameter, 42, its second and its first parameters as arguments. >
   >:let func = lh#function#bind('Print', 'v:3_', 42, 'v:2_', 'v:1_')
   >:echo lh#function#execute(func, 1, 'two', [3])
   [3] ## 42 ## 'two' ## 1
< NB: if exists('*'.func_name) is false, then the string is considered to be
  an expression that will be evaluated as specified in the next use case.

* Binding an expression:~
  This time more complex on-the-fly computations on the |lhvl#functor|
  parameters can be accomplished >
   >:let func = lh#function#bind('Print(len(v:3_), 42, v:2_, v:1_)')
   >:echo lh#function#execute(func, 1, 'two', [1,2,3])
   3 ## 42 ## 'two' ## 1
< NB: func["args"] is defined, but empty, and unused.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                                                *lh#function#execute()* {{{3
lh#function#execute({functor} [, {arguments} ...])~
While |lh#function#bind()| defines a |lhvl#functor| that can be stored and
used later, |lh#function#execute()| directly executes the {functor} received.

Different kind of {functors} are accepted:
- |FuncRef|, and function names, where arguments are |lh#function#execute()|
  ones ;
- |expr-string|, where "v:{pos}_" strings are binded on-the-fly to {arguments} ;
- |lhvl#functor|, that will be given {arguments} as arguments.

Examples:~
   See tests/lh/function.vim

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                                                *lh#function#prepare()* {{{3
lh#function#prepare({function}, {arguments} ...)~
This function expands all the elements from the {arguments} |List|, and
prepares a |expr-string| that once evaluated will call the n-ary {function}
with the n-{arguments}.
The evaluation is meant to be done with |eval()|.
>
   >:let call = lh#function#prepare('Print', [1,2,"foo"])
   >:echo eval(call)
   1 ## 2 ## 'foo'


------------------------------------------------------------------------------
LISTS RELATED FUNCTIONS                               *lhvl#list*       {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#list#Match()*       {{{3
lh#list#Match({list},{pattern}[, {start-pos}])  (*deprecated*)~
                                                *lh#list#match()*
lh#list#match({list},{pattern}[, {start-pos}])~
@param      {list} |List| 
@param   {pattern} |expr-string|
@param {start-pos}  First index to check
@return             The lowest index, >= {start-pos}, in |List| {list} where
                    the item matches {pattern}.
@return             -1 if no item matches {pattern}.
@see |index()|, |match()|

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#list#matches()*     {{{3
lh#list#match({list},{pattern}[, {start-pos}])~
@param      {list} |List| 
@param   {pattern} |expr-string|
@param {start-pos}  First index to check
@return             The |List| of indices, >= {start-pos}, in |List| {list} where
                    the item matches {pattern}.
@return             [] if no item matches {pattern}.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                            *lh#list#find_if()* *lh#list#Find_if()*     {{{3
lh#list#Find_if({list},{string-predicate} [, {pred-parameters}][, {start-pos}])~
lh#list#find_if({list},{functor-predicate} [, {pred-parameters}][, {start-pos}])~
@param             {list} |List| 
@param      {*-predicate}  Predicate to evaluate
@param {pred-parameters}] |List| of Parameters to bind to special arguments in
                           the {predicate}.
@param         {start-pos} First index to check
@return                    The lowest index, >= {start-pos}, in |List| {list}
                           where the {predicate} evals to true.
@return                    -1 if no item matches {pattern}.
@see |index()|, |eval()|

The {string-predicate} recognizes some special arguments:
- |v:val| is substituted with the current element being evaluated in the list
- *v:1_* *v:2_* , ..., are substituted with the i-th elements from
  {pred-parameters}.
  NB: the "v:\d\+_" are 1-indexed while {pred-parameters} is indeed seen as
  0-indexed by Vim. 
  This particular feature permits to pass any type of variable to the
  predicate: a |expr-string|, a |List|, a |Dictionary|, ...

e.g.: >
    :let b = { 'min': 12, 'max': 42 }
    :let l = [ 1, 5, 48, 25, 5, 28, 6]
    :let i = lh#list#Find_if(l, 'v:val>v:1_.min  && v:val<v:1_.max && v:val%v:2_==0', [b, 2] )
    :echo l[i]
    28

The {functor-predicate} is a |lhvl#function|. The same example can be
rewritten as: >
    :let l = [ 1, 5, 48, 25, 5, 28, 6]
    :let i = lh#list#find_if(l, 'v:1_>12  && v:1_<42 && v:1_%2==0')
    :echo l[i]
    28
NB: Expect the Find_if() version to be replaced with the find_if() one.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                        *lh#list#lower_bound()* *lh#list#upper_bound()* {{{3
			*lh#list#equal_range()*
lh#list#lower_bound({list}, {value} [, {first}][, {last}])~
lh#list#upper_bound({list}, {value} [, {first}][, {last}])~
lh#list#equal_range({list}, {value} [, {first}][, {last}])~
@param  {list}  Sorted |List| 
@param  {value} Value to search
@param  {first} First index to check
@param  {last}  Last+1 index to check
@return The lowest index, >= {first} and < {last}, in |List| {list}
        such as the index is <= first {value} occurrence, in lower_bound case
        such as the index is > last {value} occurrence, in upper_bound case
@return -1 if no item matches {pattern}.
@return the pair [lower_bound(), upper_bound()] in equal_range() case 
@see C++ STL eponym algorithms.


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#list#not_found()*   {{{3
lh#list#not_found({range})~
Returns whether the {range} is empty. This function can be used to check
|lh#list#equal_range()| functions results

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                   *lh#list#unique_sort()* *lh#list#unique_sort2()*     {{{3
lh#list#unique_sort({list} [, {cmp}])~
lh#list#unique_sort2({list} [, {cmp}])~
@param[in] {list} |List| to sort
@param      {cmp} |Funcref| or function name that acts as a compare predicate.
                   It seems to be required in order to not compare number with
                   a lexicographic order (with vim 7.1-156)
@return            A new |List| sorted with no element repeated
@todo support an optional {equal} predicate to use in the /unique/ making
process.

The difference between the two functions is the following:
- unique_sort() stores all the elements in a |Dictionary|, then sort the values
  stored in the dictionary ;
- unique_sort2() sorts all the elements from the initial |List|, and then
  keeps only the elements that appear once.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#list#Transform()*   {{{3
lh#list#Transform({input},{output},{action})~
@param[in]   {input} Input |List| to transform
@param[out] {output} Output |List| where the transformed elements will be
                     appended.
@param      {action} Stringified action to apply on each element from {input}.
                     The string "v:val" will always be replaced with the
                     element currently transformed.
@return {output}

This function is actually returning >
    extend(a:output, map(copy(a:input), a:action))

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#list#transform()*   {{{3
lh#list#transform({input},{output},{action})~
@param[in]   {input} Input |List| to transform
@param[out] {output} Output |List| where the transformed elements will be
                     appended.
@param      {action}|lhvl#functor| action to apply on each element from
                     {input}.
@return              {output}

This function is equivalent to (|lh#list#Transform()|) >
    extend(a:output, map(copy(a:input), a:action))
except the action is not a string but a |lhvl#functor|.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                              *lh#list#transform_if()* {{{3
lh#list#transform_if({input},{output},{action},{predicate})~
@param[in]   {input} Input |List| to transform
@param[out] {output} Output |List| where the transformed elements will be
                     appended.
@param      {action}|lhvl#functor| action to apply on each element from
                     {input} that verifies the {predicate}.
@param   {predicate} Boolean |lhvl#functor| tested on each element before
                     transforming it.
@return              {output}

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#list#copy_if()*     {{{3
lh#list#copy_if({input},{output},{predicate})~
Appends in {output} the elements from {input} that verifies the {predicate}. 

@param[in]   {input} Input |List| to transform
@param[out] {output} Output |List| where the elements that verify the
                     {predicate} will be appended.
@param   {predicate} Boolean |lhvl#functor| tested on each element.
@return              {output}

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#list#accumulate()*  {{{3
lh#list#accumulate({input},{transformation},{accumulator})~
Accumulates the transformed elements from {input}.

@param[in]      {input} Input |List| to transform
@param {transformation}|lhvl#functor| applied on each element from {input}.
@param    {accumulator}|lhvl#functor| taking the list of tranformaed elements
                        as input
@return                 the result of {accumulator}

Examples: >
   :let strings = [ 'foo', 'bar', 'toto' ]
   :echo eval(lh#list#accumulate(strings, 'strlen', 'join(v:1_,  "+")'))
   10

   :let l = [ 1, 2, 'foo', ['bar']]
   :echo lh#list#accumulate(l, 'string', 'join(v:1_, "##")')

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#list#subset()*      {{{3
lh#list#subset({input},{indices})~
Returns a subset slice of the {input} list.

@param[in] {input}   Input |List| from which  element will be extracted
@param[in] {indices}|List| of indices to extract
@return a |List| of the elements from {input} indexed by the {indices}

Example: >
    :let l = [ 1, 25, 5, 48, 25, 5, 28, 6]
    :let indices = [ 0, 5, 7, 3 ]
    :echo lh#list#subset(l, indices) 
    [ 1, 5, 6, 48 ]

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#list#remove()*      {{{3
lh#list#remove({input},{indices})~
Returns a subset slice of the {input} list trimmed of elements.

@param[in,out] {input}   Input |List| from which  element will be removed
@param[in]     {indices}|List| of indices to remove
@return a |List| of the elements from {input} not indexed by the {indices}
@pre {indices} MUST be sorted

Example: >
    :let l = [ 1, 25, 5, 48, 25, 5, 28, 6]
    :let indices = [ 0, 3, 5, 7 ]
    :echo lh#list#remove(l, indices) 
    [ 25, 5, 25, 28 ]

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#list#intersect()*   {{{3
lh#list#intersect({list1},{list2})~
Returns the elements present in both input lists.

@param[in] {list1}|List| 
@param[in] {list2}|List| 
@return a |List| of the elements in both {list1} and {list2}, the elements are
kepts in the same order as in {list1}
@note the algorithm is in O(len({list1})*len({list2}))

Example: >
    :let l1 = [ 1, 25, 7, 48, 26, 5, 28, 6]
    :let l2 = [ 3, 8, 7, 25, 6 ]
    :echo lh#list#intersect(l1, l2) 
    [ 25, 7, 6 ]

------------------------------------------------------------------------------
GRAPHS RELATED FUNCTIONS                              *lhvl#graph*      {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                             *lh#graph#tsort#depth()*   {{{3
                                             *lh#graph#tsort#breadth()* {{{3
lh#graph#tsort#depth({dag}, {start-nodes})~
lh#graph#tsort#breadth({dag}, {start-nodes})~
These two functions implement a topological sort on the Direct Acyclic Graph.
- depth() is a recursive implementation of a depth-first search. 
- breadth() is a non recursive implementation of a breadth-first search.

@param {dag} is a direct acyclic graph defined either:
             - as a |Dictionnary| that associates to each node, the |List| of
               all its successors
             - or as a /fetch/ |function()| that returns the |List| of the
               successors of a given node -- works only with depth() which
               takes care of not calling this function more than once for each
               given node.
@param {start-nodes} is a |List| of start nodes with no incoming edge
@throw "Tsort: cyclic graph detected:" if {dag} is not a DAG.
@see http://en.wikipedia.org/wiki/Topological_sort
@since Version 2.1.0
@test tests/lh/topological-sort.vim


------------------------------------------------------------------------------
PATHS RELATED FUNCTIONS                               *lhvl#path*       {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                   *lh#path#depth()*    {{{3
lh#path#depth({dirname})~
Returns the depth of a directory name.

@param {dirname}  Pathname to simplify
@return the depth of the simplified directory name, i.e. 
        lh#path#depth("bar/b2/../../foo/") returns 1

@todo However, it is not able to return depth of negative paths like
      "../../foo/". I still need to decide whether the function should return
      -1 or 3.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                 *lh#path#dirname()*    {{{3
lh#path#dirname({dirname})~
Ensures the returned directory name ends with a '/' or a '\'.

@todo On windows, it should take 'shellslash' into account to decide the
      character to append.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#Simplify()*    {{{3
lh#path#Simplify({pathname})  (*deprecated*)~
                                                *lh#path#simplify()*
lh#path#simplify({pathname} [{make_relative_to_pwd])~
Simplifies a path by getting rid of useless '../' and './'.

@param {pathname}             Pathname to simplify
@param {make_relative_to_pwd} The {pathname} is made relative to pwd when set
@return the simplified pathname

This function works like |simplify()|, except that it also strips the leading
"./".

Note: when vim is compiled for unix, it seems unable to |simplify()| paths
containing "..\". (It likelly works this way when vim is compiled without
'shellslash' support)

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *lh#path#common()*  {{{3
lh#path#common({pathnames})~
@param[in] {pathnames} |List| of pathnames to analyse
@return the common leading path between all {pathnames}

e.g.: >
 :echo lh#path#common(['foo/bar/file','foo/file', 'foo/foo/file'])
echoes >
 foo/

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#StripCommon()* {{{3
lh#path#StripCommon({pathnames})  (*deprecated*)~
                                                *lh#path#strip_common()*
lh#path#strip_common({pathnames})~
@param[in,out] {pathnames} |List| of pathnames to simplify
@return the simplified pathnames

This function strips all pathnames from their common leading part. The
compuation of the common leading part is ensured by |lh#path#common()|
thank.
e.g.: >
 :echo lh#path#strip_common(['foo/bar/file','foo/file', 'foo/foo/file'])
echoes >
 ['bar/file','file', 'foo/file']

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                 *lh#path#StripStart()* {{{3
lh#path#StripStart({pathname}, {pathslist})  (*deprecated*)~
                                                 *lh#path#strip_start()*
lh#path#strip_start({pathname}, {pathslist})~
@param[in] {pathname}  name to simplify
@param[in] {pathslist} list of pathname (can be a |string| of pathnames
                       separated by ",", of a |List|).

Strips {pathname} from any path from {pathslist}.

e.g.: >
 :echo lh#path#strip_start($HOME.'/.vim/template/bar.template',
   \ ['/home/foo/.vim', '/usr/local/share/vim/'])
 :echo lh#path#strip_start($HOME.'/.vim/template/bar.template',&rtp)
echoes >
 template/bar.template

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#IsAbsolutePath()* {{{3
lh#path#IsAbsolutePath({path})  (*deprecated*)~
                                                *lh#path#is_absolute_path()*
lh#path#is_absolute_path({path})~
@return {path} Path to test
@return whether the path is an absolute path
@note Supports Unix absolute paths, Windows absolute paths, and UNC paths

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#IsURL()*       {{{3
lh#path#IsURL({path})  (*deprecated*)~
                                                *lh#path#is_url()*
lh#path#is_url({path})~
@return {path} Path to test
@return whether the path is an URL
@note Supports http(s)://, (s)ftp://, dav://, fetch://, file://, rcp://,
rsynch://, scp://

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#SelectOne()*   {{{3
lh#path#SelectOne({pathnames},{prompt})  (*deprecated*)~
                                                *lh#path#select_one()*
lh#path#select_one({pathnames},{prompt})~
@param[in] {pathnames} |List| of pathname
@param     {prompt}     Prompt for the dialog box

@return "" if len({pathnames}) == 0
@return {pathnames}[0] if len({pathnames}) == 1
@return the selected pathname otherwise

Asks the end-user to choose a pathname among a list of pathnames.
The pathnames displayed will be simplified thanks to |lh#path#strip_common()|
-- the pathname returned is the "full" original pathname matching the
simplified pathname selected.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#ToRelative()*  {{{3
lh#path#ToRelative({pathname})  (*deprecated*)~
                                                *lh#path#to_relative()*
lh#path#to_relative({pathname})~
@param {pathname} Pathname to convert
@return the simplified {pathname} in its relative form as it would be seen
        from the current directory.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#relative_to()*  {{{3
lh#path#relative_to({from}, {to})~
Returns the relative directory that indentifies {to} from {from} location.
@param {from} origin directory
@param {to}   destination directory
@return the simplified pathname {to} in its relative form as it would be seen
        from the {from} directory.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#GlobAsList()*  {{{3
lh#path#GlobAsList({pathslist}, {expr})  (*deprecated*)~
                                                *lh#path#glob_as_list()*
lh#path#glob_as_list({pathslist}, {expr})~
@return |globpath()|'s result, but formatted as a list of matching pathnames.
In case {expr} is a |List|, |globpath()| is applied on each expression in
{expr}.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *lh#path#find()*    {{{3
lh#path#find({pathslist}, {regex})~
@param[in] {pathslist} List of paths which can be received as a |List| or as a
                       string made of coma separated paths.
@return the path that matches the given {regex}

e.g.: >
 let expected_win = $HOME . '/vimfiles'
 let expected_nix = $HOME . '/.vim'
 let what =  lh#path#to_regex($HOME.'/').'\(vimfiles\|.vim\)'
 let z = lh#path#find(&rtp,what)
 if has('win16')||has('win32')||has('win64')
   Assert z == expected_win
 else
   Assert z == expected_nix
 endif

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#path#to_regex()*    {{{3
lh#path#to_regex({pathname})~
Transforms the {pathname} to separate each node-name by the string '[/\\]' 

The rationale behind this function is to build system independant regex
pattern to use on pathnames as sometimes pathnames are built by appending
'/stuff/like/this' without taking 'shellslash' into account.

e.g.: >
 echo lh#path#to_regex('/home/luc/').'\(vimfiles\|.vim\)'
echoes >
 [/\\]home[/\\]luc[/\\]\(vimfiles\|.vim\)


------------------------------------------------------------------------------
MENUS RELATED FUNCTIONS                               *lhvl#menu*       {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                             *lh#menu#def_toggle_item()*  {{{3
lh#menu#def_toggle_item({Data})~
@param[in,out] {Data} Definition of a |menu| item.

This function defines a |menu| entry that will be associated to a
|global-variable| whose values can be cycled and explored from the menu. This
global variable can be seen as an enumerate whose value can be cyclically
updated through a menu.

{Data} is a |Dictionary| whose keys are:
- "variable": name of the |global-variable| to bind to the menu entry
  Mandatory.
- "values": associated values of string or integers (|List|)
  Mandatory.
- "menu": describes where the menu entry must be placed (|Dictionary|)
    - "priority": complete priority of the entry (see |sub-menu-priority|)
    - "name": complete name of the entry -- ampersand (&) can be used to define
      shortcut keys
  Mandatory.
- "idx_crt_value": index of the current value for the option (|expr-number|)
  This is also an internal variable that will be automatically updated to
  keep the index of the current value of the "variable" in "values".
  Optional ; default value is 1, or the associated index of the initial value
  of the variable (in "values") before the function call.
- "texts": texts to display according to the variable value (|List|)
  Optional, "values" will be used by default. This option is to be used to
  distinguish the short encoded value, from the long self explanatory name.
- "hook": |function| to call, or command to |:execute| when the value of the
  variable is toggled through toggle-menu ; default: none.
- "actions": list of functions to call, or commands to execute when the value
  of the variable is toggled through toggle-menu. There shall be one action
  per possible value when defined ; default: empty list

Warning:
    If the variable is changed by hand without using the menu, then the menu
    and the variable will be out of synch. Unless the command |lhvl-:Toggle|
    is used to change the value of the options (and keep the menu
    synchronized).

Examples:
   See tests/lh/test-toggle-menu.vim

                                                            *lhvl-:Toggle*
:Toggle {variable-name} [{text-value}]~
@param {variable-name} 
	    must be a |global-variable| name used as "variable" in the
	    definition of a toggable menu item thanks to
	    |lh#menu#def_toggle_item()|.
@param {text-value}
            when specified, :Toggle directly sets the variable to the value
	    associated to {text-value}.

This command supports autocompletion on the {variable-name}, and on
{text-value}.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                      *lh#menu#text()*  {{{3
lh#menu#text({text})~
@param[in] {text} Text to send to |:menu| commands
@return a text to be used in menus where "\" and spaces have been escaped.

This helper function transforms a regular text into a text that can be
directly used with |:menu| commands.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                      *lh#menu#make()*  {{{3
option: *[gb]:want_buffermenu_or_global_disable*
If Michael Geddes's |buffer-menu| plugin is installed, this option tells
whether we want to take advantage of it to define menus or to ignore it.

lh#menu#make({modes}, {menu-priority}, {menu-text}, {key-binding}, [<buffer>,]  {action})~
Creates a menu entry and its associated mappings for several modes at once.

@param[in] {modes} Vim modes the menus and maps will be provided for
@param[in] {menu-priority} |sub-menu-priority| for the new menu entry
@param[in] {menu-text}      Name of the new menu entry
@param[in] {key-binding}    Sequence of keys to execute the associated action
@param[in] "<buffer>"       If the string "<buffer>" is provided, then the 
                            associated mapping will be a |map-<buffer>|, and
                            the menu will be available to the current buffer
                            only. See |[gb]:want_buffermenu_or_global_disable|
                            When "<buffer>" is set, the call to lh#menu#make()
                            must be done in the buffer-zone from a |ftplugin|,
                            or from a |local_vimrc|.
@param[in] {action}         Action to execute when {key-binding} is typed, or
                            when the menu entry is selected.
@todo support select ('s') and visual-not-select ('x') modes

First example:~
The following call will add the menu "LaTeX.Run LaTeX once <C-L><C-O>", with
the priority (placement) 50.305, for the NORMAL, INSERT and COMMAND modes. The
action associated first saves all the changed buffers and then invokes LaTeX.
The same action is also binded to <C-L><C-O> for the same modes, with the
nuance that the maps will be local to the buffer.
>
  call lh#menu#make("nic", '50.305', '&LaTeX.Run LaTeX &once', "<C-L><C-O>",
          \ '<buffer>', ":wa<CR>:call TKMakeDVIfile(1)<CR>")

Second example:~
This example demonstrates an hidden, but useful, behavior: if the mode is the
visual one, then the register v is filled with the text of the visual area.
This text can then be used in the function called. Here, it will be proposed
as a default name for the section to insert:
>
  function! TKinsertSec()
    " ...
    if (strlen(@v) != 0) && (visualmode() == 'v')
      let SecName = input("name of ".SecType.": ", @v)
    else
      let SecName = input("name of ".SecType.": ")
    endif
    " ...
  endfunction
  
  call lh#menu#make("vnic", '50.360.100', '&LaTeX.&Insert.&Section',
          \ "<C-L><C-S>", '<buffer>', ":call TKinsertSec()<CR>")

We have to be cautious to one little thing, there is a side effect: the visual
mode vanishes when we enter the function. If you don't want this to happen,
use the non-existant command: |:VCall|.

Third example:~
If it is known that a function will be called only under |VISUAL-mode|, and
that we don't want of the previous behavior, we can explicitly invoke the
function with |:VCall| -- command that doesn't actually exist. Check
lh-tex/ftplugin/tex/tex-set.vim |s:MapMenu4Env| for such an example.

Fourth thing: actually, lh#menu#make() is not restricted to commands. The
action can be anything that could come at the right hand side of any |:map| or
|:menu| action. But this time, you have to be cautious with the modes you
dedicate your map to. I won't give any related example ; this is the
underlying approach in |lh#menu#IVN_make()|. 


                                                    *lh#menu#make()_modes*
Implementation details:~
The actual creation of the mappings is delegated to |lh#menu#map_all()|. 
If the {action} to execute doesn't start with ':', it is left untransformed,
otherwise it is adapted depending on each {mode}:
- INSERT-mode: each recognized |:command| call is prepended with |i_CTRL-O| 
- NORMAL-mode: the {action} is used as it is
- VISUAL-mode: ":Vcall" is replaced by "\<cr>gV", otherwise the selection is
  recorded into @v register, the {action} command is executed after a
  |v_CTRL-C|, and eventually @v is cleared. 
  The use is @v is deprecated, rely instead on |lh#menu#is_in_visual_mode()|
  and on |lh#selection#visual()|.
- COMMAND-mode: the {action} is prepended with |c_CTRL-C|.

Examples:
   See tests/lh/test-menu-map.vim

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                  *lh#menu#IVN_make()*  {{{3
Mappings & menus inserting text~
lh#menu#IVN_make(<priority>, {text}, {key}, {IM-action}, {VM-action}, {NM-action} [, {nore-IM}, {nore-VM}, {nore-NM}])~

lh#menu#IVN_MenuMake() accepts three different actions for the three modes:
INSERT, VISUAL and NORMAL. The mappings defined will be relative to the
current buffer -- this function is addressed to ftplugins writers. The last
arguments specify whether the inner mappings and abbreviations embedded within
the actions should be expanded or not ; i.e. are we defining
«noremaps/noremenus» ?

You will find very simple examples of what could be done at the end of
menu-map.vim. Instead, I'll show here an extract of my TeX ftplugin: it
defines complex functions that will help to define very simply the different
mappings I use. You could find another variation on this theme in
ftplugin/html/html_set.vim.

>
  :MapMenu 50.370.300 &LaTeX.&Fonts.&Emphasize ]em emph
  call <SID>MapMenu4Env("50.370.200", '&LaTeX.&Environments.&itemize',
        \ ']ei', 'itemize', '\item ')
  

The first command binds ]em to \emph{} for the three different modes. In
INSERT mode, the cursor is positioned between the curly brackets, and a marker
is added after the closing bracket -- cf. my bracketing system. In VISUAL
mode, the curly brackets are added around the visual area. In NORMAL mode, the
area is considered to be the current word.

The second call binds for the three modes: ]ei to:
>
      \begin{itemize}
          \item
      \end{itemize}
    
The definition of the different functions and commands involved just follows.
>
  command -nargs=1 -buffer MapMenu :call <SID>MapMenu(<f-args>)
  
  function! s:MapMenu(code,text,binding, tex_cmd, ...)
    let _2visual = (a:0 > 0) ? a:1 : "viw"
    " If the tex_cmd starts with an alphabetic character, then suppose the
    " command must begin with a '\'.
    let texc = ((a:tex_cmd[0] =~ '\a') ? '\' : "") . a:tex_cmd
    call lh#menu#IVN_make(a:code, a:text.'     --  ' . texc .'{}', a:binding,
          \ texc.'{',
          \ '<ESC>`>a}<ESC>`<i' . texc . '{<ESC>%l',
          \ ( (_2visual=='0') ? "" : _2visual.a:binding),
          \ 0, 1, 0)
  endfunction

  " a function and its map to close a "}", and that works whatever the
  " activation states of the brackets and marking features are.
  function! s:Close()
    if strlen(maparg('{')) == 0                    | exe "normal a} \<esc>"
    elseif exists("b:usemarks") && (b:usemarks==1) | exe "normal ¡jump! "
    else                                           | exe "normal a "
    endif
  endfunction

  imap <buffer> ¡close! <c-o>:call <SID>Close()<cr>

  function! s:MapMenu4Env(code,text,binding, tex_env, middle, ...)
    let _2visual = (a:0 > 0) ? a:1 : "vip"
    let b = "'" . '\begin{' . a:tex_env . '}' . "'"
    let e = "'" . '\end{' . a:tex_env . '}' . "'"
    call IVN_MenuMake(a:code, a:text, a:binding,
          \ '\begin{'.a:tex_env.'¡close!<CR>'.a:middle.' <CR>\end{'.a:tex_env.'}<C-F><esc>ks',
          \ ':VCall MapAroundVisualLines('.b. ',' .e.',1,1)',
          \ _2visual.a:binding,
          \ 0, 1, 0)
  endfunction

Examples:
   See tests/lh/test-menu-map.vim


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                         *lh#menu#is_in_visual_mode()*  {{{3
lh#menu#is_in_visual_mode()~
@return a boolean that tells whether the {action} used in
|lh#menu#is_in_visual_mode()| has been invoked from the VISUAL-mode.

NB: this function deprecates the test on @v.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                   *lh#menu#map_all()*  {{{3
lh#menu#map_all({map-type}[, {map-args...}])~
This function is a helper function that defines several mappings at once as
|:amenu| would do.

@param {map-type}     String of the form "[aincv]*(nore)?map" that tells the
                      mode on which mappings should be defined, and whether
                      the mappings shall be |:noremap|.
@param {map-args...}  Rest of the parameters that defines the mapping


The action to execute will be corrected depending on the current mode. See
|lh#menu#make()_modes| for more details.


------------------------------------------------------------------------------
COMMANDS RELATED FUNCTIONS                            *lhvl#command*    {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#command#new()*      {{{3
Highly Experimental.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                       *lh#command#Fargs2String()*      {{{3
lh#command#Fargs2String({aList})~
@param[in,out] aList list of params from <f-args>
@see tests/lh/test-Fargs2String.vim

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                            *lh#command#complete()*     {{{3
lh#command#complete({argLead}, {cmdLine}, {cursorPos})~
Under developpement


------------------------------------------------------------------------------
BUFFERS RELATED FUNCTIONS                             *lhvl#buffer*     {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#buffer#list()*      {{{3
lh#buffer#list()~
@return The |List| of |buflisted| buffers.

e.g.: >
 echo lh#list#transform(lh#buffer#list(), [], "bufname")

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#buffer#Find()*      {{{3
lh#buffer#Find({filename})  (*deprecated*)~
                                                *lh#buffer#find()*
lh#buffer#find({filename})~
Searchs for a window where the buffer is opened.

@param {filename}
@return The number of the first window found, in which {filename} is opened.

If {filename} is opened in a window, jump to this window. Otherwise, return
-1.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#buffer#Jump()*      {{{3
lh#buffer#Jump({filename}, {cmd})  (*deprecated*)~
                                                *lh#buffer#jump()*
lh#buffer#jump({filename}, {cmd})~
Jumps to the window where the buffer is opened, or open the buffer in a new
windows if none match.

@param {filename}
@param {cmd}
@return Nothing.

If {filename} is opened in a window, jump to this window. 
Otherwise, execute {cmd} with {filename} as a parameter. Typical values for
the command will be "sp" or "vsp". (see |:split|, |:vsplit|).

N.B.: While it is not the rationale behind this function, other commands that
does not open the buffer may be used in the {cmd} parameter.


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#buffer#Scratch()*   {{{3
lh#buffer#Scratch({bname},{where})  (*deprecated*)~
                                      *scratch* *lh#buffer#scratch()*
lh#buffer#scratch({bname},{where})~
Split-opens a new scratch buffer.

@param {bname} Name for the new scratch buffer
@param {where} Where the new scratch buffer will be opened ('', or 'v')
@post          The buffer has the following properties set: 
                   'bt'=nofile, 'bh'=wipe, 'nobl', 'noswf', 'ro'

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                             *lhvl-dialog*      *lh#buffer#dialog#*     {{{3
Functions for building interactive dialogs~
Unlike other |lh-vim-lib| functions which can be used independently from each
others, all the lh#buffer#dialog#*() functions constitute a coherent framework
to define interactive dialogs.

For the moment it only supports the selection of one or several items in a
list.

From a end-user point of view, a list of items is displayed in a (|scratch|)
buffer. If enabled, the user can select (/tag) one or several items, and then
validate its choice. He can always abort and quit the dialog. A few other
features are also supported: a help message can be shown, the list may be
colored, etc.


The items displayed can be of any kind (function signatures, email addresses,
suggested spellings, ...), as well as the validating action.  The
help-header can be customized, as well as colours, other mappings, ...

However the list displaying + selection aspect is almost hardcoded. 


How it works~
------------
Scripts have to call the function                    *lh#buffer#dialog#new()*
  lh#buffer#dialog#new(bname, title, where, support-tagging, action, choices)~
with:
- {bname} being the name the |scratch| buffer will receive.
- {title} the title that appears at the first line of the scratch buffer.
  I usually use it to display the name of the "client" script, its version,
  and its purpose/what to do.
- {where} are |:split| options (like "bot below") used to open the scratch
  buffer.
- {support-tagging} is a boolean (0/1) option to enable the multi-selection.
- {action} is the name of the callback function (more
  advanced calling mechanisms latter may be supported later with
  |lhvl-functions|).
- {choices} is the |List| of exact strings to display.

The #new function builds and returns a |Dictionary|, it also opens and fills
the scratch buffer, and put us within its context -- i.e. any |:map-<buffer>|
or other buffer-related definitions will done in the new scratch buffer.

Thus, if we want to add other mappings, and set a syntax highlighting for the
new buffer, it is done at this point (see the *s:PostInit()* function in my
"client" scripts like |lh-tags|).
At this point, I also add all the high level information to the
dictionary (for instance, the list of function signatures is nice, but
it does not provides enough information (the corresponding file, the
command to jump to the definition/declaration, the scope, ...)

The dictionary returned is filled with the following information:
- buffer ids,
- where was the cursor at the time of the creation of the new scratch buffer,
- name of the callback function.


Regarding the callback function: *lhvl-dialog-select-callback*
- It ca not be a |script-local| function, only global and autoload functions
  are supported.
- When called, we are still within the scratch buffer context.
- It must accept a |List| of numbers as its first parameter: the index (+1) of
  the items selected.
- The number 0, when in the list, means "aborted". In that case, the
  callback function is expected to call |lh#buffer#dialog#quit()| that will
  terminate the scratch buffer (with |:quit|), and jump back to where we were
  when #new was called, and display a little "Abort" message.
- We can terminate the dialog with just :quit if we don't need to jump
  back anywhere. For instance, lh-tags callback function first
  terminates the dialog, then jumps to the file where the selected tag
  comes from.

- It's completely asynchronous: the callback function does not return anything
  to anyone, but instead applies transformations in other places.
  This aspect is very important. I don't see how this kind of feature can work
  if not asynchronously in vim.

How to customize it:
- *lh#buffer#dialog#quit()* can be explicitly called, from a registered select
  callback (|lhvl-dialog-select-callback|), in order to terminate the dialog.
- *lh#buffer#dialog#add_help()* can be used to complete the help/usage message
  in both its short and long form.
- *lh#buffer#dialog#update()* can be called after the list of items has been
  altered in order to refresh what is displayed. The rationale behind this
  feature is to support sorting, filtering, items expansion, etc. See
 |lh-tags| implementation for an example.
- *lh#buffer#dialog#select()* can be used in new mappings in order to handle
  differently the selected items.
 |lh-tags| uses this function to map 'o' to the split-opening of the selected
  items.
  NB: the way this feature is supported may change in future releases.

Limitations:
This script is a little bit experimental (even if it the result of almost 10
years of evolution), and it is a little bit cumbersome.
- it is defined to support only one callback -- see the hacks in |lh-tags| to
  workaround this limitation.
- it is defined to display list of items, and to select one or several items
  in the end.
- and of course, it requires many other functions from |lh-vim-lib|, but
  nothing else.

------------------------------------------------------------------------------
SYNTAX RELATED FUNCTIONS                              *lhvl#syntax*     {{{2

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#syntax#NameAt()*    {{{3
lh#syntax#NameAt({lnum},{col}[,{trans}])  (*deprecated*)~
                                                *lh#syntax#name_at()*
lh#syntax#name_at({lnum},{col}[,{trans}])~
@param {lnum}  line of the character
@param {col}   column of the character
@param {trans} see |synID()|, default=0
@return the syntax kind of the given character at {lnum}, {col}

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#syntax#NameAtMark()* {{{3
lh#syntax#NameAtMark({mark}[,{trans}])  (*deprecated*)~
                                               *lh#syntax#name_at_mark()* {{{3
lh#syntax#name_at_mark({mark}[,{trans}])~
@param {mark}  position of the character
@param {trans} see |synID()|, default=0
@return the syntax kind of the character at the given |mark|.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
       *lh#syntax#Skip()* *lh#syntax#SkipAt()* *lh#syntax#SkipAtMark()* {{{3
lh#syntax#Skip()  (*deprecated*)~
lh#syntax#SkipAt({lnum},{col})  (*deprecated*)~
lh#syntax#SkipAtMark({mark})  (*deprecated*)~
       *lh#syntax#skip()* *lh#syntax#skip_at()* *lh#syntax#skip_at_mark()*
lh#syntax#skip()~
lh#syntax#skip_at({lnum},{col})~
lh#syntax#skip_at_mark({mark})~

Functions to be used with |searchpair()| functions in order to search for a
pair of elements, without taking comments, strings, characters and doxygen
(syntax) contexts into account while searching.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                               *lh#syntax#list_raw()*   {{{3
lh#syntax#list_raw({name})~
@param {group-name} 
@return the result of "syn list {group-name}" as a string

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *lh#syntax#list()*      {{{3
lh#syntax#list()~
@param {group-name} 
@return the result of "syn list {group-name}" as a list. 

This function tries to interpret the result of the raw list of syntax
elements. 

------------------------------------------------------------------------------
COMPLETION RELATED FUNCTIONS                          *lhvl#completion* {{{2

                                              *lh#icomplete#run()*      {{{3
lh#icomplete#run(startcol, matches, Hook)~
Runs |complete()| and registers the {Hook} to be executed when the user
selects one entry in the menu.

------------------------------------------------------------------------------
                                                                     }}}1
==============================================================================
 © Luc Hermitte, 2001-2011, <http://code.google.com/p/lh-vim/>       {{{1
 $Id: lh-vim-lib.txt 403 2011-06-24 09:12:43Z luc.hermitte $
 VIM: let b:VS_language = 'american' 
 vim:ts=8:sw=4:tw=80:fo=tcq2:ft=help:
 vim600:fdm=marker:
macros/menu-map.vim	[[[1
83
"===========================================================================
" $Id: menu-map.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		macros/menu-map.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
"
" Purpose:	Define functions to build mappings and menus at the same time
"
" Version:	2.2.1
" Last Update:  $Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $ (02nd Dec 2006)
"
" Last Changes: {{{
" 	Version 2.0.0:
" 		Moved to vim7, 
" 		Functions moved to {rtp}/autoload/
" 	Version 1.6.2: 
" 		(*) Silent mappings and menus
" 	Version 1.6. : 
" 		(*) Uses has('gui_running') instead of has('gui') to check if
" 		we can generate the menu.
" 	Version 1.5. : 
" 		(*) visual mappings launched from select-mode don't end with
" 		    text still selected -- applied to :VCalls
" 	Version 1.4. : 
" 		(*) address obfuscated for spammers
" 		(*) support the local option 
" 		    b:want_buffermenu_or_global_disable if we don't want
" 		    buffermenu to be used systematically.
" 		    0 -> buffer menu not used
" 		    1 -> buffer menu used
" 		    2 -> the VimL developper will use a global disable.
" 		    cf.:   tex-maps.vim:: s:SimpleMenu()
" 		       and texmenus.vim
" 	Version 1.3. :
"		(*) add continuation lines support ; cf 'cpoptions'
" 	Version 1.2. :
" 		(*) Code folded.
" 		(*) Take advantage of buffermenu.vim if present for local
" 		    menus.
" 		(*) If non gui is available, the menus won't be defined
" 	Version 1.1. :
"               (*) Bug corrected : 
"                   vnore(map\|menu) does not imply v+n(map\|menu) any more
" }}}
"
" Inspired By:	A function from Benji Fisher
"
" TODO:		(*) no menu if no gui.
"
"===========================================================================

if exists("g:loaded_menu_map") | finish | endif
let g:loaded_menu_map = 1  

"" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim

"=========================================================================
" Commands {{{
command! -nargs=+ -bang      MAP      map<bang> <args>
command! -nargs=+           IMAP     imap       <args>
command! -nargs=+           NMAP     nmap       <args>
command! -nargs=+           CMAP     cmap       <args>
command! -nargs=+           VMAP     vmap       <args>
command! -nargs=+           AMAP
      \       call lh#menu#map_all('amap', <f-args>)

command! -nargs=+ -bang  NOREMAP  noremap<bang> <args>
command! -nargs=+       INOREMAP inoremap       <args>
command! -nargs=+       NNOREMAP nnoremap       <args>
command! -nargs=+       CNOREMAP cnoremap       <args>
command! -nargs=+       VNOREMAP vnoremap       <args>
command! -nargs=+       ANOREMAP
      \       call lh#menu#map_all('anoremap', <f-args>)
" }}}

" End !
let &cpo = s:cpo_save
finish

"=========================================================================
" vim600: set fdm=marker:
mkVba/mk-lh-vim-lib.vim	[[[1
55
"=============================================================================
" $Id: mk-lh-vim-lib.vim 405 2011-06-24 09:14:09Z luc.hermitte $
" File:		mk-lh-lib.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.5
let s:version = '2.2.5'
" Created:	06th Nov 2007
" Last Update:	$Date: 2011-06-24 11:14:09 +0200 (ven., 24 juin 2011) $
"------------------------------------------------------------------------
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '22,$MkVimball! lh-vim-lib-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
autoload/lh/askvim.vim
autoload/lh/buffer.vim
autoload/lh/buffer/dialog.vim
autoload/lh/command.vim
autoload/lh/common.vim
autoload/lh/encoding.vim
autoload/lh/env.vim
autoload/lh/event.vim
autoload/lh/float.vim
autoload/lh/graph/tsort.vim
autoload/lh/icomplete.vim
autoload/lh/list.vim
autoload/lh/menu.vim
autoload/lh/option.vim
autoload/lh/path.vim
autoload/lh/position.vim
autoload/lh/syntax.vim
autoload/lh/visual.vim
doc/lh-vim-lib.txt
macros/menu-map.vim
mkVba/mk-lh-vim-lib.vim
plugin/let.vim
plugin/lhvl.vim
plugin/ui-functions.vim
plugin/words_tools.vim
tests/lh/function.vim
tests/lh/list.vim
tests/lh/path.vim
tests/lh/test-Fargs2String.vim
tests/lh/test-askmenu.vim
tests/lh/test-command.vim
tests/lh/test-menu-map.vim
tests/lh/test-toggle-menu.vim
tests/lh/topological-sort.vim
plugin/let.vim	[[[1
54
"=============================================================================
" $Id: let.vim 239 2010-06-01 00:48:43Z luc.hermitte $
" File:         plugin/let.vim                                    {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.1
" Created:      31st May 2010
" Last Update:  $Date: 2010-06-01 02:48:43 +0200 (mar., 01 juin 2010) $
"------------------------------------------------------------------------
" Description:
"       Defines a command :LetIfUndef that sets a variable if undefined
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/plugin
"       Requires Vim7+
" History:      
" 	v2.2.1: first version of this command into lh-vim-lib
" TODO: 
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
let s:k_version = 221
if &cp || (exists("g:loaded_let")
      \ && (g:loaded_let >= s:k_version)
      \ && !exists('g:force_reload_let'))
  finish
endif
let g:loaded_let = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
command! -nargs=+ LetIfUndef call s:LetIfUndef(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«let».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
function! s:LetIfUndef(var, value)
  if !exists(a:var)
    let {a:var} = eval(a:value)
  endif
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
plugin/lhvl.vim	[[[1
45
"=============================================================================
" $Id: lhvl.vim 245 2010-09-19 22:40:10Z luc.hermitte $
" File:		plugin/lhvl.vim                                   {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	27th Apr 2010
" Last Update:	$Date: 2010-09-20 00:40:10 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	
"       Non-function resources from lh-vim-lib
" 
"------------------------------------------------------------------------
" Installation:	
"       Drop the file into {rtp}/plugin
" History:	
"       v2.2.1  first version
" TODO:		«missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
let s:k_version = 221
if &cp || (exists("g:loaded_lhvl")
      \ && (g:loaded_lhvl >= s:k_version)
      \ && !exists('g:force_reload_lhvl'))
  finish
endif
let g:loaded_lhvl = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
" Moved from lh-cpp
command! PopSearch :call histdel('search', -1)| let @/=histget('search',-1)

" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
plugin/ui-functions.vim	[[[1
480
"=============================================================================
" File:         plugin/ui-functions.vim                                  {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" URL: http://hermitte.free.fr/vim/ressources/vimfiles/plugin/ui-functions.vim
" 
" Version:      2.2.1
" Created:      18th nov 2002
" Last Update:  28th Nov 2007
"------------------------------------------------------------------------
" Description:  Functions for the interaction with a User Interface.
"               The UI can be graphical or textual.
"               At first, this was designed to ease the syntax of
"               mu-template's templates.
"
" Option:       {{{2
"       {[bg]:ui_type} 
"               = "g\%[ui]", 
"               = "t\%[ext]" ; the call must not be |:silent|
"               = "f\%[te]"
" }}}2
"------------------------------------------------------------------------
" Installation: Drop this into one of your {rtp}/plugin/ directories.
" History:      {{{2
"    v0.01 Initial Version
"    v0.02
"       (*) Code "factorisations" 
"       (*) Help on <F1> enhanced.
"       (*) Small changes regarding the parameter accepted
"       (*) Function SWITCH
"    v0.03
"       (*) Small bug fix with INPUT()
"    v0.04
"       (*) New function: WHICH()
"    v0.05
"       (*) In vim7e, inputdialog() returns a trailing '\n'. INPUT() strips the
"           NL character.
"    v0.06
"       (*) :s/echoerr/throw/ => vim7 only
"    v2.2.0
"       (*) menu to switch the ui_type
" 
" TODO:         {{{2
"       (*) Save the hl-User1..9 before using them
"       (*) Possibility other than &statusline:
"           echohl User1 |echon "bla"|echohl User2|echon "bli"|echohl None
"       (*) Wraps too long choices-line (length > term-width)
"       (*) Add to the documentation: "don't use CTRL-C to abort !!"
"       (*) Look if I need to support 'wildmode'
"       (*) 3rd mode: return string for FTE
"       (*) 4th mode: interaction in a scratch buffer
"
" }}}1
"=============================================================================
" Avoid reinclusion {{{1
" 
if exists("g:loaded_ui_functions") && !exists('g:force_reload_ui_functions')
  finish 
endif
let g:loaded_ui_functions = 1
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" External functions {{{1
" Function: IF(var, then, else) {{{2
function! IF(var,then, else)
  let o = s:Opt_type() " {{{3
  if     o =~ 'g\%[ui]\|t\%[ext]' " {{{4
    return a:var ? a:then : a:else
  elseif o =~ 'f\%[te]'           " {{{4
    return s:if_fte(a:var, a:then, a:else)
  else                    " {{{4
    throw "UI-Fns::IF(): Unkonwn user-interface style (".o.")"
  endif
  " }}}3
endfunction

" Function: SWITCH(var, case, action [, case, action] [default_action]) {{{2
function! SWITCH(var, ...)
  let o = s:Opt_type() " {{{3
  if     o =~ 'g\%[ui]\|t\%[ext]' " {{{4
    let explicit_def = ((a:0 % 2) == 1)
    let default      = explicit_def ? a:{a:0} : ''
    let i = a:0 - 1 - explicit_def
    while i > 0
      if a:var == a:{i}
        return a:{i+1}
      endif
      let i = i - 2
    endwhile
    return default
  elseif o =~ 'f\%[te]'           " {{{4
    return s:if_fte(a:var, a:then, a:else)
  else                    " {{{4
    throw "UI-Fns::SWITCH(): Unkonwn user-interface style (".o.")"
  endif
  " }}}3
endfunction

" Function: CONFIRM(text [, choices [, default [, type]]]) {{{2
function! CONFIRM(text, ...)
  " 1- Check parameters {{{3
  if a:0 > 4 " {{{4
    throw "UI-Fns::CONFIRM(): too many parameters"
    return 0
  endif
  " build the parameters string {{{4
  let i = 1
  while i <= a:0
    if i == 1 | let params = 'a:{1}'
    else      | let params = params. ',a:{'.i.'}'
    endif
    let i = i + 1
  endwhile
  " 2- Choose the correct way to execute according to the option {{{3
  let o = s:Opt_type()
  if     o =~ 'g\%[ui]'  " {{{4
    exe 'return confirm(a:text,'.params.')'
  elseif o =~ 't\%[ext]' " {{{4
    if !has('gui_running') && has('dialog_con')
      exe 'return confirm(a:text,'.params.')'
    else
      exe 'return s:confirm_text("none", a:text,'.params.')'
    endif
  elseif o =~ 'f\%[te]'  " {{{4
      exe 'return s:confirm_fte(a:text,'.params.')'
  else               " {{{4
    throw "UI-Fns::CONFIRM(): Unkonwn user-interface style (".o.")"
  endif
  " }}}3
endfunction

" Function: INPUT(prompt [, default ]) {{{2
function! INPUT(prompt, ...)
  " 1- Check parameters {{{3
  if a:0 > 4 " {{{4
    throw "UI-Fns::INPUT(): too many parameters"
    return 0
  endif
  " build the parameters string {{{4
  let i = 1 | let params = ''
  while i <= a:0
    if i == 1 | let params = 'a:{1}'
    else      | let params = params. ',a:{'.i.'}'
    endif
    let i = i + 1
  endwhile
  " 2- Choose the correct way to execute according to the option {{{3
  let o = s:Opt_type()
  if     o =~ 'g\%[ui]'  " {{{4
    exe 'return matchstr(inputdialog(a:prompt,'.params.'), ".\\{-}\\ze\\n\\=$")'
  elseif o =~ 't\%[ext]' " {{{4
    exe 'return input(a:prompt,'.params.')'
  elseif o =~ 'f\%[te]'  " {{{4
      exe 'return s:input_fte(a:prompt,'.params.')'
  else               " {{{4
    throw "UI-Fns::INPUT(): Unkonwn user-interface style (".o.")"
  endif
  " }}}3
endfunction

" Function: COMBO(prompt, choice [, ... ]) {{{2
function! COMBO(prompt, ...)
  " 1- Check parameters {{{3
  if a:0 > 4 " {{{4
    throw "UI-Fns::COMBO(): too many parameters"
    return 0
  endif
  " build the parameters string {{{4
  let i = 1
  while i <= a:0
    if i == 1 | let params = 'a:{1}'
    else      | let params = params. ',a:{'.i.'}'
    endif
    let i = i + 1
  endwhile
  " 2- Choose the correct way to execute according to the option {{{3
  let o = s:Opt_type()
  if     o =~ 'g\%[ui]'  " {{{4
    exe 'return confirm(a:prompt,'.params.')'
  elseif o =~ 't\%[ext]' " {{{4
    exe 'return s:confirm_text("combo", a:prompt,'.params.')'
  elseif o =~ 'f\%[te]'  " {{{4
    exe 'return s:combo_fte(a:prompt,'.params.')'
  else               " {{{4
    throw "UI-Fns::COMBO(): Unkonwn user-interface style (".o.")"
  endif
  " }}}3
endfunction

" Function: WHICH(function, prompt, choice [, ... ]) {{{2
function! WHICH(fn, prompt, ...)
  " 1- Check parameters {{{3
  " build the parameters string {{{4
  let i = 1
  while i <= a:0
    if i == 1 | let params = 'a:{1}'
    else      | let params = params. ',a:{'.i.'}'
    endif
    let i = i + 1
  endwhile
  " 2- Execute the function {{{3
  exe 'let which = '.a:fn.'(a:prompt,'.params.')'
  if     0 >= which | return ''
  elseif 1 == which
    return substitute(matchstr(a:{1}, '^.\{-}\ze\%(\n\|$\)'), '&', '', 'g')
  else
    return substitute(
          \ matchstr(a:{1}, '^\%(.\{-}\n\)\{'.(which-1).'}\zs.\{-}\ze\%(\n\|$\)')
          \ , '&', '', 'g')
  endif
  " }}}3
endfunction

" Function: CHECK(prompt, choice [, ... ]) {{{2
function! CHECK(prompt, ...)
  " 1- Check parameters {{{3
  if a:0 > 4 " {{{4
    throw "UI-Fns::CHECK(): too many parameters"
    return 0
  endif
  " build the parameters string {{{4
  let i = 1
  while i <= a:0
    if i == 1 | let params = 'a:{1}'
    else      | let params = params. ',a:{'.i.'}'
    endif
    let i = i + 1
  endwhile
  " 2- Choose the correct way to execute according to the option {{{3
  let o = s:Opt_type()
  if     o =~ 'g\%[ui]'  " {{{4
    exe 'return s:confirm_text("check", a:prompt,'.params.')'
  elseif o =~ 't\%[ext]' " {{{4
    exe 'return s:confirm_text("check", a:prompt,'.params.')'
  elseif o =~ 'f\%[te]'  " {{{4
      exe 'return s:check_fte(a:prompt,'.params.')'
  else               " {{{4
    throw "UI-Fns::CHECK(): Unkonwn user-interface style (".o.")"
  endif
  " }}}3
endfunction

" }}}1
"------------------------------------------------------------------------
" Options setting {{{1
let s:OptionData = {
      \ "variable": "ui_type",
      \ "idx_crt_value": 1,
      \ "values": ['gui', 'text', 'fte'],
      \ "menu": { "priority": '500.2700', "name": '&Plugin.&LH.&UI type'}
      \}

call lh#menu#def_toggle_item(s:OptionData)

" }}}1
"------------------------------------------------------------------------
" Internal functions {{{1
function! s:Option(name, default) " {{{2
  if     exists('b:ui_'.a:name) | return b:ui_{a:name}
  elseif exists('g:ui_'.a:name) | return g:ui_{a:name}
  else                          | return a:default
  endif
endfunction


function! s:Opt_type() " {{{2
  return s:Option('type', 'gui')
endfunction

"
" Function: s:status_line(current, hl [, choices] ) {{{2
"     a:current: current item
"     a:hl     : Generic, Warning, Error
function! s:status_line(current, hl, ...)
  " Highlightning {{{3
  if     a:hl == "Generic"  | let hl = '%1*'
  elseif a:hl == "Warning"  | let hl = '%2*'
  elseif a:hl == "Error"    | let hl = '%3*'
  elseif a:hl == "Info"     | let hl = '%4*'
  elseif a:hl == "Question" | let hl = '%5*'
  else                      | let hl = '%1*'
  endif
  
  " Build the string {{{3
  let sl_choices = '' | let i = 1
  while i <= a:0
    if i == a:current
      let sl_choices = sl_choices . ' '. hl . 
            \ substitute(a:{i}, '&\(.\)', '%6*\1'.hl, '') . '%* '
    else
      let sl_choices = sl_choices . ' ' . 
            \ substitute(a:{i}, '&\(.\)', '%6*\1%*', '') . ' '
    endif
    let i = i + 1
  endwhile
  " }}}3
  return sl_choices
endfunction


" Function: s:confirm_text(box, text [, choices [, default [, type]]]) {{{2
function! s:confirm_text(box, text, ...)
  let help = "/<esc>/<s-tab>/<tab>/<left>/<right>/<cr>/<F1>"
  " 1- Retrieve the parameters       {{{3
  let choices = ((a:0>=1) ? a:1 : '&Ok')
  let default = ((a:0>=2) ? a:2 : (('check' == a:box) ? 0 : 1))
  let type    = ((a:0>=3) ? a:3 : 'Generic')
  if     'none'  == a:box | let prefix = ''
  elseif 'combo' == a:box | let prefix = '( )_'
  elseif 'check' == a:box | let prefix = '[ ]_'
    let help = '/ '.help
  else                    | let prefix = ''
  endif


  " 2- Retrieve the proposed choices {{{3
  " Prepare the hot keys
  let i = 0
  while i != 26
    let hotkey_{nr2char(i+65)} = 0
    let i += 1
  endwhile
  let hotkeys = '' | let help_k = '/'
  " Parse the choices
  let i = 0
  while choices != ""
    let i = i + 1
    let item    = matchstr(choices, "^.\\{-}\\ze\\(\n\\|$\\)")
    let choices = matchstr(choices, "\n\\zs.*$")
    " exe 'anoremenu ]'.a:text.'.'.item.' :let s:choice ='.i.'<cr>'
    if ('check' == a:box) && (strlen(default)>=i) && (1 == default[i-1])
      " let choice_{i} = '[X]' . substitute(item, '&', '', '')
      let choice_{i} = '[X]_' . item
    else
      " let choice_{i} = prefix . substitute(item, '&', '', '')
      let choice_{i} = prefix . item
    endif
    if i == 1
      let list_choices = 'choice_{1}'
    else
      let list_choices = list_choices . ',choice_{'.i.'}'
    endif
    " Update the hotkey.
    let key = toupper(matchstr(choice_{i}, '&\zs.\ze'))
    let hotkey_{key} = i
    let hotkeys = hotkeys . tolower(key) . toupper(key)
    let help_k = help_k . tolower(key)
  endwhile
  let nb_choices = i
  if default > nb_choices | let default = nb_choices | endif

  " 3- Run an interactive text menu  {{{3
  " Note: emenu can not be used through ":exe" {{{4
  " let wcm = &wcm
  " set wcm=<tab>
  " exe ':emenu ]'.a:text.'.'."<tab>"
  " let &wcm = wcm
  " 3.1- Preparations for the statusline {{{4
  " save the statusline
  let sl = &l:statusline
  " Color schemes for selected item {{{5
  :hi User1 term=inverse,bold cterm=inverse,bold ctermfg=Yellow 
        \ guifg=Black guibg=Yellow
  :hi User2 term=inverse,bold cterm=inverse,bold ctermfg=LightRed
        \ guifg=Black guibg=LightRed
  :hi User3 term=inverse,bold cterm=inverse,bold ctermfg=Red 
        \ guifg=Black guibg=Red
  :hi User4 term=inverse,bold cterm=inverse,bold ctermfg=Cyan
        \ guifg=Black guibg=Cyan
  :hi User5 term=inverse,bold cterm=inverse,bold ctermfg=LightYellow
        \ guifg=Black guibg=LightYellow
  :hi User6 term=inverse,bold cterm=inverse,bold ctermfg=LightGray
        \ guifg=DarkRed guibg=LightGray
  " }}}5

  " 3.2- Interactive loop                {{{4
  let help =  "\r-- Keys available (".help_k.help.")"
  " item selected at the start
  let i = ('check' != a:box) ? default : 1
  let direction = 0 | let toggle = 0
  while 1
    if 'combo' == a:box
      let choice_{i} = substitute(choice_{i}, '^( )', '(*)', '')
    endif
    " Colored statusline
    " Note: unfortunately the 'statusline' is a global option, {{{
    " not a local one. I the hope that may change, as it does not provokes any
    " error, I use '&l:statusline'. }}}
    exe 'let &l:statusline=s:status_line(i, type,'. list_choices .')'
    if has(':redrawstatus')
      redrawstatus!
    else
      redraw!
    endif
    " Echo the current selection
    echo "\r". a:text.' '.substitute(choice_{i}, '&', '', '')
    " Wait the user to hit a key
    let key=getchar()
    let complType=nr2char(key)
    " If the key hit matched awaited keys ...
    if -1 != stridx(" \<tab>\<esc>\<enter>".hotkeys,complType) ||
          \ (key =~ "\<F1>\\|\<right>\\|\<left>\\|\<s-tab>")
      if key           == "\<F1>"                       " Help      {{{5
        redraw!
        echohl StatusLineNC
        echo help
        echohl None
        let key=getchar()
        let complType=nr2char(key)
      endif
      " TODO: support CTRL-D
      if     complType == "\<enter>"                    " Validate  {{{5
        break
      elseif complType == " "                           " check box {{{5
        let toggle = 1
      elseif complType == "\<esc>"                      " Abort     {{{5
        let i = -1 | break
      elseif complType == "\<tab>" || key == "\<right>" " Next      {{{5
        let direction = 1
      elseif key =~ "\<left>\\|\<s-tab>"                " Previous  {{{5
        let direction = -1
      elseif -1 != stridx(hotkeys, complType )          " Hotkeys     {{{5
        if '' == complType  | continue | endif
        let direction = hotkey_{toupper(complType)} - i
        let toggle = 1
      " else
      endif
      " }}}5
    endif
    if direction != 0 " {{{5
      if 'combo' == a:box
        let choice_{i} = substitute(choice_{i}, '^(\*)', '( )', '')
      endif
      let i = i + direction
      if     i > nb_choices | let i = 1 
      elseif i == 0         | let i = nb_choices
      endif
      let direction = 0
    endif
    if toggle == 1    " {{{5
      if 'check' == a:box
        let choice_{i} = ((choice_{i}[1] == ' ')? '[X]' : '[ ]') 
              \ . strpart(choice_{i}, 3)
      endif
      let toggle = 0
    endif
  endwhile " }}}4
  " 4- Terminate                     {{{3
  " Clear screen
  redraw!

  " Restore statusline
  let &l:statusline=sl
  " Return
  if (i == -1) || ('check' != a:box)
    return i
  else
    let r = '' | let i = 1
    while i <= nb_choices
      let r = r . ((choice_{i}[1] == 'X') ? '1' : '0')
      let i = i + 1
    endwhile
    return r
  endif
endfunction
" }}}1
"------------------------------------------------------------------------
" Functions that insert fte statements {{{1
" Function: s:if_fte(var, then, else) {{{2
" Function: s:confirm_fte(text, [, choices [, default [, type]]]) {{{2
" Function: s:input_fte(prompt [, default]) {{{2
" Function: s:combo_fte(prompt, choice [, ...]) {{{2
" Function: s:check_fte(prompt, choice [, ...]) {{{2
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
plugin/words_tools.vim	[[[1
104
" File:		plugin/words_tools.vim
" Author:	Luc Hermitte <hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" URL: http://hermitte.free.fr/vim/ressources/vim_dollar/plugin/words_tools.vim
"
" Last Update:	14th nov 2002
" Purpose:	Define functions better than expand("<cword>")
"
" Note:		They are expected to be used in insert mode (thanks to <c-r>
"               or <c-o>)
"
"===========================================================================

" Return the current keyword, uses spaces to delimitate {{{1
function! GetNearestKeyword()
  let c = col ('.')-1
  let ll = getline('.')
  let ll1 = strpart(ll,0,c)
  let ll1 = matchstr(ll1,'\k*$')
  let ll2 = strpart(ll,c,strlen(ll)-c+1)
  let ll2 = matchstr(ll2,'^\k*')
  " let ll2 = strpart(ll2,0,match(ll2,'$\|\s'))
  return ll1.ll2
endfunction

" Return the current word, uses spaces to delimitate {{{1
function! GetNearestWord()
  let c = col ('.')-1
  let l = line('.')
  let ll = getline(l)
  let ll1 = strpart(ll,0,c)
  let ll1 = matchstr(ll1,'\S*$')
  let ll2 = strpart(ll,c,strlen(ll)-c+1)
  let ll2 = strpart(ll2,0,match(ll2,'$\|\s'))
  ""echo ll1.ll2
  return ll1.ll2
endfunction

" Return the word before the cursor, uses spaces to delimitate {{{1
" Rem : <cword> is the word under or after the cursor
function! GetCurrentWord()
  let c = col ('.')-1
  let l = line('.')
  let ll = getline(l)
  let ll1 = strpart(ll,0,c)
  let ll1 = matchstr(ll1,'\S*$')
  if strlen(ll1) == 0
    return ll1
  else
    let ll2 = strpart(ll,c,strlen(ll)-c+1)
    let ll2 = strpart(ll2,0,match(ll2,'$\|\s'))
    return ll1.ll2
  endif
endfunction

" Return the keyword before the cursor, uses \k to delimitate {{{1
" Rem : <cword> is the word under or after the cursor
function! GetCurrentKeyword()
  let c = col ('.')-1
  let l = line('.')
  let ll = getline(l)
  let ll1 = strpart(ll,0,c)
  let ll1 = matchstr(ll1,'\k*$')
  if strlen(ll1) == 0
    return ll1
  else
    let ll2 = strpart(ll,c,strlen(ll)-c+1)
    let ll2 = matchstr(ll2,'^\k*')
    " let ll2 = strpart(ll2,0,match(ll2,'$\|\s'))
    return ll1.ll2
  endif
endfunction

" Extract the word before the cursor,  {{{1
" use keyword definitions, skip latter spaces (see "bla word_accepted ")
function! GetPreviousWord()
  let lig = getline(line('.'))
  let lig = strpart(lig,0,col('.')-1)
  return matchstr(lig, '\<\k*\>\s*$')
endfunction

" GetLikeCTRL_W() retrieves the characters that i_CTRL-W deletes. {{{1
" Initial need by Hari Krishna Dara <hari_vim@yahoo.com>
" Last ver:
" Pb: "if strlen(w) ==  " --> ") ==  " instead of just "==  ".
" There still exists a bug regarding the last char of a line. VIM bug ?
function! GetLikeCTRL_W()
  let lig = getline(line('.'))
  let lig = strpart(lig,0,col('.')-1)
  " treat ending spaces apart.
  let s = matchstr(lig, '\s*$')
  let lig = strpart(lig, 0, strlen(lig)-strlen(s))
  " First case : last characters belong to a "word"
  let w = matchstr(lig, '\<\k\+\>$')
  if strlen(w) == 0
    " otherwise, they belong to a "non word" (without any space)
    let w = substitute(lig, '.*\(\k\|\s\)', '', 'g')
  endif
  return w . s
endfunction

" }}}1
"========================================================================
" vim60: set fdm=marker:
tests/lh/function.vim	[[[1
284
"=============================================================================
" $Id: function.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		tests/lh/function.vim                                   {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	03rd Nov 2008
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	
" 	Tests for autoload/lh/function.vim
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

UTSuite [lh-vim-lib] Testing lh#function plugin

runtime autoload/lh/function.vim

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
function! Test(...)
  let nb = len(a:000)
  " echo "test(".nb.':' .join(a:000, ' -- ')')'
  let i =0
  while i!= len(a:000)
    echo "Test: type(".i.")=".type(a:000[i]).' --> '. string(a:000[i])
    let i += 1
  endwhile
endfunction

function! Print(...)
  let res = lh#list#accumulate([1,2,'foo'], 'string', 'join(v:1_, " ## ")')
  return res
endfunction

function! Id(...)
  return copy(a:000)
endfunction

function! s:TestId()
  let r = Id(1, 'string', [0], [[1]], {'ffo':42}, function('exists'), 1.2)
  Assert! len(r) == 7
  Assert! should#be#number (r[0])
  Assert! should#be#string (r[1])
  Assert! should#be#list   (r[2])
  Assert! should#be#list   (r[3])
  Assert! should#be#dict   (r[4])
  Assert! should#be#funcref(r[5])
  Assert! should#be#float  (r[6])
  Assert r[0] == 1
  Assert r[1] == 'string'
  Assert r[2] == [0]
  Assert r[3] == [[1]]
  Assert r[4].ffo == 42
  Assert r[5] == function('exists')
  Assert r[6] == 1.2
endfunction

function! s:Test_bind()
  " lh#function#bind + lh#function#execute
  let rev4 = lh#function#bind(function('Id'), 'v:4_', 42, 'v:3_', 'v:2_', 'v:1_')
  let r = lh#function#execute(rev4, 1,'two','three', [4,5])
  Assert! len(r) == 5
  Assert! should#be#list   (r[0])
  Assert! should#be#number (r[1])
  Assert! should#be#string (r[2])
  Assert! should#be#string (r[3])
  Assert! should#be#number (r[4])

  Assert r[0] == [4,5]
  Assert r[1] == 42
  Assert r[2] == 'three'
  Assert r[3] == 'two'
  Assert r[4] == 1
endfunction

function! s:Test_bind_compound_vars()
  " lh#function#bind + lh#function#execute
  let rev4 = lh#function#bind(function('Id'), 'v:4_', 'v:1_ . v:2_', 'v:3_', 'v:2_', 'v:1_')
  let r = lh#function#execute(rev4, 1,'two','three', [4,5])
  Assert! len(r) == 5
  Assert! should#be#list   (r[0])
  Assert! should#be#string (r[1])
  Assert! should#be#string (r[2])
  Assert! should#be#string (r[3])
  Assert! should#be#number (r[4])

  Assert r[0] == [4,5]
  Assert r[1] == '1two'
  Assert r[2] == 'three'
  Assert r[3] == 'two'
  Assert r[4] == 1
endfunction


function! s:Test_execute_func_string_name()
  " function name as string
  let r = lh#function#execute('Id', 1,'two',3)
  Assert! len(r) == 3
  Assert! should#be#number (r[0])
  Assert! should#be#string (r[1])
  Assert! should#be#number (r[2])
  Assert r[0] == 1
  Assert r[1] == 'two'
  Assert r[2] == 3
endfunction

function! s:Test_execute_string_expr()
  " exp as binded-string
  let r = lh#function#execute('Id(12,len(v:2_).v:2_, 42, v:3_, v:1_)', 1,'two',3)
  Assert! len(r) == 5
  Assert! should#be#number (r[0])
  Assert! should#be#string (r[1])
  Assert! should#be#number (r[2])
  Assert! should#be#number (r[3])
  Assert! should#be#number (r[4])
  Assert r[0] == 12
  Assert r[1] == len('two').'two'
  Assert r[2] == 42
  Assert r[3] == 3
  Assert r[4] == 1
endfunction

function! s:Test_execute_func()
  " calling a function() + bind
  let r = lh#function#execute(function('Id'), 1,'two','v:1_',['a',42])
  Assert! len(r) == 4
  Assert! should#be#number (r[0])
  Assert! should#be#string (r[1])
  Assert! should#be#string (r[2])
  Assert! should#be#list   (r[3])
  Assert r[0] == 1
  Assert r[1] == 'two'
  Assert r[2] == 'v:1_'
  Assert r[3] == ['a', 42]
endfunction
"------------------------------------------------------------------------
function! s:Test_bind_func_string_name_AND_execute()
  " function name as string
  let rev3 = lh#function#bind('Id', 'v:3_', 12, 'v:2_', 'v:1_')
  let r = lh#function#execute(rev3, 1,'two',3)

  Assert! len(r) == 4
  Assert! should#be#number (r[0])
  Assert! should#be#number (r[1])
  Assert! should#be#string (r[2])
  Assert! should#be#number (r[3])
  Assert r[0] == 3
  Assert r[1] == 12
  Assert r[2] == 'two'
  Assert r[3] == 1
endfunction

function! s:Test_bind_string_expr_AND_execute()
" expressions as string
  let rev3 = lh#function#bind('Id(12,len(v:2_).v:2_, 42, v:3_, v:1_)')
  let r = lh#function#execute(rev3, 1,'two',3)
  Assert! len(r) == 5
  Assert! should#be#number (r[0])
  Assert! should#be#string (r[1])
  Assert! should#be#number (r[2])
  Assert! should#be#number (r[3])
  Assert! should#be#number (r[4])
  Assert r[0] == 12
  Assert r[1] == len('two').'two'
  Assert r[2] == 42
  Assert r[3] == 3
  Assert r[4] == 1
endfunction

function! s:Test_double_bind_func_name()
  let f1 = lh#function#bind('Id', 1, 2, 'v:1_', 4, 'v:2_')
  " Comment "f1=".string(f1)
  let r = lh#function#execute(f1, 3, 5)
  Assert! len(r) == 5
  let i = 0
  while i != len(r)
    Assert! should#be#number (r[i])
    Assert r[i] == i+1
    let i += 1
  endwhile

  " f2
  let f2 = lh#function#bind(f1, 'v:1_', 5)
  " Comment "f2=f1(v:1_, 5)=".string(f2)
  let r = lh#function#execute(f2, 3)
  Assert! len(r) == 5
  let i = 0
  while i != len(r)
    Assert! should#be#number (r[i])
    " echo "?? ".(r[i])."==".(i+1)
    Assert r[i] == i+1
    let i += 1
  endwhile
endfunction

function! s:Test_double_bind_func()
  let f1 = lh#function#bind(function('Id'), 1, 2, 'v:1_', 4, 'v:2_')
  " Comment "f1=".string(f1)
  let r = lh#function#execute(f1, 3, 5)
  Assert! len(r) == 5
  let i = 0
  while i != len(r)
    Assert! should#be#number (r[i])
    Assert r[i] == i+1
    let i += 1
  endwhile

  " f2
  let f2 = lh#function#bind(f1, 'v:1_', 5)
  " Comment "f2=f1(v:1_, 5)=".string(f2)
  let r = lh#function#execute(f2, 3)
  Assert! len(r) == 5
  let i = 0
  while i != len(r)
    Assert! should#be#number (r[i])
    Assert r[i] == i+1
    let i += 1
  endwhile
endfunction

function! s:Test_double_bind_func_cplx()
  let s:bar = "bar"
  let f1 = lh#function#bind(function('Id'), 1, 2, 'v:1_', 4, 'v:2_', 'v:3_', 'v:4_', 'v:5_', 'v:6_', 'v:7_')
  " Comment "f1=".string(f1)
  let f2 = lh#function#bind(f1, 'v:1_', 5, 'foo', s:bar, 'len(s:bar.v:1_)+v:1_', [1,2], '[v:1_, v:2_]')
  " Comment "f2=f1(v:1_, 5)=".string(f2)

  let r = lh#function#execute(f2, 42, "foo")
  Assert! 0 && "not ready"
  Comment "2bcpl# ".string(r)
endfunction

function! s:Test_double_bind_expr()
  let f1 = lh#function#bind('Id(1, 2, v:1_, v:3_, v:2_)')
  Comment "2be# f1=".string(f1)
  let r = lh#function#execute(f1, 3, 5, 4)
  Comment "2be# ".string(r)
  Assert! len(r) == 5
  let i = 0
  while i != len(r)
    Assert! should#be#number (r[i])
    Assert r[i] == i+1
    let i += 1
  endwhile

  " f2
  let f2 = lh#function#bind(f1, 'v:1_', '"foo"', [])
  Comment "2be# f2=f1(v:1_, 5)=".string(f2)
  let r = lh#function#execute(f2, 3)
  Comment "2be# ".string(r)
  Assert! len(r) == 5
  let i = 0
  while i != len(r)-2
    Assert! should#be#number (r[i])
    Assert r[i] == i+1
    let i += 1
  endwhile

  Assert! should#be#list (r[-2])
  Assert r[-2] == []
  Assert! should#be#string (r[-1])
  Assert r[-1] == 'foo'
endfunction

"todo: write double-binded tests for all kind of binded parameters:
" 'len(g:bar)'
" 42
" []
" v:1_ + len(v:2_.v:3_)
" '"foo"'
" v:1_

"------------------------------------------------------------------------

let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
tests/lh/list.vim	[[[1
165
"=============================================================================
" $Id: list.vim 238 2010-06-01 00:47:16Z luc.hermitte $
" File:		tests/lh/list.vim                                      {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	19th Nov 2008
" Last Update:	$Date: 2010-06-01 02:47:16 +0200 (mar., 01 juin 2010) $
"------------------------------------------------------------------------
" Description:	
" 	Tests for autoload/lh/list.vim
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

UTSuite [lh-vim-lib] Testing lh#list functions

runtime autoload/lh/function.vim
runtime autoload/lh/list.vim
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" Find_if
function! s:Test_Find_If_string_predicate()
    :let b = { 'min': 12, 'max': 42 }
    :let l = [ 1, 5, 48, 25, 5, 28, 6]
    :let i = lh#list#Find_if(l, 'v:val>v:1_.min  && v:val<v:1_.max && v:val%v:2_==0', [b, 2] )
    " echo i . '/' . len(l)
    Assert i == 5
    Assert l[i] == 28
    " :echo l[i]
endfunction

function! s:Test_Find_If_functor_predicate()
    :let l = [ 1, 5, 48, 25, 5, 28, 6]
    :let i = lh#list#find_if(l, 'v:1_>12  && v:1_<42 && v:1_%2==0')
    " echo i . '/' . len(l)
    Assert i == 5
    Assert l[i] == 28
    " :echo l[i]
endfunction

function! s:Test_find_if_double_bind()
    :let b = { 'min': 12, 'max': 42 }
    :let l = [ 1, 5, 48, 25, 5, 28, 6]
    :let f = lh#function#bind( 'v:3_>v:1_.min  && v:3_<v:1_.max && v:3_%v:2_==0') 
    :let p = lh#function#bind(f, b,2,'v:1_') 
    :let i = lh#list#find_if(l, p)
    :echo l[i]
endfunction
" double bind is not yet operational
UTIgnore Test_find_if_double_bind

"------------------------------------------------------------------------
" Unique Sorting
function! CmpNumbers(lhs, rhs)
  if     a:lhs < a:rhs  | return -1
  elseif a:lhs == a:rhs | return 0
  else              | return +1
  endif
endfunction

function! s:Test_sort()
    :let l = [ 1, 5, 48, 25, 5, 28, 6]
    :let expected = [ 1, 5, 6, 25, 28, 48]
    :let s = lh#list#unique_sort(l, "CmpNumbers") 
    " Comment string(s)
    Assert s == expected
endfunction

function! s:Test_sort2()
    :let l = [ 1, 5, 48, 25, 5, 28, 6]
    :let expected = [ 1, 5, 6, 25, 28, 48]
    :let s = lh#list#unique_sort2(l, "CmpNumbers") 
    " Comment string(s)
    Assert s == expected
endfunction

"------------------------------------------------------------------------
" Searchs
function! s:TestBinarySearches()
  let v1 = [ -3, -2, -1, -1, 0, 0, 1, 2, 3, 4, 6 ]
  let i = lh#list#lower_bound(v1, 3)
  Assert v1[i] == 3
  let i = lh#list#upper_bound(v1, 3)
  Assert v1[i] == 4
  let r = lh#list#equal_range(v1, 3)
  Assert v1[r[0]:r[1]-1] == [3]

  let i = lh#list#lower_bound(v1, -1)
  Assert v1[i] == -1
  let i = lh#list#upper_bound(v1, -1)
  Assert v1[i] == 0
  let r = lh#list#equal_range(v1, -1)
  Assert v1[r[0]:r[1]-1] == [-1, -1]

  let i = lh#list#lower_bound(v1, 5)
  Assert v1[i] == 6
  let i = lh#list#upper_bound(v1, 5)
  Assert v1[i] == 6
  let r = lh#list#equal_range(v1, 5)
  Assert v1[r[0]:r[1]-1] == []

  Assert len(v1) == lh#list#lower_bound(v1, 10)
  Assert len(v1) == lh#list#upper_bound(v1, 10)
  Assert [len(v1), len(v1)] == lh#list#equal_range(v1, 10)
endfunction

"------------------------------------------------------------------------
" accumulate

function! s:Test_accumulate_len_strings()
  let strings = [ 'foo', 'bar', 'toto' ]
  let len = eval(lh#list#accumulate(strings, 'strlen', 'join(v:1_,  "+")'))
  Assert len == 3+3+4
endfunction

function! s:Test_accumulate_join()
  let ll = [ 1, 2, 'foo', ['bar'] ]
  let res = lh#list#accumulate(ll, 'string', 'join(v:1_,  " ## ")')
  Assert res == "1 ## 2 ## 'foo' ## ['bar']"
  " This test will fail because it seems :for each loop cannot iterate on
  " heterogeneous containers
endfunction

"------------------------------------------------------------------------
" Copy_if
function! s:Test_copy_if()
    :let l = [ 1, 25, 5, 48, 25, 5, 28, 6]
    :let expected = [ 25, 48, 25, 28, 6]
    :let s = lh#list#copy_if(l, [], "v:1_ > 5") 
    " Comment string(s)
    Assert s == expected
endfunction

"------------------------------------------------------------------------
" subset
function! s:Test_subset()
    :let l = [ 1, 25, 5, 48, 25, 5, 28, 6]
    :let indices = [ 0, 5, 7, 3 ]
    :let expected = [ 1, 5, 6, 48 ]
    :let s = lh#list#subset(l, indices) 
    " Comment string(s)
    Assert s == expected
endfunction

"------------------------------------------------------------------------
" intersect
function! s:Test_intersect()
    :let l1 = [ 1, 25, 7, 48, 26, 5, 28, 6]
    :let l2 = [ 3, 8, 7, 25, 6 ]
    :let expected = [ 25, 7, 6 ]
    :let s = lh#list#intersect(l1, l2) 
    " Comment string(s)
    Assert s == expected
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
tests/lh/path.vim	[[[1
173
"=============================================================================
" $Id: path.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		tests/lh/path.vim                                      {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	28th May 2009
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:
" 	Tests for autoload/lh/path.vim
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

UTSuite [lh-vim-lib] Testing lh#path functions

runtime autoload/lh/path.vim
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
function! s:Test_simplify()
  Assert lh#path#simplify('a/b/c') == 'a/b/c'
  Assert lh#path#simplify('a/b/./c') == 'a/b/c'
  Assert lh#path#simplify('./a/b/./c') == 'a/b/c'
  Assert lh#path#simplify('./a/../b/./c') == 'b/c'
  Assert lh#path#simplify('../a/../b/./c') == '../b/c'
  Assert lh#path#simplify('a\b\c') == 'a\b\c'
  Assert lh#path#simplify('a\b\.\c') == 'a\b\c'
  Assert lh#path#simplify('.\a\b\.\c') == 'a\b\c'
  if exists('+shellslash')
    Assert lh#path#simplify('.\a\..\b\.\c') == 'b\c'
    Assert lh#path#simplify('..\a\..\b\.\c') == '..\b\c'
  endif
endfunction

function! s:Test_strip_common()
  let paths = ['foo/bar/file', 'foo/file', 'foo/foo/file']
  let expected = [ 'bar/file', 'file', 'foo/file']
  Assert lh#path#strip_common(paths) == expected
endfunction

function! s:Test_common()
  Assert 'foo/' == lh#path#common(['foo/bar/dir', 'foo'])
  Assert 'foo/bar/' == lh#path#common(['foo/bar/dir', 'foo/bar'])
  Assert 'foo/' == lh#path#common(['foo/bar/dir', 'foo/bar2'])
endfunction

function! s:Test_strip_start()
  let expected = 'template/bar.template'
  Assert lh#path#strip_start($HOME.'/.vim/template/bar.template',
	\ [ $HOME.'/.vim', $HOME.'/vimfiles', '/usr/local/share/vim' ]) 
	\ == expected

  Assert lh#path#strip_start($HOME.'/vimfiles/template/bar.template',
	\ [ $HOME.'/.vim', $HOME.'/vimfiles', '/usr/local/share/vim' ]) 
	\ == expected

  Assert lh#path#strip_start('/usr/local/share/vim/template/bar.template',
	\ [ $HOME.'/.vim', $HOME.'/vimfiles', '/usr/local/share/vim' ]) 
	\ == expected
endfunction

function! s:Test_IsAbsolutePath()
  " nix paths
  Assert lh#path#is_absolute_path('/usr/local')
  Assert lh#path#is_absolute_path($HOME)
  Assert ! lh#path#is_absolute_path('./usr/local')
  Assert ! lh#path#is_absolute_path('.usr/local')

  " windows paths
  Assert lh#path#is_absolute_path('e:\usr\local')
  Assert ! lh#path#is_absolute_path('.\usr\local')
  Assert ! lh#path#is_absolute_path('.usr\local')

  " UNC paths
  Assert lh#path#is_absolute_path('\\usr\local')
  Assert lh#path#is_absolute_path('//usr/local')
endfunction

function! s:Test_IsURL()
  " nix paths
  Assert ! lh#path#is_url('/usr/local')
  Assert ! lh#path#is_url($HOME)
  Assert ! lh#path#is_url('./usr/local')
  Assert ! lh#path#is_url('.usr/local')

  " windows paths
  Assert ! lh#path#is_url('e:\usr\local')
  Assert ! lh#path#is_url('.\usr\local')
  Assert ! lh#path#is_url('.usr\local')

  " UNC paths
  Assert ! lh#path#is_url('\\usr\local')
  Assert ! lh#path#is_url('//usr/local')

  " URLs
  Assert lh#path#is_url('http://www.usr/local')
  Assert lh#path#is_url('https://www.usr/local')
  Assert lh#path#is_url('ftp://www.usr/local')
  Assert lh#path#is_url('sftp://www.usr/local')
  Assert lh#path#is_url('dav://www.usr/local')
  Assert lh#path#is_url('fetch://www.usr/local')
  Assert lh#path#is_url('file://www.usr/local')
  Assert lh#path#is_url('rcp://www.usr/local')
  Assert lh#path#is_url('rsynch://www.usr/local')
  Assert lh#path#is_url('scp://www.usr/local')
endfunction

function! s:Test_ToRelative()
  let pwd = getcwd()
  Assert lh#path#to_relative(pwd.'/foo/bar') == 'foo/bar'
  Assert lh#path#to_relative(pwd.'/./foo') == 'foo'
  Assert lh#path#to_relative(pwd.'/foo/../bar') == 'bar'

  " Does not work yet as it returns an absolute path it that case
  Assert lh#path#to_relative(pwd.'/../bar') == '../bar'
endfunction

function! s:Test_relative_path()
  Assert lh#path#relative_to('foo/bar/dir', 'foo') == '../../'
  Assert lh#path#relative_to('foo', 'foo/bar/dir') == 'bar/dir/'
  Assert lh#path#relative_to('foo/bar', 'foo/bar2/dir') == '../bar2/dir/'

  let pwd = getcwd()
  Assert lh#path#relative_to(pwd ,pwd.'/../bar') == '../bar/'
endfunction

function! s:Test_search_vimfiles()
  let expected_win = $HOME . '/vimfiles'
  let expected_nix = $HOME . '/.vim'
  let what =  lh#path#to_regex($HOME.'/').'\(vimfiles\|.vim\)'
  " Comment what
  let z = lh#path#find(&rtp,what)
  if has('win16')||has('win32')||has('win64')
    Assert z == expected_win
  else
    Assert z == expected_nix
  endif
endfunction

function! s:Test_path_depth()
  Assert 0 == lh#path#depth('.')
  Assert 0 == lh#path#depth('./')
  Assert 0 == lh#path#depth('.\')
  Assert 1 == lh#path#depth('toto')
  Assert 1 == lh#path#depth('toto/')
  Assert 1 == lh#path#depth('toto\')
  Assert 1 == lh#path#depth('toto/.')
  Assert 1 == lh#path#depth('toto\.')
  Assert 1 == lh#path#depth('toto/./.')
  Assert 1 == lh#path#depth('toto\.\.')
  Assert 0 == lh#path#depth('toto/..')
  if exists('+shellslash')
    Assert 0 == lh#path#depth('toto\..')
  endif
  Assert 2 == lh#path#depth('toto/titi/')
  Assert 2 == lh#path#depth('toto\titi\')
  Assert 2 == lh#path#depth('/toto/titi/')
  Assert 2 == lh#path#depth('c:/toto/titi/')
  Assert 2 == lh#path#depth('c:\toto/titi/')
" todo: make a choice about "negative" paths like "../../foo"
  Assert -1 == lh#path#depth('../../foo')
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
tests/lh/test-Fargs2String.vim	[[[1
83
"=============================================================================
" $Id: test-Fargs2String.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		tests/lh/test-Fargs2String.vim                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	16th Apr 2007
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	Tests for lh-vim-lib . lh#command#Fargs2String
" 
"------------------------------------------------------------------------
" Installation:	
" 	Relies on the version «patched by myself|1?» of vim_units
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

function! s:TestEmpty()
  let empty = []
  let res = lh#command#Fargs2String(empty)
  call VUAssertEquals(len(empty), 0, 'Expected empty', 22)
  call VUAssertEquals(res, '', 'Expected empty result', 23)
endfunction

function! s:TestSimpleText1()
  let expected = 'text'
  let one = [ expected ]
  let res = lh#command#Fargs2String(one)
  call VUAssertEquals(len(one), 0, 'Expected empty', 27)
  call VUAssertEquals(res, expected, 'Expected a simple result', 28)
endfunction

function! s:TestSimpleTextN()
  let expected = 'text'
  let list = [ expected , 'stuff1', 'stuff2']
  let res = lh#command#Fargs2String(list)
  call VUAssertEquals(len(list), 2, 'Expected not empty', 38)
  call VUAssertEquals(res, expected, 'Expected a simple result', 39)
endfunction

function! s:TestComposedN()
  let expected = '"a several tokens string"'
  let list = [ '"a', 'several', 'tokens', 'string"', 'stuff1', 'stuff2']
  let res = lh#command#Fargs2String(list)
  call VUAssertEquals(len(list), 2, 'Expected not empty', 46)
  call VUAssertEquals(res, expected, 'Expected a composed string', 47)
  call VUAssertEquals(list, ['stuff1', 'stuff2'], 'Expected a list', 48)
  call VUAssertNotSame(list, ['stuff1', 'stuff2'], 'Expected different lists', 49)
endfunction

function! s:TestComposed1()
  let expected = '"string"'
  let list = [ '"string"', 'stuff1', 'stuff2']
  let res = lh#command#Fargs2String(list)
  call VUAssertEquals(len(list), 2, 'Expected not empty', 56)
  call VUAssertEquals(res, expected, 'Expected a string', 57)
  call VUAssertEquals(list, ['stuff1', 'stuff2'], 'Expected a list', 58)
  call VUAssertNotSame(list, ['stuff1', 'stuff2'], 'Expected different lists', 59)
endfunction

function! s:TestInvalidString()
  let expected = '"a string'
  let list = [ '"a', 'string']
  let res = lh#command#Fargs2String(list)
  call VUAssertEquals(len(list), 0, 'Expected empty', 66)
  call VUAssertEquals(res, expected, 'Expected an invalid string', 67)
endfunction

function! AllTests()
  call s:TestEmpty()
  call s:TestSimpleText1()
  call s:TestSimpleTextN()
  call s:TestComposed1()
  call s:TestComposedN()
endfunction

" call VURunnerRunTest('AllTests')
VURun % AllTests

"=============================================================================
" vim600: set fdm=marker:
tests/lh/test-askmenu.vim	[[[1
65
"=============================================================================
" $Id: test-askmenu.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		test-buffer-menu.vim                                      {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	18th Apr 2007
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	
" 	Test units for buffermenu.vim
" 
"------------------------------------------------------------------------
" Installation:	Requires:
" 	(*) Vim 7.0+
" 	(*) vim_units.vim v0.2/1.0?
" 	    Vimscript # «???»
" 	(*) lh-vim-lib (lh#ask#menu)
"
" User Manual:
" 	Source this file.
"
" History:	
" (*) 17th Apr 2007: First version 
" TODO:		«missing features»
" }}}1
"=============================================================================



"=============================================================================
let s:cpo_save=&cpo
"------------------------------------------------------------------------
" Functions {{{1

function! TestAskMenu()
  imenu          42.40.10 &LH-Tests.&Menu.&ask.i       iask
  inoremenu      42.40.10 &LH-Tests.&Menu.&ask.inore   inoreask
  nmenu          42.40.10 &LH-Tests.&Menu.&ask.n       nask
  nnoremenu      42.40.10 &LH-Tests.&Menu.&ask.nnore   nnoreask
  nmenu <script> 42.40.10 &LH-Tests.&Menu.&ask.nscript nscriptask
  nnoremenu <script> 42.40.10 &LH-Tests.&Menu.&ask.nnnscript nnscriptask

  vmenu          42.40.10 &LH-Tests.&Menu.&ask.v     vask
  vnoremenu      42.40.10 &LH-Tests.&Menu.&ask.vnore vnoreask

  call s:CheckInMode('i', 'i')

endfunction

function! s:CheckInMode(mode, name)
  let g:menu = lh#askvim#menu('LH-Tests.Menu.ask.'.a:name, a:mode)
  let g:name = a:name
  " VUAssert 55 Equals g:menu.name     g:name     "Name mismatch"
  " VUAssert 56 Equals g:menu.priority '42.40.10' "Priority mismatch"
  " VUAssert 57 Fail "parce qu'il le faut bien"
  echomsg "name= ".g:menu.name
  echomsg "prio= ".g:menu.priority
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
tests/lh/test-command.vim	[[[1
69
" $Id: test-command.vim 156 2010-05-07 00:54:36Z luc.hermitte $
" Tests for lh-vim-lib . lh#command

" FindFilter(filter):                            Helper {{{3
function! s:FindFilter(filter)
  let filter = a:filter . '.vim'
  let result =globpath(&rtp, "compiler/BTW-".filter) . "\n" .
	\ globpath(&rtp, "compiler/BTW_".filter). "\n" .
	\ globpath(&rtp, "compiler/BTW/".filter)
  let result = substitute(result, '\n\n', '\n', 'g')
  let result = substitute(result, '^\n', '', 'g')
  return result
endfunction

function! s:ComplFilter(filter)
  let files = s:FindFilter('*')
  let files = substitute(files,
	\ '\(^\|\n\).\{-}compiler[\\/]BTW[-_\\/]\(.\{-}\)\.vim\>\ze\%(\n\|$\)',
	\ '\1\2', 'g')
  return files
endfunction

function! s:Add()
endfunction

let s:v1 = 'v1'
let s:v2 = 2

function! s:Foo(i)
  return a:i*a:i
endfunction

function! s:echo(params)
  echo s:{join(a:params, '')}
endfunction

function! Echo(params)
  " echo "Echo(".string(a:params).')'
  let expr = 's:'.join(a:params, '')
  " echo expr
  exe 'echo '.expr
endfunction

let TBTWcommand = {
      \ "name"      : "TBT",
      \ "arg_type"  : "sub_commands",
      \ "arguments" :
      \     [
      \       { "name"      : "echo",
      \		"arg_type"  : "function",
      \         "arguments" : "v1,v2",
      \         "action": function("\<sid>echo") },
      \       { "name"      : "Echo",
      \		"arg_type"  : "function",
      \         "arguments" : "v1,v2",
      \         "action": function("Echo") },
      \       { "name"  : "help" },
      \       { "name"  : "add",
      \         "arguments": function("s:ComplFilter"),
      \         "action" : function("s:Add") }
      \     ]
      \ }

call lh#command#new(TBTWcommand)

nnoremap µ :call lh#command#new(TBTWcommand)<cr>

"=============================================================================
" vim600: set fdm=marker:
tests/lh/test-menu-map.vim	[[[1
54
"=============================================================================
" $Id: test-menu-map.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:		tests/lh/test-menu-map.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.2.1
" Created:	05th Dec 2006
" Last Update:	$Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:	Tests for lh-vim-lib . lh#menu#
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================


" let g:want_buffermenu_or_global_disable = 1
" let b:want_buffermenu_or_global_disable = 1
" echo lh#option#get("want_buffermenu_or_global_disable", 1, "bg")

" Call a command (':Command')
call lh#menu#make("nic", '42.50.340',
      \ '&LH-Tests.&Menu-Make.Build Ta&gs', "<C-L>g",
      \ '<buffer>',
      \ ":echo 'TeXtags'<CR>")

" With '{' expanding to '{}××', or '{}' regarding the mode
call lh#menu#IVN_make('42.50.360.200',
      \ '&LH-Tests.&Menu-Make.&Insert.\toto{}', ']toto',
      \ '\\toto{',
      \ '{%i\\toto<ESC>%l',
      \ "viw]toto")

" Noremap for the visual maps
call lh#menu#IVN_make('42.50.360.200',
      \ '&LH-Tests.&Menu-Make.&Insert.\titi{}', ']titi',
      \ '\\titi{',
      \ '<ESC>`>a}<ESC>`<i\\titi{<ESC>%l',
      \ "viw]titi",
      \ 0, 1, 0)

" Noremap for the insert and visual maps
call lh#menu#IVN_make('42.50.360.200',
      \ '&LH-Tests.&Menu-Make.&Insert.<tata></tata>', ']tata',
      \ '<tata></tata><esc>?<<CR>i', 
      \ '<ESC>`>a</tata><ESC>`<i<tata><ESC>/<\\/tata>/e1<CR>',
      \ "viw]tata", 
      \ 1, 1, 0)

"=============================================================================
" vim600: set fdm=marker:
tests/lh/test-toggle-menu.vim	[[[1
84
"=============================================================================
" $Id: test-toggle-menu.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:         tests/lh/topological-sort.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.1
" Created:      17th Apr 2007
" Last Update:  $Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:  
"       Tests for lh-vim-lib . lh#menu#def_toggle_item()
"
"------------------------------------------------------------------------
" Installation: «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

source autoload/lh/menu.vim

let Data = {
      \ "variable": "bar",
      \ "idx_crt_value": 1,
      \ "values": [ 'a', 'b', 'c', 'd' ],
      \ "menu": { "priority": '42.50.10', "name": '&LH-Tests.&TogMenu.&bar'}
      \}

call lh#menu#def_toggle_item(Data)

let Data2 = {
      \ "variable": "foo",
      \ "idx_crt_value": 3,
      \ "texts": [ 'un', 'deux', 'trois', 'quatre' ],
      \ "values": [ 1, 2, 3, 4 ],
      \ "menu": { "priority": '42.50.11', "name": '&LH-Tests.&TogMenu.&foo'}
      \}

call lh#menu#def_toggle_item(Data2)

" No default
let Data3 = {
      \ "variable": "nodef",
      \ "texts": [ 'one', 'two', 'three', 'four' ],
      \ "values": [ 1, 2, 3, 4 ],
      \ "menu": { "priority": '42.50.12', "name": '&LH-Tests.&TogMenu.&nodef'}
      \}
call lh#menu#def_toggle_item(Data3)

" No default
let g:def = 2
let Data4 = {
      \ "variable": "def",
      \ "values": [ 1, 2, 3, 4 ],
      \ "menu": { "priority": '42.50.13', "name": '&LH-Tests.&TogMenu.&def'}
      \}
call lh#menu#def_toggle_item(Data4)

" What follows does not work because we can't build an exportable FuncRef on top
" of a script local function
" finish

function! s:getSNR()
  if !exists("s:SNR")
    let s:SNR=matchstr(expand("<sfile>"), "<SNR>\\d\\+_\\zegetSNR$")
  endif
  return s:SNR 
endfunction

function! s:Yes()
  echomsg "Yes"
endfunction

function! s:No()
  echomsg "No"
endfunction
let Data4 = {
      \ "variable": "yesno",
      \ "values": [ 1, 2 ],
      \ "text": [ "No", "Yes" ],
      \ "actions": [ function(s:getSNR()."No"), function(s:getSNR()."Yes") ],
      \ "menu": { "priority": '42.50.20', "name": '&LH-Tests.&TogMenu.&yesno'}
      \}
call lh#menu#def_toggle_item(Data4)
tests/lh/topological-sort.vim	[[[1
120
"=============================================================================
" $Id: topological-sort.vim 246 2010-09-19 22:40:58Z luc.hermitte $
" File:         tests/lh/topological-sort.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.1
" Created:      17th Apr 2008
" Last Update:  $Date: 2010-09-20 00:40:58 +0200 (lun., 20 sept. 2010) $
"------------------------------------------------------------------------
" Description:  «description»
"
"------------------------------------------------------------------------
" Installation: «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
UTSuite [lh-vim-lib] topological sort

" Fully defineds DAGs {{{1

" A Direct Acyclic Graph {{{2
let s:dag1 = {}
let s:dag1[7] = [11, 8]
let s:dag1[5] = [11]
let s:dag1[3] = [8, 10]
let s:dag1[11] = [2, 9, 10]
let s:dag1[8] = [9]

" A Direct Cyclic Graph {{{2
let s:dcg1 = deepcopy(s:dag1)
let s:dcg1[9] = [11]

" Check routine: are the elements correctly sorted? {{{2
function! s:DoTestOrder(elements)
  Assert! len(a:elements) == 8
  Assert index(a:elements, 7) < index(a:elements, 11)
  Assert index(a:elements, 7) < index(a:elements, 8)
  Assert index(a:elements, 5) < index(a:elements, 11)
  Assert index(a:elements, 3) < index(a:elements, 8)
  Assert index(a:elements, 3) < index(a:elements, 10)
  Assert index(a:elements, 11) < index(a:elements, 2)
  Assert index(a:elements, 11) < index(a:elements, 9)
  Assert index(a:elements, 11) < index(a:elements, 10)
  Assert index(a:elements, 8) < index(a:elements, 9)
endfunction

" Test DAG1 {{{2
function! s:TestDAG_depth()
  let res = lh#graph#tsort#depth(s:dag1, [3, 5,7])
  call s:DoTestOrder(res)
  echo "D(s:dag1)=".string(res)
endfunction

function! s:TestDAG_breadth()
  let res = lh#graph#tsort#breadth(s:dag1, [3, 5,7])
  call s:DoTestOrder(res)
  echo "B(s:dag1)=".string(res)
endfunction

" Test DCG1 {{{2
function! s:TestDCG_depth()
  let expr = 'lh#graph#tsort#depth('.string(s:dcg1).', [3, 5,7])'
  Assert should#throw(expr, 'Tsort: cyclic graph detected')
endfunction

function! s:TestDCG_breadth()
  let expr = 'lh#graph#tsort#breadth('.string(s:dcg1).', [3, 5,7])'
  Assert should#throw(expr, 'Tsort: cyclic graph detected')
endfunction

" Lazzy Evaluated DAGs {{{1

" Emulated lazzyness {{{2
" The time-consumings evaluation function
let s:called = 0
function! Fetch(node)
  let s:called += 1
  return has_key(s:dag1, a:node) ? (s:dag1[a:node]) : []
endfunction

" Test Fetch on a DAG {{{2
function! s:TestDAG_fetch()
  let s:called = 0
  let res = lh#graph#tsort#depth(function('Fetch'), [3,5,7])
  call s:DoTestOrder(res)
  echo "D(fetch)=".string(res)
  echo "Fetch has been evaluated ".s:called." times / ".len(res)
  Assert s:called == len(res)
endfunction


" Setup/Teardown functions {{{1
" display the test name before each assertion
function! s:Setup()
  if exists('g:UT_print_test')
    let s:old_print_test = g:UT_print_test
  endif
  let g:UT_print_test = 1
endfunction

function! s:Teardown()
  if exists('s:old_print_test')
    let g:UT_print_test = s:old_print_test 
    unlet s:old_print_test
  else
    unlet g:UT_print_test
  endif
endfunction


" }}}1
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:

