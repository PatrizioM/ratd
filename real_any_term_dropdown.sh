#!/bin/bash

# real_any_term_dropdown.sh - really turns any terminal into a dropdown, FPS/guake style, terminal
# version 0.1.0.2019
# Patrizio Migliarini
# based on any_term_dropdown.sh from gotbletu - https://github.com/gotbletu
#
# requirements:
#	-geometry -T / -n parameters compatible terminal emulator
#	devilspie
# 	xdotool
# 	wmutils https://github.com/wmutils/core
#		https://aur.archlinux.org/packages/wmutils-git/ 
#
# extensively tested on Ubuntu 19 with GNOME 3 and uxterm
#
# devilspie script:
#
#(if
#        (matches (application_name) "dr0pdown")
#        (begin
#                (undecorate)
#                (above)
#        )
#)
#

# get screen resolution
ROOT=$(lsw -r)
# get width
width=$(wattr w $ROOT)
# get height
fullheight=$(wattr h $ROOT)
# calculate half height
height=$(( $fullheight / 2))
# set minimum terminal height, with 40 and default uxterm you will have a single line ternial while minimized
min_H=40
# set transparency (to be matched with topbar transparency)
tran=0.70

# option 1: set terminal emulator manually
# my_term=urxvt
# my_term=xterm
# my_term=terminator
# my_term=gnome-terminal
my_term=uxterm


# option 2: auto detect terminal emulator (note: make sure to only open one)
#my_term="urxvt|xterm|uxterm|termite|sakura|lxterminal|terminator|mate-terminal|pantheon-terminal|konsole|gnome-terminal|xfce4-terminal"

# get terminal emulator pid ex: 44040485
pid=$(xdotool search --class "$my_term" | head -n 1)

# test if terminal is running
if test -z "$pid" 

#if terminal emulator is not running
then

# run terminal with 0x0+0+0 size and "dr0pdown" title and name to be catched by devilspie
$my_term -geometry 0x0+0+0 -T "dr0pdown" -n "dr0pdown" &

# wait for the process to be started, you can change it according to your system speed
sleep 0.3

# search for terminal window
pid=$(xdotool search --class "$my_term" | head -n 1)

# get windows id from pid ex: 0x2a00125%
wid=$(printf 0x%x "$pid")

# set transparency
transset -i "$wid" "$tran" &

# dropdown the terminal emulator
# maximize width first for courtain effect
wrs -a "$width" "$min_H" "$wid"
# maximize height to $height (default: half screen)
wrs -a "$width" "$height" "$wid"

# if terminal emulator is running
else

# search terminal emulator window
pid=$(xdotool search --class "$my_term" | head -n1)

# get windows id from pid ex: 0x2a00125%
wid=$(printf 0x%x "$pid")

# get terminal window height
consoleH=$(xdotool getwindowgeometry "$pid" |tail -n1 |tail -c 3)

# check if it's up or down
if [ "$consoleH" -lt "$min_H" ]

# up
then

# drop it down
wrs -a "$width" "$height" "$wid"

# switch focus on the terminal
wtf "$wid"

# down
else

# roll it up
wrs -a "$width" "$min_H" "$wid"
fi

#switch focus to the next window
xdotool keydown alt key Tab
xdotool keyup alt 

# end of main if (terminal is opened or closed)
fi
