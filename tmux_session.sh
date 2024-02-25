#!/usr/bin/env bash
# Creates tmux session with different windows

cd ~/Documents/Code/
session="main"
tmux new-session -d -s $session
window=0
tmux rename-window -t $session:$window "nvim-main"
window=1
tmux new-window -t $session:$window -n "run"
window=2
tmux new-window -t $session:$window -n "git"
window=3
tmux new-window -t $session:$window -n "nvim-test"
window=4
tmux new-window -t $session:$window -n "shell"
tmux attach-session -t $session:0
