# Start wpa_supplicant using configuration file:
sudo wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
# Start dhclient to assign IP address:
sudo dhclient wlp3s0
# Start the X server (graphical mode):
startx
