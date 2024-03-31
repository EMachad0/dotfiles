#!/usr/bin/env sh

TITLE=$(yabai -m query --windows --window | jq -r '.app')
sketchybar --set $NAME label="$TITLE"

