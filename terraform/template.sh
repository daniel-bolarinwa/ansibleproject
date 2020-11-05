#!/bin/bash
sudo yum install wget -y
sudo amazon-linux-extras install nginx1 -y
sudo nginx
sudo yum install ansible -y