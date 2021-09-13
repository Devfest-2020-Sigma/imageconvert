#!/bin/bash

# MAJ du système
sudo apt update
sudo apt upgrade -y

# Installation des prérequis
sudo apt install -y openjdk-11-jre python3-pip git

wget "https://ugs.jfrog.io/ui/api/v1/download?repoKey=UGS&path=v2.0.8%252FUniversalGcodeSender.zip" -O UniversalGcodeSender.zip
unzip UniversalGcodeSender.zip
sudo mv UniversalGcodeSender.jar /usr/local/

# AutoBoot du UniversalGcodeSender
## Le cron
cat << EOF | sudo tee /etc/cron.d/java
@reboot root /usr/local/sbin/ugcs
EOF
## Le script
cat << EOF | sudo tee /usr/local/sbin/ugcs
#!/bin/bash

if lsusb | grep -q 'ID 2341:0043' ; then
  Port=/dev/ttyACM0
elif lsusb | grep -q 'ID 0403:6001' ; then
  Port=/dev/ttyUSB0
else
  echo Please investigate on com port
  exit 42
fi

java -Xmx512m -cp /usr/local/UniversalGcodeSender.jar com.willwinder.ugs.cli.TerminalClient --controller GRBL --port ${Port} --baud 115200 --print-progressbar --driver JSSC --daemon
EOF

sudo chmod +x /usr/local/sbin/ugcs

sudo git clone https://github.com/Devfest-2020-Sigma/ui-devfest /usr/local/ui
cat << EOF | sudo tee /etc/cron.d/impressiongcode
@reboot root /usr/local/sbin/impressiongcode
EOF

## Le script
cat << EOF | sudo tee /usr/local/sbin/impressiongcode
cd /usr/local/ui/ms-impression-gcode ; sudo npm install ; sudo npm run build ; sudo npm start
EOF

sudo chmod +x /usr/local/sbin/impressiongcode
