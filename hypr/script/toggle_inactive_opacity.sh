#!/bin/bash

# Define desired opacity values for inactive windows
OPAQUE=1.0        # Tamamen opak
TRANSPARENT=0.7   # Daha şeffaf (istediğin değeri kullanabilirsin, örn: 0.5, 0.8)

# Get the address of the active window
ACTIVE_WINDOW_ADDRESS=$(hyprctl activewindow -j | jq -r '.address')

# Get all window addresses except the active one
INACTIVE_WINDOW_ADDRESSES=$(hyprctl clients -j | jq -r ".[] | select(.address != \"$ACTIVE_WINDOW_ADDRESS\") | .address")

# Check the current opacity of one of the inactive windows to determine the toggle state
# (Assuming all inactive windows have the same current opacity setting for simplicity)
# If no inactive windows, default to opaque to avoid errors
FIRST_INACTIVE_WINDOW_ALPHA=""
if [ -n "$INACTIVE_WINDOW_ADDRESSES" ]; then
    FIRST_INACTIVE_WINDOW_ADDRESS=$(echo "$INACTIVE_WINDOW_ADDRESSES" | head -n 1)
    FIRST_INACTIVE_WINDOW_ALPHA=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$FIRST_INACTIVE_WINDOW_ADDRESS\") | .alpha")
fi

NEW_ALPHA=""
if (( $(echo "$FIRST_INACTIVE_WINDOW_ALPHA == $OPAQUE" | bc -l) )); then
    NEW_ALPHA=$TRANSPARENT
else
    NEW_ALPHA=$OPAQUE
fi

# Apply the new opacity to all inactive windows
if [ -n "$INACTIVE_WINDOW_ADDRESSES" ]; then
    for ADDR in $INACTIVE_WINDOW_ADDRESSES; do
        hyprctl setprop address:$ADDR alpha $NEW_ALPHA
    done
fi

# Not: Bu betik, aktif pencerenin saydamlığını etkilemez.
# Sadece aktif olmayan pencereleri hedefler.
