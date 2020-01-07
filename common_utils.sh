#!/usr/bin/env bash

# Note that this still has the trailing ',' and gives the 5 minute load average.
get_cpu_load() {
    uptime | awk '{ print $9 }'
}

get_battery() {
    echo $(cat /sys/class/power_supply/BAT0/capacity)%
}

get_alsa_volume() {
    amixer -M sget Master | awk -F'[][]' '{ print $2 }' | tail -n 1
}

get_alsa_mute() {
    amixer -M sget Master | tail -n 1 | awk '{ print $6 }'
}

raise_alsa_volume() {
    amixer -M set Master 2%+
    swaymsg -t send_tick $(echo volum $(get_alsa_volume))
}

lower_alsa_volume() {
    amixer -M set Master 2%-
    swaymsg -t send_tick $(echo volum $(get_alsa_volume))
}

toggle_alsa_mute() {
    amixer set Master toggle
    if [ $(get_alsa_mute) = [off] ]; then
	swaymsg -t send_tick $(echo volum mute)
    else
	swaymsg -t send_tick $(echo volum $(get_alsa_volume))
    fi
}

raise_mpd_volume() {
    mpc volume +5
}

lower_mpd_volume() {
    mpc volume -5
}

get_backlight() {
    printf "light %0.f%%" $(light -G)
}

raise_backlight() {
    light -A 5
    swaymsg -t send_tick $(get_backlight)
}

lower_backlight() {
    light -U 5
    swaymsg -t send_tick $(get_backlight)
}

full_screenshot() {
    grim ~/Pictures/$(date +'%s_grim.png')
}

region_screenshot() {
    grim -g "$(slurp)" ~/Pictures/$(date +'%s_grim.png')
}

open_falkon() {
    swaymsg exec falkon
    sleep 2
    swaymsg floating toggle
}

# lock_and_suspend() {
#     swaylock -e -f --font "IBM Plex Mono Text" -s fill -i "/home/thereca/Pictures/GFL/m200-intervention_chibi_acquire-screen.png"
#     swaymsg "output * dpms off"
#     sudo /usr/local/sbin/echo_suspend.sh  # Don't rely on broken programs like uswusp-git.
#     sleep 1
#     swaymsg "output * dpms on"
#     sleep 1
#     sudo hostname etria  # For some reason the hostname always resets after reboot/unsuspend.
# }

#
# Shamelessly stolen from:
# https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line
#
# Check if the function exists (bash specific)
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "'$1' is not a known function name" >&2
  exit 1
fi
