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

[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion

## ALIAS ##
alias ls="ls --color=auto --group-directories-first"
alias clean="rm -vI \#*; rm -vI *~; rm -vI .*~"
alias sshlabs="ssh martin.tran@linux.cpsc.ucalgary.ca"
alias sshpsc="ssh pscadmin@psc.cpsc.ucalgary.ca"
alias orphans="pacman -Qtdq"
alias swaylock="swaylock -e -f --font 'IBM Plex Mono Text' -s fill -i /home/thereca/Pictures/yosumi_seek.png"
# alias chromium="chromium --ignore-gpu-blacklist --use-gl=egl"

swap_monitors_dp2() {
    dp2_is_focused=$(swaymsg --pretty --type get_outputs | \
                         grep -E "DP\-2.+ \(focused\)")
    if [[ -n $dp2_is_focused ]]; then
        swaymsg output eDP-1 enable
        swaymsg output DP-2 disable
    else
        swaymsg output DP-2 enable
        swaymsg output eDP-1 disable
    fi
}
