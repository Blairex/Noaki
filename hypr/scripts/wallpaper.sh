#!/usr/bin/env bash

THEMES="$HOME/.config/hypr/themes"
THEME=$(cat "$THEMES/current")
DIR="$THEMES/$THEME/wallpapers"
CACHE="$HOME/.cache/wallpaper-thumbnails"

mkdir -p "$CACHE"

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

    name=$(while IFS= read -r f; do
        hash=$(printf '%s' "$f" | sha256sum | cut -d' ' -f1)
        thumb="$CACHE/$hash.jpg"

        if [[ ! -f "$thumb" ]]; then
            magick "${f}[0]" -thumbnail '440x300>' -strip -quality 75 "$thumb"
        fi

        printf '%s\0icon\x1f%s\n' "$(basename "$f")" "$thumb"
    done < <(list | sort) |
        rofi -dmenu -show-icons -no-custom -theme-str "$LAYOUT")

    [ -z "$name" ] && exit 0
    img="$DIR/$name"
fi

[ -z "$img" ] && exit 0

awww img "$img" --transition-type center --transition-duration 1.5 --transition-fps 60