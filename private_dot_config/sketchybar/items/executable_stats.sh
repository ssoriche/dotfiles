#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"

cpu_percent=(
  label.font="$FONT:Heavy:12"
  label=CPU%
  label.color="$TEXT"
  icon="$CPU"
  icon.color="$BLUE"
  update_freq=2
  mach_helper="$HELPER"
)

sketchybar --add item cpu.percent right \
  --set cpu.percent "${cpu_percent[@]}"

disk=(
  label.font="$FONT:Heavy:12"
  label.color="$TEXT"
  icon="$DISK"
  icon.color="$MAROON"
  update_freq=60
  script="$PLUGIN_DIR/disk.sh"
)

sketchybar --add item disk right \
  --set disk "${disk[@]}"

memory=(label.font="$FONT:Heavy:12"
  label.color="$TEXT"
  icon="$MEMORY"
  icon.font="$FONT:Bold:16.0"
  icon.color="$GREEN"
  update_freq=15
  script="$PLUGIN_DIR/ram.sh"
)

sketchybar --add item memory right \
  --set memory "${memory[@]}"
separator_right=(
  icon=
  icon.font="$NERD_FONT:Regular:16.0"
  background.padding_left=10
  background.padding_right=15
  label.drawing=off
  click_script='sketchybar --trigger toggle_stats'
  icon.color="$TEXT"
)

sketchybar --add item separator_right right \
  --set separator_right "${separator_right[@]}"
