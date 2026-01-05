#!/usr/bin/env bash

STATE_DIR="$HOME/.cache/hypr"

WS=$(hyprctl activeworkspace -j | jq -r '.id')

if [ -f "$STATE_DIR/ws_float_$WS" ]; then
  echo "󰖯 FLOAT"
else
  echo ""
fi