#!/bin/bash

# real_any_term_dropdown.sh - really turns any terminal into a dropdown, FPS/guake style, terminal
# version 0.1.0.2019
# Patrizio Migliarini
# based on any_term_dropdown.sh from gotbletu - https://github.com/gotbletu
#
# requirements:
#	-geometry -T / -n parameters compatible terminal emulator (tested with uxterm)
#	devilspie
# 	xdotool
# 	wmutils https://github.com/wmutils/core
#		https://aur.archlinux.org/packages/wmutils-git/ 
#
# extensively tested on Ubuntu 19 with GNOME 3 and uxterm
#
# DEVILSPIE:
# xterm.ds script in ~/:
#
#(if
#        (matches (application_name) "dr0pdown")
#        (begin
#                (undecorate)
#                (above)
#        )
#)
#
# PROMPT:
# colored prompt PS1 for debian/ubuntu in ~/.bashrc:
#PS1='${debian_chroot:+($debian_chroot)}\[\e[38;5;201m\]\u\[\e[38;5;202m\]@\[\e[38;5;204m\]\h\[\e[38;5;207m\]:\[\033[01;34m\]\w\033[00m\]$ '

# define the name of the dropdown console window
dropdown_name='dr0pdown'

#check if devilspie is running, if not run it
pgrep -x devilspie >/dev/null || devilspie ~/xterm.ds &

# wait for devilspie to be executed
sleep 0.1

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

# run terminal with 0x0+0+0 size and $dropdown_name title and name to be catched by devilspie
$my_term -geometry 0x0+0+0 -T "$dropdown_name" -n "$dropdown_name" &

# wait for the process to be started, you can change it according to your system speed
sleep 0.5

# search for terminal window
pid=$(xdotool search --class "$my_term" | head -n 1)

# get windows id from pid ex: 0x2a00125%
wid=$(printf 0x%x "$pid")

# set transparency
transset -i "$wid" "$tran" >/dev/null &

# wait for the transparency to be set
sleep 0.1

# maximize width first for courtain effect
wrs -a "$width" "$min_H" "$wid"
sleep 0.1

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

# is up
then

# switch focus on the terminal
wtf "$wid"

# map window
mapw -m "$wid"

# wait until mapped
wait

# wait before the drop down
sleep 0.1

# drop it down
wrs -a "$width" "$height" "$wid"

# is down
else

# detect active window
drophasfocus=$(xwininfo -id $(xprop -root | awk '/NET_ACTIVE_WINDOW/ { print $5; exit }') | awk -F\" '/xwininfo:/ { print $2; exit }')

# check if it's down and out of focus to bring back to a dropped down terminal
if [ "$drophasfocus" != "$dropdown_name" ]

# is down and out of focus
then

# activate and focus the dropdown terminal
xdotool windowactivate "$wid"

# is not out of focus, time to roll it up
else

# switch focus on the terminal to be sure it will not get focus once reduced and the focus switched
wtf "$wid"

# roll it up
wrs -a "$width" "$min_H" "$wid"

# switch focus to and active the previous window
xdotool keydown alt key Tab
xdotool keyup alt

# unmap window
sleep 0.65
mapw -u "$wid"

# end dropdown has focus
fi

# end of up or down if
fi

# end of terminal is opened or closed
fi
