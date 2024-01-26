#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
echo "<h1>Hello world from highly available group of ec2 instances</h1>" > /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd
