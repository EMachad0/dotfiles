sketchybar --add item     time right                        \
           --add item     date right                        \
           --set date     label.font="$FONT:Black:12.0"     \
                          label.padding_right=0             \
                          background.padding_left=15        \
                          update_freq=30                    \
                          script="$PLUGIN_DIR/date.sh"      \
                                                            \
           --set time     update_freq=30                    \
                          script="$PLUGIN_DIR/time.sh"

