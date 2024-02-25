#!/usr/bin/env bash
# switches escape with caps lock
# Used to use this for vim but no need (jj, jk exits insert mode)
# Or just use CTRL + [

read -p "Caps -> Esc? Otherwise reset. (y/n): " keysw

if [[ $keysw =~ [yY] ]]; then
	setxkbmap -option caps:swapescape
else
	setxkbmap -option
fi
