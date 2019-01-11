" ~/.vimrc (configuration file for vim only)


" """""""""""""""""""""""""""""""""""""""""""""""
" General settings to make things work like I want:

" line numbers on 
set nu

" always show the tab bar
set showtabline=2

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

" turn on the bottom scroll bar 
set guioptions+=b

" Set the window height and width
set lines=50
set columns=110

" turn on the syntax menu
let do_syntax_sel_menu = 1|runtime! synmenu.vim|aunmenu &Syntax.&Show\ filetypes\ in\ menu 

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




" """"""""""""""""""""""""""""""""""""""""""""""""""
" MACROS
" " """"""""""""""""""""""""""""""""""""""""""""""""
" Enable extended % matching
" The % key will switch between opening and closing brackets. By sourcing
" matchit.vim, it can also switch among:
" - if/elsif/else/end, 
" - opening and closing XML tags, etc
runtime macros/matchit.vim






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

" ~/.vimrc ends here
