#!/usr/bin/env bash

# Set sane defaults for volume and backlight.
amixer -M set Master 15%
light -S 20

# Add a delay since MPD seems really finicky about starting.
sleep 5

# MPD daemon start (if no other user instance exists).
[ ! -s /home/thereca/.config/mpd/pid ] && mpd /home/thereca/.config/mpd/mpd.conf
mpc volume 50

###  Waybar's tray doesn't play nice without xwayland enabled. ###
## Add a delay so waybar's tray is available for cmst.
# pipewire &
cmst -w 5 &
qbittorrent &
fcitx-autostart
