#
# ~/.bash_profile
#

# ENABLE FCITX FOR JAPANESE KEYBOARD ##
export INPUT_METHOD=fcitx
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx

# Force Qt5 progarms to use Wayland instead of XWayland.
export QT_QPA_PLATFORM=wayland-egl

export EDITOR=emacs

export PATH="$PATH:$HOME/go/bin"

# Autostart sway.
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec sway -d 2> ~/sway1.log; fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
