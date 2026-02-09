#!/bin/bash

# --- AYARLAR ---
# 'hyprctl monitors' yazarak kendi monitör isimlerini öğrenip buraya yazmalısın.
MON_1="DP-3"     # Ana Monitör (Workspace 1-10)
MON_2="HDMI-A-1" # İkinci Monitör (Workspace 11-20)
OFFSET=10        # İkinci monitör için kaydırma miktarı
# ----------------

target=$1
action=$2 # "sync", "move" veya boş

# Aktif monitörü bul (jq gereklidir: sudo pacman -S jq)
active_mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# İkinci monitör için hedef workspace numarasını hesapla
target_sec=$(($target + $OFFSET))

if [ "$action" == "move" ]; then
  # --- PENCERE TAŞIMA MODU ---
  if [ "$active_mon" == "$MON_2" ]; then
    hyprctl dispatch movetoworkspace $target_sec
  else
    hyprctl dispatch movetoworkspace $target
  fi

elif [ "$action" == "sync" ]; then
  # --- SENKRONİZE GEÇİŞ MODU ---
  # Aktif ekranın odağını korumak için önce diğerini, sonra aktifi değiştiriyoruz
  if [ "$active_mon" == "$MON_1" ]; then
    hyprctl dispatch workspace $target_sec
    hyprctl dispatch workspace $target
  else
    hyprctl dispatch workspace $target
    hyprctl dispatch workspace $target_sec
  fi

else
  # --- NORMAL GEÇİŞ MODU ---
  if [ "$active_mon" == "$MON_2" ]; then
    hyprctl dispatch workspace $target_sec
  else
    hyprctl dispatch workspace $target
  fi
fi
