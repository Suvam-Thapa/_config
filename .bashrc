#
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval "$(zoxide init bash)"
# Start tmux 
tea() { 
    . ~/start_tmux.sh
}
alias ls='ls --color=auto -sah'
alias grep='grep --color=auto'
PS1='[\#]\n[\@] [\d]\n[\u@\h \W]\$ '
