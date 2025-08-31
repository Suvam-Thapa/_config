#!/bin/bash
# Check if the code session exists, attach if it does, create if it doesn't
if ! tmux has-session -t code 2>/dev/null; then
    tmux new-session -s code -d -c "$PWD"
    tmux new-window -t code -c "$PWD"
    tmux send-keys -t code:1.1 "nvim" C-m
    tmux select-window -t code:1 # same thing : tmux select-pane -t code:1.1
fi
tmux attach-session -t code
