#!/bin/bash

# Transformation des photos
## Dépendances
sudo apt update
sudo apt install -y build-essential cmake python3 python3-virtualenv python3-dev python3-pip make bc imagemagick  libavcodec-extra libavformat-dev libswscale5 libatlas3-base potrace git  ffmpeg libzbar0
sudo apt install -y curl libxrandr-dev libx11-dev libopencv-dev libopengl-dev freeglut3-dev libudev-dev libfreetype-dev libopenal-dev libvorbis-dev libflac-dev net-tools ncdu tmux python

sudo virtualenv -p python2.7 /usr/local/svg
sudo /usr/local/svg/bin/pip install --upgrade pip
sudo /usr/local/svg/bin/pip install lxml argparse svgutils

# libqt5gui5 libjasper

## tspart
cd
git clone https://github.com/Devfest-2020-Sigma/tspart --recursive
cd tspart
cmake -B build .
cmake --build build

## Virtualenv
Folder=/usr/local ; for Package in svg_stack ; do
  sudo rm -rf ${Folder}/${Package}
  sudo virtualenv -p python3 ${Folder}/${Package}
  sudo ${Folder}/${Package}/bin/pip install --upgrade pip
  sudo ${Folder}/${Package}/bin/pip install --upgrade ${Package}
  sudo ${Folder}/${Package}/bin/pip install --upgrade lxml six
done

## Fichiers nécessaires
### Scripts
cd
git clone https://github.com/Devfest-2020-Sigma/imageconvert
cd imageconvert
sudo cp cartoon jpg2* svg_rotate.py tsp_art_tools/*.py /usr/local/svg/bin/
sudo cp svg_rotate.py tsp_art_tools/*.py /usr/local/svg/bin/
sudo chmod +x /usr/local/bin/* /usr/local/svg/bin/
### fonts
sudo cp fonts/* /usr/local/share/fonts/

## SquiggleDraw
sudo apt install -y xvfb libxrender1 libxtst6
wget https://github.com/processing/processing/releases/download/processing-0270-3.5.4/processing-3.5.4-linux64.tgz
tar -zxf processing-3.5.4-linux64.tgz
sudo mv processing-3.5.4 /usr/local/
sudo ln -sf /usr/local/processing-3.5.4/ /usr/local/processing

sudo git clone https://github.com/Devfest-2020-Sigma/squiggledraw /usr/local/squiggledraw
# xvfb-run processing-java --sketch=/usr/local/squiggledraw/SquiggleDraw/ --run P1000146.jpg

## TSP
git clone https://github.com/matthelb/concorde.git ~/concorde
cd ~/concorde ; ./configure ; cd LINKERN ; make -j2
sudo cp linkern /usr/local/bin/


# Interface web
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt install -y nodejs
sudo git clone https://github.com/Devfest-2020-Sigma/ui-devfest /usr/local/ui
# update
# cd /usr/local/ui
# sudo git pull

# npm install
cd /usr/local/ui/ms-generation-gcode ; sudo npm install  ; sudo npm run build


# AutoBoot du node
cat << EOF | sudo tee /etc/cron.d/impressiongcode
@reboot root /usr/local/sbin/impressiongcode
EOF

## Le script
cat << EOF | sudo tee /usr/local/sbin/impressiongcode
/usr/bin/tmux new-session -d -s ms-impression-gcode -c /usr/local/ui/ms-impression-gcode 'sudo npm start'
EOF

sudo chmod +x /usr/local/sbin/impressiongcode
