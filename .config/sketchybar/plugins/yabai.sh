#!/bin/sh

window_state() {
    source "$HOME/.config/sketchybar/colors.sh"
    source "$HOME/.config/sketchybar/icons.sh"

    WINDOW=$(yabai -m query --windows --window)
    CURRENT=$(echo "$WINDOW" | jq '.["stack-index"]')

    args=()
    if [[ $CURRENT -gt 0 ]]; then
        LAST=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
        args+=(--set $NAME icon=$YABAI_STACK icon.color=$RED label.drawing=on label=$(printf "[%s/%s]" "$CURRENT" "$LAST"))
    else 
        args+=(--set $NAME label.drawing=off)
        case "$(echo "$WINDOW" | jq '.["is-floating"]')" in
            "false")
                if [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
                    args+=(--set $NAME icon=$YABAI_FULLSCREEN_ZOOM icon.color=$GREEN)
                elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
                    args+=(--set $NAME icon=$YABAI_PARENT_ZOOM icon.color=$BLUE)
                else
                    args+=(--set $NAME icon=$YABAI_GRID icon.color=$ORANGE)
                fi
                ;;
            "true")
                args+=(--set $NAME icon=$YABAI_FLOAT icon.color=$MAGENTA)
                ;;
        esac
    fi

    sketchybar -m "${args[@]}"
}

windows_on_spaces () {
    source "$HOME/.config/sketchybar/icon_map.sh"

    CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

    args=()
    while read -r line
    do
        for space in $line
        do
            icon_strip=" "
            apps=$(yabai -m query --windows --space $space | jq -r ".[].app")
            if [ "$apps" != "" ]; then
                while IFS= read -r app_name; do
                    __icon_map "${app_name}"
                    icon_strip+=" ${icon_result}"
                done <<< "$apps"
            fi
            args+=(--set space.$space label="$icon_strip" label.drawing=on)
        done
    done <<< "$CURRENT_SPACES"

    sketchybar -m "${args[@]}"
}

mouse_clicked() {
    # yabai -m window --toggle float
    window_state
}

case "$SENDER" in
    "mouse.clicked") mouse_clicked
        ;;
    "forced") exit 0
        ;;
    "window_focus") window_state 
        ;;
    "windows_on_spaces") windows_on_spaces
        ;;
esac

