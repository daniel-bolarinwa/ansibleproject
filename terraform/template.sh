#!/bin/bash
sudo yum install wget -y
sudo amazon-linux-extras install ansible2
sudo yum install git -y
cd /home/ec2-user/ git clone https://github.com/daniel-bolarinwa/ansibleproject.git