#!/bin/bash

SESSION="Ephemera_nvim"
TARGET_DIR="$(pwd)/lua"

tmux kill-session -t "$SESSION" 2>/dev/null

# editor window
tmux new-session -d -s "$SESSION" -n "editor" -c "$TARGET_DIR"
tmux send-keys -t "$SESSION:editor" "nvim" C-m

# shell window
tmux new-window -t "$SESSION" -n "shell" -c "$TARGET_DIR"

# lazygit window
tmux new-window -t "$SESSION" -n "lazygit" -c "$TARGET_DIR"
tmux send-keys -t "$SESSION:lazygit" "lazygit" C-m

# opencode window (opencode left 69%, terminal right 31%)
tmux new-window -t "$SESSION" -n "opencode" -c "$TARGET_DIR"
tmux send-keys -t "$SESSION:opencode" "opencode" C-m
tmux split-window -h -t "$SESSION:opencode" -p 31 -c "$TARGET_DIR"

tmux select-window -t "$SESSION:editor"
tmux attach-session -t "$SESSION"
