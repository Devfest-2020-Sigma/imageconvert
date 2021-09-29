#!/bin/bash

# MAJ du système
sudo apt update
sudo apt upgrade -y

# Installation des prérequis
sudo apt install -y openjdk-11-jre python3-pip git clang tmux

## svg2gcode
git clone https://github.com/Devfest-2020-Sigma/svg2gcode
cd svg2gcode
make
sudo cp -a svg2gcode /usr/local/bin/

wget "https://ugs.jfrog.io/ui/api/v1/download?repoKey=UGS&path=v2.0.8%252FUniversalGcodeSender.zip" -O UniversalGcodeSender.zip
unzip UniversalGcodeSender.zip UniversalGcodeSender.jar
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

/usr/bin/tmux new-session -d -s ugcs 'java -Xmx512m -cp /usr/local/UniversalGcodeSender.jar com.willwinder.ugs.cli.TerminalClient --controller GRBL --port ${Port} --baud 115200 --print-progressbar --driver JSSC --daemon'
EOF

sudo chmod +x /usr/local/sbin/ugcs

# Inscription auto du robot dans la file d'attente
## Le cron
cat << EOF | sudo tee /etc/cron.d/inscriptionrobot
@reboot root /usr/local/sbin/InscriptionRobot
EOF
cat << EOF | sudo tee /usr/local/sbin/InscriptionRobot
#!/bin/bash

myIP=$(hostname -I)

rabbitmqadmin publish exchange=amq.default routing_key=integration-robots payload="{\"pattern\":\"integration-robot\",\"data\":{\"message\":{\"ip\":\"${myIP}\"},\"__EVENT_NAME\":\"RobotRabbitEvent\",\"__TRANSPORTS\":[5]}}" --host=192.168.88.201 --username=admin --password=admin
EOF
