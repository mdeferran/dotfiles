add gopass
add rclone

add docker
```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Add keyboard configuration (/etc/default/keyboard)
```
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT="altgr-intl"
XKBOPTIONS="lv3:ralt_switch,terminate:ctrl_alt_bksp"

BACKSPACE="guess"
```

Unmute with alsamixer
```
$ amixer sset Master unmute
$ amixer sset Speaker unmute
$ amixer sset Headphone unmute
```

install vlc
```
sudo apt install --no-install-recommends vlc
```

install chrome
```
cat <<-EOF | sudo tee /etc/apt/sources.list.d/google-chrome.list
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF
curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt update
sudo apt install -y bluez google-chrome-stable i3 i3lock i3status pulseaudio pulseaudio-module-bluetooth pulsemixer
```

install vscode
```
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg\nsudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get update
sudo apt-get install code
```

fix SSH agent `sign_and_send_pubkey: signing failed for RSA gpg-agent`
```
journalctl -f

seems to be related with the pinentry program
gpg-connect-agent updatestartuptty /bye > /dev/null

sudo apt install pinentry-gtk2
sudo update-alternatives --config pinentry
```

add gopass completion
```
sudo cp zsh.completion /usr/share/zsh/vendor-completions/_gopass
rm ~/.zcompdump;compinit
```

Set timezone
```
sudo timedatectl set-timezone Europe/Paris
```

Install VPN
```
sudo apt install openvpn wireguard

```

Others
```
apt install tree pwgen
```
