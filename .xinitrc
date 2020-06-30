# Set clock in root window name
while true; do
    xsetroot -name "$(date +"%H:%M %A %d %B %Y")"
    sleep 30s
done &

# Set wallpaper
xwallpaper --zoom ~/.local/share/wallpaper/wallpaper.png &

# Start dwm window manager
ssh-agent dwm
