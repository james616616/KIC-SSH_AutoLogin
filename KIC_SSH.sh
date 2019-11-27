#!/bin/bash
script=KIC_SSH
ext=sh
OS=$(uname)
file=$script"-"$OS.$ext
if [ $OS == "Linux" ]; then
LOCATE=$(dirname $(readlink -f $BASH_SOURCE)) 
    DE=$XDG_CURRENT_DESKTOP
    if [ $DE == "KDE" ] ;then
        konsole --workdir $LOCATE -e sh $file
    elif [ $DE == "GNOME" ];then
        gnome-terminal --working-directory $LOCATE -e sh $file
    else xterm -e "cd $LOCATE && sh $file"
    fi
elif [ $OS == "Darwin" ]; then
    SOURCE="$(dirname $0)"
    osascript -e 'tell application "Terminal"
        activate
        do script "cd '$SOURCE' && sh 'file'"
   end tell'
else echo "NOT SUPPORTED"
fi
