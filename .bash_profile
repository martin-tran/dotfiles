#
# ~/.bash_profile
#

# ENABLE FCITX FOR JAPANESE KEYBOARD ##
export INPUT_METHOD=fcitx
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx

export EDITOR=emacs

export PATH="$PATH:/usr/local/go/bin:$HOME/.local/bin"
# export GOPATH="$HOME/go"

export TERMINAL=termite

# Required for a functional tray.
export XDG_CURRENT_DESKTOP=Unity

# Autostart sway on tty1.
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    # Force Qt5 progarms to use Wayland instead of XWayland.
    # export QT_QPA_PLATFORM=wayland-egl
    export QT_QPA_PLATFORMTHEME=qt5ct

    exec sway;
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
