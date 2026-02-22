#!/bin/bash

WALL_DIR="$HOME/Dosyalar/Wallpaper"
SELECTED=$(ls "$WALL_DIR" | wofi --dmenu --prompt "Duvar Kağıdı Seç:")

if [ -n "$SELECTED" ]; then
  # Fare imlecinin/odağın bulunduğu aktif monitörün adını al
  ACTIVE_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name')

  # -o parametresi ile aktif monitöre uygula
  # --transition-type fade: Solarak geçiş efekti
  # --transition-duration 1.5: Geçişin süresi (saniye cinsinden)
  # Not: fade için transition-pos parametresine gerek yoktur, kaldırdık.
  swww img "$WALL_DIR/$SELECTED" \
    -o "$ACTIVE_MONITOR" \
    --transition-type fade \
    --transition-duration 1.5
fi
