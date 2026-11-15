# ~/.bashrc: executado pelo bash para shells interativos (não-login)

case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

case ":$PATH:" in
    *:/usr/sbin:*) ;;
    *) export PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin" ;;
esac

if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
