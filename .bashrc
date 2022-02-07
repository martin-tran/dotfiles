#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[[ -f ~/.extend.bashrc ]] && . ~/.extend.bashrc

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

## ALIAS ##
alias ls="ls --color=auto --group-directories-first -lha"
alias clean="rm -vI ./\#*; rm -vI ./*~; rm -vI ./*~"
alias sshlabs="ssh martin.tran@linux.cpsc.ucalgary.ca"
alias sshpsc="ssh pscadmin@psc.cpsc.ucalgary.ca"
alias sshoraclevm="ssh opc@140.238.152.151"
alias orphans="pacman -Qtdq"
alias swaylock="swaylock -e -f --font 'IBM Plex Mono Text' -s fill -i /home/thereca/Pictures/yosumi_seek.png"
alias ffprobe="ffprobe -hide_banner"
alias ffmpeg="ffmpeg -hide_banner -vaapi_device /dev/dri/renderD128"
alias toggle_touchpad="swaymsg input type:touchpad events toggle enabled disabled"
# alias chromium="chromium --ignore-gpu-blacklist --use-gl=egl"

# Creates a webm with no audio, suitable for posting on image boards.
# Trades encoding time for higher quality and smaller file sizes.
# Adapted from https://wiki.installgentoo.com/wiki/WebM#2-pass_encoding.
convert_to_webm() {
    ffmpeg -hide_banner -vaapi_device /dev/dri/renderD128 -i "$1" -an \
           -c:v libvpx -pass 1 -qmin 0 -qmax 50 -crf 10 -b:v 1M \
           -threads 1 -speed 4 -g 128 -f webm /dev/null
    ffmpeg -hide_banner -vaapi_device /dev/dri/renderD128 -i "$1" -an \
           -c:v libvpx -pass 2 -qmin 0 -qmax 50 -crf 10 -b:v 1M \
           -threads 1 -speed 0 -auto-alt-ref 1 -lag-in-frames 25 \
           -g 128 -f webm "$2"
}

# Creates a gif with reasonable quality.
# Output is 10 fps, scaled down to $width, and infinitely looping.
# Usage: converttogif input.mp4 width output.gif
convert_to_gif() {
    if [[ -z "$1" ]] && [[ -z "$2" ]] && [[ -z "$3" ]]; then
        echo "Usage: converttogif input.mp4 width output.gif"
        exit 1
    fi
    ffmpeg -hide_banner -vaapi_device /dev/dri/renderD128 -i "$1" \
           -vf "fps=10,scale=$2:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
           -loop 0 "$3"
}

# Crops a video, preserving aspect ratio.
# Usage: scale_video input.mp4 720 cropped.mp4
scale_video() {
    if [[ -z "$1" ]] && [[ -z "$2" ]] && [[ -z "$3" ]]; then
        echo "Usage: scale_video input.mp4 720 cropped.mp4"
        exit 1
    fi
    ffmpeg -hide_banner -vaapi_device /dev/dri/renderD128 \
           -i "$1" -vf scale="-1:$2" "$3"
}

# Re-encode a YouTube stream from h.264 to HEVC. Meant to reduce the file size
# without affecting quality. Taken from:
# http://www.ssanime.ga/2021/09/how-to-encode-anime-episodes-to.html
# Usage: ssa_yt input.mp4 output.mp4
ssa_yt() {
    if [[ -z "$1" ]] && [[ -z "$2" ]]; then
        echo "Usage: ssa_yt input.mp4 output.mp4"
        exit 1
    fi
    ffmpeg -hide_banner -vaapi_device /dev/dri/renderD128 -i "$1" \
           -map 0:v:0 -map 0:a -b:a 192k -c:a aac -c:v libx265 \
           -color_primaries 1 -color_range 1 -color_trc 1 -colorspace 1 \
           -crf 24.2 -map 0:s? -pix_fmt yuv420p -preset slow -profile:v main \
           -vf smartblur=1.5:-0.35:-3.5:0.65:0.25:2.0,scale=1920:1080:spline16+accurate_rnd+full_chroma_int \
           -x265-params me=2:rd=4:subme=7:aq-mode=3:aq-strength=1:deblock=1,1:psy-rd=1:psy-rdoq=1:rdoq-level=2:merange=57:bframes=8:b-adapt=2:limit-sao=1 \
           "$2" -y
}

swap_monitors_dp2() {
    dp2_is_focused=$(swaymsg --pretty --type get_outputs | \
                         grep -E "DP\-2.+ \(focused\)")
    if [[ -n "${dp2_is_focused}" ]]; then
        swaymsg output eDP-1 enable
        swaymsg output DP-2 disable
    else
        swaymsg output DP-2 enable
        swaymsg output eDP-1 disable
    fi
}

swap_cpu_gov() {
    cur_gov=$(sudo tlp-stat -p | grep scaling_governor | awk '{ print $3 }')
    if [[ "$1" == "powersave" ]] || [[ "$1" == "schedutil" ]]; then
        gov="$1"
    else
        if [[ "${cur_gov}" == "powersave" ]]; then
            gov="schedutil"
        else
            gov="powersave"
        fi
    fi
    echo "Swapping scaling governor from $cur_gov to $gov"
    sudo cpupower frequency-set -g "${gov}"
}
