#!/bin/bash

# Transformation des photos
## Dépendances
sudo apt update
sudo apt install -y clang python-virtualenv python3.7 python3-dev bc imagemagick libqtgui4 libqt4-test libavcodec-extra libavformat-dev libswscale5 libatlas3-base potrace git libjasper-dev ffmpeg libzbar0

## svg2gcode
git clone https://github.com/Devfest-2020-Sigma/svg2gcode
cd svg2gcode
make
sudo cp -a svg2gcode /usr/local/bin/

## tspart
cd
git clone https://github.com/Devfest-2020-Sigma/tspart
cd tspart
cmake -B build .
cmake --build build

## Virtualenv
Folder=/usr/local ; for Package in autocrop opencv-python-headless svg_stack ; do
  sudo rm -rf ${Folder}/${Package}
  sudo virtualenv -p python3 ${Folder}/${Package}
  sudo ${Folder}/${Package}/bin/pip install --upgrade pip
  sudo ${Folder}/${Package}/bin/pip install --upgrade ${Package}
done

## Fichiers nécessaires
### Scripts
cd
git clone https://github.com/Devfest-2020-Sigma/imageconvert
cd imageconvert
sudo cp cartoon jpg2* svg_rotate.py tsp_art_tools/*.py /usr/local/bin/
sudo chmod +x /usr/local/bin/*
### fonts
sudo cp fonts\* /usr/local/share/fonts/



## SquiggleDraw
sudo apt install -y xvfb libxrender1 libxtst6
curl https://processing.org/download/install-arm.sh | sudo sh
sudo git clone https://github.com/Devfest-2020-Sigma/squiggledraw /usr/local/squiggledraw
# xvfb-run processing-java --sketch=/usr/local/squiggledraw/SquiggleDraw/ --run P1000146.jpg

## TSP
cd concorde ; ./configure ; cd LINKERN ; make
sudo cp linkern /usr/local/bin/

# Interface web
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt install -y nodejs git
sudo git clone https://github.com/Devfest-2020-Sigma/ui-devfest /usr/local/ui
# update
# cd /usr/local/ui
# sudo git pull

# npm install
cd /usr/local/ui/ms-generation-gcode ; sudo npm install  ; sudo npm run build


# AutoBoot du node
cat << EOF | sudo tee /etc/cron.d/generationgcode
@reboot root /usr/local/sbin/generationgcode
EOF
## Le script
cat << EOF | sudo tee /usr/local/sbin/generationgcode
cd /usr/local/ui/ms-generation-gcode ; sudo npm start :prod
EOF
sudo chmod +x /usr/local/sbin/generationgcode

