#!/bin/bash

# Update the package list and install necessary dependencies
sudo apt update
sudo apt install -y unzip nginx openjdk-11-jre

# Define SonarQube version
SONARQUBE_VERSION=8.9.0.43852

# Download SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip

# Unzip the downloaded package
unzip sonarqube-${SONARQUBE_VERSION}.zip -d /opt

# Rename the directory for simplicity
sudo mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube

# Create a system service for SonarQube
echo "[Unit]
Description=SonarQube service
After=network.target network-online.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonarqube.service

# Create a dedicated system user for SonarQube
sudo useradd -r sonarqube -d /opt/sonarqube

# Set file permissions
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Reload system service manager
sudo systemctl daemon-reload

# Start and enable the SonarQube service
sudo systemctl start sonarqube
sudo systemctl enable sonarqube

# Enable SonarQube to start on boot
sudo systemctl enable sonarqube

# Allow SonarQube through the firewall
sudo ufw allow 9000

# Configure Nginx for SonarQube
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

echo "server {
  listen 80;
  server_name your_domain.com;  # Change to your domain name or IP address

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://127.0.0.1:9000;  # SonarQube listens on port 9000
  }

  location /api/system/status {
    proxy_pass http://127.0.0.1:9000;  # SonarQube listens on port 9000
  }
}" | sudo tee /etc/nginx/sites-available/sonarqube
sudo ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Inform the user about the setup
echo "SonarQube has been successfully installed and configured to work behind Nginx."
echo "Access the SonarQube web interface at http://your_domain.com"

# Clean up downloaded files
rm sonarqube-${SONARQUBE_VERSION}.zip
