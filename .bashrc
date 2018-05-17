#
# ~/.bashrc
#

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

# AUTOMATICALLY APPLY PYWAL THEME TO NEW TERMINALS
#(wal -r &)
#cat /home/thereca/.cache/wal/sequences

# MAKE RUBY GEMS EXECUTABLE ##
PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
# MAKE USERWIDE CABAL INSTALLS EXECUTABLE ##
PATH=$PATH:~/.cabal/bin

# ENABLE FCITX FOR JAPANESE KEYBOARD ##
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx

remove_residues() {
    rm -vf *~
    rm -vf .*~
    rm -vf \#*
    rm -vf *.hi
    rm -vf *.o
}

## ALIAS ##
alias clean=remove_residues
alias sshlabs="ssh martin.tran@linux.cpsc.ucalgary.ca"
alias i3-mvwsright="i3-msg move workspace to output right"
alias i3-mvwsleft="i3-msg move workspace to output left"
alias ghc="ghc -dynamic -O3"
alias cabal="/home/thereca/.local/bin/cabal"
