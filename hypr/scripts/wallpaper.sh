#!/usr/bin/env bash
THEMES="$HOME/.config/hypr/themes"
THEME=$(cat "$THEMES/current")
DIR="$THEMES/$THEME/wallpapers"

list() {
  find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \)
}

if [ "$1" = "random" ]; then
  img=$(list | shuf -n1)
else
  LAYOUT='
    window { width: 1000px; }
    mainbox { children: [ listview ]; }
    listview {
      columns: 4;
      lines: 1;
      fixed-columns: true;
      spacing: 10px;
      scrollbar: false;
      cycle: true;
    }
    element { orientation: vertical; padding: 8px; }
    element-icon { size: 220px; }
    element-text { enabled: false; }
  '

  name=$(list | sort | while IFS= read -r f; do
      printf '%s\0icon\x1f%s\n' "$(basename "$f")" "$f"
    done | rofi -dmenu -show-icons -no-custom -theme-str "$LAYOUT")

  [ -z "$name" ] && exit 0
  img="$DIR/$name"
fi

[ -z "$img" ] && exit 0
awww img "$img" --transition-type center --transition-duration 1.5 --transition-fps 60