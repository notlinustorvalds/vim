" ~/.vimrc (configuration file for vim only)


" """""""""""""""""""""""""""""""""""""""""""""""
" General settings to make things work like I want:

" line numbers on 
set nu


" tab width = 4, use spaces!
set expandtab
set shiftwidth=4
set softtabstop=4

" show me non-printing chars
set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:< 
" show me non-printing chars - mac
"set listchars=eol:$,tab:>-,trail: ,extends:>,precedes:< 

" catch trailing whitespace
nmap <silent> <leader>s :set nolist!<CR>

" highlight matching brackets 
set showmatch

" keep indenting as you go 
set autoindent

" dont bloody think for me when indenting! (smart indent, cindent)
set nosi
set nocin

" turn off the fscking wrap text 
set wrap!



" """""""""""""""""""""""""""""""""""""""""""""""
" """""""""""""""""""""""""""""""""""""""""""""""
" GUI MODE ONLY
if has('gui_running')

  " Set the window height and width
  set lines=35
  set columns=130

  " always show the tab bar
  set showtabline=2

  " turn on the syntax menu
  let do_syntax_sel_menu = 1|runtime! synmenu.vim|aunmenu &Syntax.&Show\ filetypes\ in\ menu
  
  " turn on the bottom scroll bar 
  set guioptions+=b

  " https://github.com/scrooloose/nerdtree
  autocmd vimenter * NERDTree
  
  " http://www.troubleshooters.com/linux/vifont.htm
  set guifont=Droid\ Sans\ Mono\ 8

endif
" """""""""""""""""""""""""""""""""""""""""""""""
" """""""""""""""""""""""""""""""""""""""""""""""


" be explicit about the map leader (the default is fine)
" let mapleader = "\"


" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings from "Configuring Vim right" (http://items.sjbach.com/319/configuring-vim-right)

" turn off the bell
set visualbell

" Intuitive backspacing in insert mode
set backspace=indent,eol,start

" concentrate the swp and temp files in one place (~/.vim/tmp)
set backupdir=~/.vim/tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim/tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" show all available commands when using \t to complete -- instead of first match:
set wildmenu

" By default, Vim only remembers the last 20 commands and search patterns 
set history=1000

" Turn on hidden: What this does is allow Vim to manage multiple buffers effectively.
set hidden





" """"""""""""""""""""""""""""""""""""""""""""""""""
" " PLUGINS
" " """"""""""""""""""""""""""""""""""""""""""""""""
" ShowMarks Plugin (http://www.vim.org/scripts/script.php?script_id=152)
let g:showmarks_include='0123456789ABCDEFGHJKLMNPQRSTUVWXYabcdefghjklmnpqrstuvwxyz'

" use the Autoclose plugin (http://www.vim.org/scripts/script.php?script_id=2009)
" (cant enable in vimrc)
" AutoCloseOn


" filetypes
syntax on
filetype on
filetype plugin on

" the default setting makes me batty!
" filetype indent on
filetype indent off

"https://github.com/scrooloose/nerdcommenter
"autocmd vimenter * NERDCommenter

" I REALLY REALLY like automatic comments!!!
" http://stackoverflow.com/questions/951555/vim-insert-comments-automatically
" http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
setlocal formatoptions+=c formatoptions+=r formatoptions+=o


" """"""""""""""""""""""""""""""""""""""""""""""""""
" MACROS
" " """"""""""""""""""""""""""""""""""""""""""""""""
" Enable extended % matching
" The % key will switch between opening and closing brackets. By sourcing
" matchit.vim, it can also switch among:
" - if/elsif/else/end, 
" - opening and closing XML tags, etc
runtime macros/matchit.vim

"http://www.vim.org/scripts/script.php?script_id=20
"Add the jcommenter.vim to your macros-folder (or whatever).
"autocmd FileType php let b:jcommenter_class_author='Rich Williams'
"autocmd FileType php let b:jcommenter_file_author='Rich Williams'
"autocmd FileType php source ~/.vim/macros/jcommenter.vim
"autocmd FileType php map <M-c> :call JCommentWriter()<CR>
"use Alt-c for commenting the file/methods/attributes/classes.




" """"""""""""""""""""""""""""""""""""""""""""""""""
" CODE
" """"""""""""""""""""""""""""""""""""""""""""""""""

" """"""""""""""""""""""""""""""""""""""""""""""""""
" HTML/XML AUTOCLOSE TAG
" http://vim.wikia.com/wiki/Auto_closing_an_HTML_tag
:iabbrev </ </<C-X><C-O>
" You may find that sometimes you want to type </ without invoking the abbreviation.
":iabbrev <// </<C-X><C-O>
" Also you can remap Ctrl-x Ctrl-o to Ctrl-Space using: 
:imap <C-Space> <C-X><C-O>





" """"""""""""""""""""""""""""""""""""""""""""""""''
" default stuff
" skeletons
function! SKEL_spec()
	0r /usr/share/vim/current/skeletons/skeleton.spec
	language time en_US
	if $USER != ''
	    let login = $USER
	elseif $LOGNAME != ''
	    let login = $LOGNAME
	else
	    let login = 'unknown'
	endif
	let newline = stridx(login, "\n")
	if newline != -1
	    let login = strpart(login, 0, newline)
	endif
	if $HOSTNAME != ''
	    let hostname = $HOSTNAME
	else
	    let hostname = system('hostname -f')
	    if v:shell_error
		let hostname = 'localhost'
	    endif
	endif
	let newline = stridx(hostname, "\n")
	if newline != -1
	    let hostname = strpart(hostname, 0, newline)
	endif
	exe "%s/specRPM_CREATION_DATE/" . strftime("%a\ %b\ %d\ %Y") . "/ge"
	exe "%s/specRPM_CREATION_AUTHOR_MAIL/" . login . "@" . hostname . "/ge"
	exe "%s/specRPM_CREATION_NAME/" . expand("%:t:r") . "/ge"
	setf spec
endfunction

autocmd BufNewFile	*.spec	call SKEL_spec()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" @file    codefile.vim
"" @brief   turns on the tools that I use for coding.... but only when I want them
"" @since   27 Jan 2012
"" @author  Rich Williams; misterich -at google's domain-
"
"" @details     Place this file in the ~/.vim/plugins folder (when it's done)


" http://vim.wikia.com/wiki/Auto_end-quote_html/xml_attribute_values_as_you_type_in_insert_mode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" auto-closing quotes
"inoremap " ""<LEFT>
"inoremap ' ''<LEFT>
"inoremap ` ``<LEFT>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" auto-closing brackets

" html <I>
"inoremap <> <><LEFT>

" parenthesis:  this allows for a standard function call foo();
"imap () ()

" parenthesis: ( I )
inoremap (<Space> (<Space><Space>)<LEFT><LEFT>

" square brackets: [I]
"inoremap [] []<LEFT>

" square brackets: [ I ]    << useful for BASH and shell scripts
inoremap [<Space> [<Space><Space>]<LEFT><LEFT>

" curly braces: {I}
"inoremap {} {}<LEFT>

" curly braces: 
"{
"   I    
"}
"inoremap { {<CR><BS>}<Esc>ko

" curly braces: {
"    I
"}
inoremap {<CR> {<CR>}<Esc>O <TAB>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Tab completion
"  http://www.cosy.sbg.ac.at/~held/teaching/unix/init_files/.vimrc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction

" Remap the tab key to select action with InsertTabWrapper
inoremap <C-space> <c-r>=InsertTabWrapper()<cr>

" http://ubuntuforums.org/showthread.php?t=1212765
if has("autocmd")
  filetype plugin on
endif


" ~/.vimrc ends here
