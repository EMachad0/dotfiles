#!/usr/bin/env sh

TITLE=$(yabai -m query --windows --window | jq -r '.title')
sketchybar --set $NAME label="$INFO - $TITLE"

