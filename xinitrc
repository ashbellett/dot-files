# ~/.xinitrc
# Ash Bellett

# Define resolution:
xrandr --output Virtual1 --mode 1360x768

# Load X settings:
xrdb -merge ~/.Xresources

# Name root window:
xsetroot -name "Ash"

# Set wallpaper:
feh --bg-fill ~/.wallpaper/wallpaper.png

# Begin compositor:
compton --config ~/.config/compton/compton.conf -b

# Start window manager:
exec dwm
