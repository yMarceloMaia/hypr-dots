PID=$(pidof xdg-desktop-portal-hyprland)

if [ -n "$PID" ] && ls -l /proc/$PID/fd 2>/dev/null | grep -q pipewire; then
  echo " 󰄄  "
else
  echo ""
fi