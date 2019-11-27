#!/bin/bash
script=KIC_SSH
ext=sh
OS=$(uname)
file=$ext" "$script"-"$OS.$ext
if [ $OS == "Linux" ]; then
LOCATE=$(dirname $(readlink -f $BASH_SOURCE)) 
    DE=$XDG_CURRENT_DESKTOP
    if [ $DE == "KDE" ] ;then
        konsole --workdir $LOCATE -e $file
    elif [ $DE == "GNOME" ];then
        gnome-terminal --working-directory $LOCATE -e $file
    else xterm -e "cd $LOCATE && $ext $file"
    fi
elif [ $OS == "Darwin" ]; then
    SOURCE="$(dirname $0)"
    osascript -e 'tell application "Terminal"
        activate
        do shell script "cd '$SOURCE' && sh '$file'"
    end tell'
else echo "NOT SUPPORTED"
fi
