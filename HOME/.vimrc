" ~/.vimrc (configuration file for vim only)


" """""""""""""""""""""""""""""""""""""""""""""""
" General settings to make things work like I want:

" line numbers on 
set nu

" turn modelines on
set modeline
set modelines=5

" http://www.e-reading.org.ua/htmbook.php/orelly/unix2.1/vi/ch11_10.htm
" The nocp option turns off strict vi compatibility. The incsearch option
" turns on incremental searching.
" - also used for the align plugin: http://www.vim.org/scripts/script.php?script_id=294
set nocp incsearch

"Line and column highlighting
"http://vim.wikia.com/wiki/Highlight_current_line
" http://stackoverflow.com/questions/9869057/vim-linenr-and-cursorline-colour-configuration-change
" options: http://www.sbf5.com/~cduan/technical/vi/vi-4.shtml
" colors: http://choorucode.wordpress.com/2011/07/29/vim-chart-of-color-names/
"         http://alvinalexander.com/linux/vi-vim-editor-color-scheme-syntax
" src: http://code.metager.de/source/xref/vim/src/syntax.c
"set cursorline
"set cursorcolumn
":hi CursorLine   cterm=NONE bg=darkred ctermfg=white guibg=darkred guifg=white
":hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
":hi CursorLine      cterm=underline ctermbg=none guibg=GhostWhite 
":hi CursorColumn    cterm=bold      ctermbg=none guibg=GhostWhite


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


" http://www.cs.swarthmore.edu/help/vim/vim7.html
if has("spell")
""  set spell
  map <F5> :set spell!<CR><Bar>:echo "Spell Check: " . strpart("OffOn", 3 * &spell, 3)<CR>
  highlight SpellBad ctermfg=black ctermbg=white guibg=darkgrey guifg=white cterm=bold
  highlight SpellCap ctermfg=darkred ctermbg=white guibg=darkred guifg=white cterm=bold
  highlight PmenuSel ctermfg=black ctermbg=white guibg=black guifg=white cterm=bold
  mkspell!  ~/.vim/spell/en.utf-8.add
endif
" """""""""""""""""""""""""""""""""""""""""""""""
" """""""""""""""""""""""""""""""""""""""""""""""
" GUI MODE ONLY
if has('gui_running')

  " Set the window height and width
  set lines=65
  set columns=200

  " always show the tab bar
  set showtabline=2

  " show up to 50 tabs
  "set tabpagemax=50

  " show up to 100 tabs
  set tabpagemax=100
  
  function! GuiTabLabel()
    " buffer_number[+] buffer_name [(number_windows)]

    " Add buffer number
    let label = v:lnum

    " Add '+' if one of the buffers in the tab page is modified
    let bufnrlist = tabpagebuflist(v:lnum)
    for bufnr in bufnrlist
        if getbufvar(bufnr, "&modified")
        let label .= '+'
        break
        endif
    endfor

    " Append the buffer name
    let label .= ' ' . bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])

    " Append the number of windows in the tab page if more than one
    let wincount = tabpagewinnr(v:lnum, '$')
    if wincount > 1
        let label .= ' (' . wincount . ')'
    endif

    return label
  endfunction

set guitablabel=%{GuiTabLabel()}
  
  " turn on the syntax menu
  let do_syntax_sel_menu = 1|runtime! synmenu.vim   "|aunmenu &Syntax.&Show\ filetypes\ in\ menu
  
  " turn on the bottom scroll bar 
  set guioptions+=b

  " https://github.com/scrooloose/nerdtree
  "autocmd vimenter * NERDTree
  
  " http://www.troubleshooters.com/linux/vifont.htm
  set guifont=Droid\ Sans\ Mono\ 14

endif
" """""""""""""""""""""""""""""""""""""""""""""""
" """""""""""""""""""""""""""""""""""""""""""""""
" http://stackoverflow.com/questions/8356195/vimrc-different-colorscheme-when-file-is-read-only
function CheckRo()
    if &readonly
        colorscheme desert
    endif
endfunction
au BufReadPost * call CheckRo()
" """""""""""""""""""""""""""""""""""""""""""""""
" """""""""""""""""""""""""""""""""""""""""""""""




" be explicit about the map leader (the default is fine)
" let mapleader = "\"





" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings from "Configuring Vim right" (http://items.sjbach.com/319/configuring-vim-right)

" turn off the bell
"set visualbell

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
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-markdown-preview
" ~/.vim/bundle/vim-markdown-preview
" https://github.com/JamshedVesuna/vim-markdown-preview
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let vim_markdown_preview_browser='firefox'
let vim_markdown_preview_use_xdg_open=1
"let vim_markdown_preview_hotkey='<F12>'
"   the following requies python grip
"   https://github.com/joeyespo/grip
"   $  sudo pip install grip
let vim_markdown_preview_github=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" pathogen.vim
" https://github.com/tpope/vim-pathogen
" Manage your 'runtimepath' with ease. In practical terms, pathogen.vim 
" makes it super easy to install plugins and runtime files in their own 
" private directories.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" usage:
"   Now any plugins you wish to install can be extracted to a 
"   SUBDIRECTORY under ~/.vim/bundle, and they will be added 
"   to the 'runtimepath'. 
"   observe:
"       cd ~/.vim/bundle && \
"       git clone https://github.com/tpope/vim-sensible.git
"execute pathogen#infect()
"execute pathogen#infect('bundle/{}', '~/.vim/bundle/{}')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Folding
" http://vim.wikia.com/wiki/Folding

"   MANUAL FOLDING
"   Normally it is best to use an automatic folding method, but manual 
"   folding is simple and useful for dealing with small folds. It is 
"   easy to fold an arbitrary block from visual mode by pressing:
"       'v{motion}zf'. 
"   Alternatively, this can be used in normal mode, after zf'a for 
"   example will fold from the current line to wherever the mark a has been 
"   set, or zf3j will fold the next 3 lines. This allows you to see the 
"   section you've selected before you fold it. 
"
"   If you just want to enter a few folds in a program that uses braces 
"   around blocks ({...}), you can use the command
"       'va}zf' 
"   to create a fold for the block containing the cursor. i
"
"   Use zd to delete a fold (no text is deleted; the fold at the 
"   cursor is removed). 
"   A quicker way to create a block is with 
"       'zf{motion}'
"   so the example fold mentioned earlier could also be typed 
"       'zfa}'
"
" INDENT FOLDING WITH MANUAL FOLDS
" If you like the convenience of having Vim define folds automatically by indent level, 
" -- but would also like to create folds manually, you can get both by putting 
"  this in your vimrc:
augroup vimrc
  au BufReadPre * setlocal foldmethod=indent
  au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
augroup END

" Key maps to show/hide folds
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf

set viewoptions=cursor,folds,slash,unix 
let g:skipview_files = ['*\.vim']

" http://vim.wikia.com/wiki/Vim_as_XML_Editor
" To set up syntax folding automatically for XML files put the 
" following lines in your .vimrc
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax
au FileType xsd setlocal foldmethod=syntax

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
"function! SKEL_spec()
"	0r /usr/share/vim/current/skeletons/skeleton.spec
"	language time en_US
"	if $USER != ''
"	    let login = $USER
"	elseif $LOGNAME != ''
"	    let login = $LOGNAME
"	else
"	    let login = 'unknown'
"	endif
"	let newline = stridx(login, "\n")
"	if newline != -1
"	    let login = strpart(login, 0, newline)
"	endif
"	if $HOSTNAME != ''
"	    let hostname = $HOSTNAME
"	else
"	    let hostname = system('hostname -f')
"	    if v:shell_error
"		let hostname = 'localhost'
"	    endif
"	endif
"	let newline = stridx(hostname, "\n")
"	if newline != -1
"	    let hostname = strpart(hostname, 0, newline)
"	endif
"	exe "%s/specRPM_CREATION_DATE/" . strftime("%a\ %b\ %d\ %Y") . "/ge"
"	exe "%s/specRPM_CREATION_AUTHOR_MAIL/" . login . "@" . hostname . "/ge"
"	exe "%s/specRPM_CREATION_NAME/" . expand("%:t:r") . "/ge"
"	setf spec
"endfunction
"autocmd BufNewFile	*.spec	call SKEL_spec()

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ~/.vimrc ends here
