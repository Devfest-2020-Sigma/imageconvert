#!/bin/bash

# Transformation des photos
## Dépendances
sudo apt update
sudo apt upgrade -y

sudo apt install -y python-virtualenv python3.7 python3-dev bc imagemagick libqtgui4 libqt4-test libavcodec-extra libavformat-dev libswscale5 libatlas3-base potrace git libjasper-dev ffmpeg libzbar0

## Virtualenv
Folder=/usr/local ; for Package in autocrop opencv-python-headless svg_stack ; do
  sudo rm -rf ${Folder}/${Package}
  sudo virtualenv -p python3 ${Folder}/${Package}
  sudo ${Folder}/${Package}/bin/pip install --upgrade pip
  sudo ${Folder}/${Package}/bin/pip install --upgrade ${Package}
done

# Ajout de module python dans opencv-python-headless
Folder=/usr/local
sudo ${Folder}/opencv-python-headless/bin/pip install --upgrade pyzbar imutils picamera

## Fichiers nécessaires
### Scripts
cd
git clone https://github.com/Devfest-2020-Sigma/imageconvert
cd imageconvert
sudo cp cartoon jpg2* svg_rotate.py tsp_art_tools/*.py /usr/local/bin/
sudo chmod +x /usr/local/bin/*
### fonts
sudo cp fonts/* /usr/local/share/fonts/


## SquiggleDraw
sudo apt install -y xvfb libxrender1 libxtst6

cd ; wget https://github.com/processing/processing/releases/download/processing-0269-3.5.3/processing-3.5.3-linux-armv6hf.tgz
tar xzf processing-3.5.3-linux-armv6hf.tgz
cd processing-3.5.3/ ; sudo ./install.sh
sudo git clone https://github.com/Devfest-2020-Sigma/squiggledraw /usr/local/squiggledraw
# xvfb-run processing-java --sketch=/usr/local/squiggledraw/SquiggleDraw/ --run P1000146.jpg

## TSP
cd ~/imageconvert
sudo cp tsp_art_tools/*.py jpg2tsp /usr/local/bin/
sudo chmod +x /usr/local/bin/{tspart.py,tspbitcity.py,tspsolution.py,jpg2tsp}
git clone https://github.com/matthelb/concorde.git ~/concorde
cd ~/concorde ; ./configure ; cd LINKERN ; make
sudo cp linkern /usr/local/bin/

# Interface web
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt install -y mongodb-server rabbitmq-server nodejs git

sudo rabbitmqctl add_user admin admin

sudo rabbitmqctl set_user_tags admin administrator

sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

sudo rabbitmq-plugins enable rabbitmq_management

sudo rabbitmqadmin declare queue name=impression-robots durable=true

sudo rabbitmqadmin declare queue name=integration-robots durable=true

sudo git clone https://github.com/Devfest-2020-Sigma/ui-devfest /usr/local/ui
# update
# cd /usr/local/ui
# sudo git pull

# npm install
cd /usr/local/ui/backend-devfest ; sudo npm install ; sudo npm run build
cd /usr/local/ui/websocket ; sudo npm install ws 
cd /usr/local/ui/front-devfest ; sudo npm install ; sudo npm run build
cd /usr/local/ui/ms-impression-gcode ; sudo npm install  ; sudo npm run build


# AutoBoot du node
## Le cron
cat << EOF | sudo tee /etc/cron.d/backend
@reboot root /usr/local/sbin/backend
EOF
## Le script
cat << EOF | sudo tee /usr/local/sbin/backend
#!/bin/bash
cd /usr/local/ui/backend-devfest ; sudo npm start :prod
EOF
sudo chmod +x /usr/local/sbin/backend

## Le cron
cat << EOF | sudo tee /etc/cron.d/websocket
@reboot root /usr/local/sbin/websocket
EOF
## Le script
cat << EOF | sudo tee /usr/local/sbin/websocket
#!/bin/bash
cd /usr/local/ui/websocket ; sudo ./start.sh
EOF
sudo chmod +x /usr/local/sbin/websocket

cat << EOF | sudo tee /etc/cron.d/frontend
@reboot root /usr/local/sbin/frontend
EOF
## Le script
cat << EOF | sudo tee /usr/local/sbin/frontend
#!/bin/bash
cd /usr/local/ui/front-devfest ; sudo npm start
EOF
sudo chmod +x /usr/local/sbin/frontend

# Kiosk
sudo apt install -y unclutter chromium

cat << EOF | sudo tee /etc/xdg/lxsession/LXDE-pi/autostart
xset s off
xset s noblank
xset -dpms

@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@unclutter
#@xscreensaver -no-splash

@sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
@sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
@/usr/local/bin/LaunchWhenReady
EOF

cat << EOF | sudo tee /usr/local/bin/LaunchWhenReady
#!/bin/bash
while ! netcat -z -w 5 127.0.0.1 4200 ; do
  sleep 5s
done
/usr/bin/chromium --kiosk --incognito --overscroll-history-navigation=0 http://127.0.0.1:4200
EOF
sudo chmod +x /usr/local/bin/LaunchWhenReady

cat > /usr/share/dispsetup.sh << EOF
#!/bin/sh
if ! grep -q 'Raspberry Pi' /proc/device-tree/model || (grep -q okay /proc/device-tree/soc/v3d@7ec00000/status 2> /dev/null || grep -q okay /proc/device-tree/soc/firmwarekms@7e600000/status 2> /dev/null || grep -q okay /proc/device-tree/v3dbus/v3d@7ec04000/status 2> /dev/null) ; then
if xrandr --output HDMI-1 --primary --mode 1600x900 --rate 60.00 --pos 0x0 --rotate left --dryrun ; then 
xrandr --output HDMI-1 --primary --mode 1600x900 --rate 60.00 --pos 0x0 --rotate left
fi
fi
if [ -e /usr/share/tssetup.sh ] ; then
. /usr/share/tssetup.sh
fi
EOF

# A faire automatiquement :
# dans /usr/share/X11/xorg.conf.d/40-libinput.conf
#   Identifier "libinput touchscreen catchall"
# ajouter
#   Option "TransformationMatrix" "0 -1 1 1 0 0 0 0 1"
