#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
# From /etc/skel/.xinitrc

# ssh-add
eval $(gpg-agent --enable-ssh-support --daemon)

# Source all the files

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi
