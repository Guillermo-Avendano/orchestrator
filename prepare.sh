#!/bin/bash
#execute dos2unix
find . -name "*.yaml" -exec dos2unix {} \;
find . -name "*.sh" -exec dos2unix {} \;

sudo systemctl restart docker.service
chmod -R u+x *.sh
sudo chmod 666 //var/run/docker.sock