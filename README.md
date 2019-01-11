# Rich's vim configuration
Note the special `.git/config`:

```
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
    ignorecase = true
    eol=lf
    symlinks=true
    editor = vim
```

To use:

1. Clone the repo to a location not in `$HOME`  
   ```
   cd /data/`hostname`/projects
   mkdir vim
   cd vim
   git clone git@github.com:notlinustorvalds/vim.git .
   ```
1. Create symlinks in `$HOME`  
   ```
   cd ~
   ln -s  /data/`hostname`/projects/vim/HOME/.vimrc  .
   ln -s  /data/`hostname`/projects/vim/HOME/.vim  .
   ```

