#
# ~/.bashrc
#

. /etc/bash.bashrc

# Disable flow control (^S, ^Q)
stty -ixon -ixoff

PATH=$PATH:~/.gem/ruby/2.1.0/bin
#export PS1="\[\e[1;30m\][\[\e[1;32m\]\u\[\e[0;30m\]@\[\e[1;30m\]\[\e[1;36m\]\H\[\e[0;30m\] \[\e[1;37m\]\w\[\e[1;30m\]]\[\e[0;37m\]$ "

export M2_HOME=/opt/maven
export SDL_MOUSE_RELATIVE=0
export OXYGEN_DISABLE_INNER_SHADOWS_HACK=1

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias onidle='sudo ionice -c3 -p$$'

alias wine32='export WINEPREFIX=/home/andrew/.wine32; export WINEARCH=win32'
alias wine64='export WINEPREFIX=/home/andrew/.wine64; export WINEARCH=win64'
wine32

alias steam-wine='wine ~/.wine64/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe -no-dwrite'

# wine reg add 'HKCU\Software\Valve\Steam' /v DWriteEnable /t REG_DWORD /d 00000000

#export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"

export GAME_DEBUGGER="$HOME/tf2"

export EDITOR=nano

alias p='ping 8.8.8.8'

#alias pacman='pacmatic'

function calc() { echo "scale=2; $@" | bc -l; }

alias x='startx'
alias game='xinit ~/newx openbox'
alias k='xinit ~/newx startkde'

alias xterm='xterm -rv'

export STEAM_FRAME_FORCE_CLOSE=1

export MONO_IOMAP=all
export SDL_MOUSE_RELATIVE=0

[[ "${PROMPT_COMMAND}" ]] && PROMPT_COMMAND="$PROMPT_COMMAND;history -a" || PROMPT_COMMAND="history -a"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# coloured prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

unset color_prompt force_color_prompt

export PATH="~/Scripts:$PATH"

EC() { echo -e '\e[1;33m'code $?'\e[m\n'; }
trap EC ERR


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#     . /etc/bash_completion
# fi
