#!/usr/bin/env bash
# This isn't how you do this
# Switched to a function in .bashrc

selected=$(find ~/Documents/Code -maxdepth 1 -type d | fzf)
cd $selected