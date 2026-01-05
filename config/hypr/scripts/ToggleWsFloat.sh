#!/usr/bin/env bash


STATE_DIR="$HOME/.cache/hypr"
mkdir -p "$STATE_DIR"

# Workspace atual
WS=$(hyprctl activeworkspace -j | jq -r '.id')

STATE_FILE="$STATE_DIR/ws_float_$WS"

# Toggle float no workspace atual
hyprctl dispatch workspaceopt allfloat

# Toggle estado
if [ -f "$STATE_FILE" ]; then
  rm "$STATE_FILE"
else
  touch "$STATE_FILE"
fi