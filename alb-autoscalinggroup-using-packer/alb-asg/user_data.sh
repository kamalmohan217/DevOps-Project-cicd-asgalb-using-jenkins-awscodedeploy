#!/bin/bash

sudo yum update -y
sudo yum install ruby wget -y
cd /opt
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl status codedeploy-agent
