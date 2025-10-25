#!/bin/bash

apt-get update -y
apt-get upgrade -y

curl https://packages.grafana.com/gpg.key | apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list

apt-get update -y

apt-get install -y software-properties-common

wget -q -O /tmp/grafana.key https://packages.grafana.com/gpg.key
apt-key add /tmp/grafana.key

apt-get install -y grafana

systemctl start grafana-server
systemctl enable grafana-server

systemctl status grafana-server
