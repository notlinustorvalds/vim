" Defaults override
" http://vimdoc.sourceforge.net/htmldoc/options.html#after-directory
"   In the "after" directory in the system-wide Vim directory.  This is
"   for the system administrator to overrule or add to the distributed
"   defaults (rarely needed)
"    
"   In the "after" directory in your home directory.  This is for
"   personal preferences to overrule or add to the distributed defaults
"   or system-wide settings (rarely needed).
"



" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax Folding
" http://vim.wikia.com/wiki/Syntax_folding_of_Vim_scripts
"   http://vim.wikia.com/wiki/Folding
"   http://vim.wikia.com/wiki/VimTip1534

setlocal foldmethod=syntax

"   VIM's command window ('q:') and the :options window also set filetype=vim. We
"   do not want folding in these enabled by default, though, because some
"   malformed :if, :function, ... commands would fold away everything from the
"   malformed command until the last command.
if bufname('') =~# '^\%(' . (v:version < 702 ? 'command-line' : '\[Command Line\]') . '\ option-window\)$'
    "   With this, folding can still be enabled easily via any zm, zc, zi, ...
    "   command.
    setlocal nofoldenable
else
    "   Fold settings for ordinary windows.
    setlocal foldcolumn=4
endif

