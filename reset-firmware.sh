#!/bin/bash

IP=$1

[ "xxx$1" == "xxx" ] && echo "Missing IP" && exit 1
unset http_proxy

curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$21 = 0"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$100 = 77.000"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$101 = 77.000"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$110 = 20000.000"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$111 = 20000.000"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$120 = 8000.000"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$121 = 8000.000"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$130 = 220.000"}'
sleep 1
curl "http://${IP}:8080/api/v1/machine/sendGcode" -H 'Content-Type: application/json' --data-raw '{"commands":"$131 = 220.000"}'
