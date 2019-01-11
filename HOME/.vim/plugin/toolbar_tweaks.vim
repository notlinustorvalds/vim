"http://vimdoc.sourceforge.net/htmldoc/gui.html
" http://vimdoc.sourceforge.net/htmldoc/gui.html#creating-menus

" :version
"  system vimrc file: '$VIM/vimrc'
"    user vimrc file: '$HOME/.vimrc'
"     user exrc file: '$HOME/.exrc'
" system gvimrc file: '$VIM/gvimrc'
"   user gvimrc file: '$HOME/.gvimrc'
"   system menu file: '$VIMRUNTIME/menu.vim'
" fall-back for $VIM: '/usr/share/vim'

" ---------------------------------------------------------------------------------------------------
"  copied from /usr/share/vim/vimcurrent/menu.vim
"  NOTE:
"   ALL BACKSLASHES HAVE BEEN INSERTED; THEY WERE NOT IN THE ORIGINAL  FILE!
"
"
" The GUI toolbar (for MS-Windows and GTK)
" if has("toolbar")
"   an 1.10 ToolBar.Open			:browse confirm e<CR>
"   an <silent> 1.20 ToolBar.Save		:if expand("%") == \"\"<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR>
"   an 1.30 ToolBar.SaveAll		:browse confirm wa<CR>
" 
"   if has("printer")
"     an 1.40   ToolBar.Print		:hardcopy<CR>
"     vunmenu   ToolBar.Print
"     vnoremenu ToolBar.Print		:hardcopy<CR>
"   elseif has("unix")
"     an 1.40   ToolBar.Print		:w !lpr<CR>
"     vunmenu   ToolBar.Print
"     vnoremenu ToolBar.Print		:w !lpr<CR>
"   endif
" 
"   an 1.45 ToolBar.-sep1-		<Nop>
"   an 1.50 ToolBar.Undo			u
"   an 1.60 ToolBar.Redo			<C-R>
" 
"   an 1.65 ToolBar.-sep2-		<Nop>
"   vnoremenu 1.70 ToolBar.Cut		"+x
"   vnoremenu 1.80 ToolBar.Copy		"+y
"   cnoremenu 1.80 ToolBar.Copy		<C-Y>
"   nnoremenu 1.90 ToolBar.Paste		"+gP
"   cnoremenu	 ToolBar.Paste		<C-R>+
"   exe 'vnoremenu <script>	 ToolBar.Paste	' . paste#paste_cmd['v']
"   exe 'inoremenu <script>	 ToolBar.Paste	' . paste#paste_cmd['i']
" 
"   if !has("gui_athena")
"     an 1.95   ToolBar.-sep3-		<Nop>
"     an 1.100  ToolBar.Replace		:promptrepl<CR>
"     vunmenu   ToolBar.Replace
"     vnoremenu ToolBar.Replace		y:promptrepl <C-R>=<SID>FixFText()<CR><CR>
"     an 1.110  ToolBar.FindNext		n
"     an 1.120  ToolBar.FindPrev		N
"   endif
" 
"   an 1.215 ToolBar.-sep5-		<Nop>
"   an <silent> 1.220 ToolBar.LoadSesn	:call <SID>LoadVimSesn()<CR>
"   an <silent> 1.230 ToolBar.SaveSesn	:call <SID>SaveVimSesn()<CR>
"   an 1.240 ToolBar.RunScript		:browse so<CR>
" 
"   an 1.245 ToolBar.-sep6-		<Nop>
"   an 1.250 ToolBar.Make			:make<CR>
"   an 1.270 ToolBar.RunCtags		:exe \"!\" . g:ctags_command<CR>
"   an 1.280 ToolBar.TagJump		g<C-]>
" 
"   an 1.295 ToolBar.-sep7-		<Nop>
"   an 1.300 ToolBar.Help			:help<CR>
"   an <silent> 1.310 ToolBar.FindHelp	:call <SID>Helpfind()<CR>



" Default crap that I NEVER use to remove
:aunmenu ToolBar.LoadSesn
:aunmenu ToolBar.SaveSesn
:aunmenu ToolBar.Make
:aunmenu ToolBar.RunCtags
:aunmenu ToolBar.TagJump
:aunmenu ToolBar.Help
:aunmenu ToolBar.FindHelp


" http://superuser.com/questions/11289/how-do-i-customize-the-gvim-toolbar
" :tmenu position  ToolBar.name-of-icon-w/o-ext   pop up texct to display
" > The :tmenu command works just like other menu commands, it uses the same
" > arguments.  :tunmenu deletes an existing menu tip, in the same way as the
" > other unmenu commands.
"
" :amenu  ToolBar.name-of-icon-w/o-ext   G/vim command to run
" > The :amenu command can be used to define menu entries for all modes at once.
"
" :imenu 
" > use only during interactive mode!
"
" use :emenu to access useful menu items you may have got used to from GUI mode.
" http://vimdoc.sourceforge.net/htmldoc/gui.html#console-menus
"
" :tm[enu] {menupath} {rhs}	Define a tip for a menu or tool.
"
" :tu[nmenu] {menupath}		Remove a tip for a menu or tool.
"
" If you want to get rid of the menu bar:
"   :set guioptions-=m

" New Items!
:amenu  ToolBar.DeleteAllFolds      <Esc>ggvG$zD<CR>
:amenu  ToolBar.DeleteThisFold      zd
:amenu  ToolBar.CloseAllFolds       zM
:amenu  ToolBar.OpenAllFolds        zR
:amenu  ToolBar.SpellCheckOn        :set spell<CR>
:amenu  ToolBar.SpellCheckOff       :set nospell<CR>
:amenu  ToolBar.SpellCheckNext      ]s
:amenu  ToolBar.SpellCheckPrev      [s
:amenu  ToolBar.SpellCheckSuggest   z=
:amenu  ToolBar.SpellCheckReplAll   :spellrepall<CR>


:tmenu  1.250   ToolBar.DeleteAllFolds      Delete All Folds!
:tmenu  1.270   ToolBar.DeleteThisFold      Delete current fold
:tmenu  1.280   ToolBar.CloseAllFolds       Close all folds
:tmenu  1.290   ToolBar.OpenAllFolds        Open all folds
an      1.305   ToolBar.-sep7-		    <Nop>
:tmenu  1.310   ToolBar.SpellCheckOn        Turn on spelcehck!
:tmenu  1.330   ToolBar.SpellCheckOff       Turn off spellcheck
:tmenu  1.350   ToolBar.SpellCheckNext      To next splelig error
:tmenu  1.370   ToolBar.SpellCheckPrev      To prev splelng error
:tmenu  1.390   ToolBar.SpellCheckSuggest   Suggest spelling corrections
:tmenu  1.410   ToolBar.SpellCheckReplAll   Repeat spelling correction

