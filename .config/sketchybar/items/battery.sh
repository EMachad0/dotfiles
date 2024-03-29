#!/usr/bin/env sh

sketchybar --add item battery right \
           --set battery update_freq=3 \
                         icon.font="FiraCode Nerd Font:Regular:16.0" \
                         icon.color=$YELLOW \
                         script="$PLUGIN_DIR/battery.sh" \
                         background.padding_left=0
 
