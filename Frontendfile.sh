#!/bin/bash

# Log file path
LOG_FILE="/var/log/script_execution.log"

log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

# Function to check the exit status of the last executed command
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed." | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 succeeded." | tee -a $LOG_FILE
    fi
}

# Clear the log file at the beginning of the script
> $LOG_FILE

# Update package lists
log "Running apt update..." 
sudo apt -y update
check_exit_status "apt update"

# Upgrade installed packages
log "Running apt upgrade..."
sudo apt -y upgrade
check_exit_status "apt upgrade"

# Install the AWS CLI tool using Snap for managing AWS resources
snap install aws-cli --classic

# Clone the GitHub repository
log "Cloning GitHub repository..."
sudo git clone https://github.com/kenanam/epa-project.git /root/wordpress-project 
check_exit_status "git clone"

# Change permissions of the cloned repository
log "Changing permissions of the cloned repository..."
sudo chmod -R 755 /root/wordpress-project
check_exit_status "chmod"

# Run the setup script
log "Running lemp-setup.sh script..."

sudo apt update -y
sudo apt upgrade -y
sudo touch /root/testing.txt # this file will contain the output of our LEMP stack unit tests
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx # this starts and enables nginx on a server reboot. The 2nd command will only run if the first command is successful
sudo systemctl status nginx > /root/testing.txt
sudo apt -y install php php-cli php-common php-imap php-fpm php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v >> /root/testing.txt
sudo systemctl stop apache2 # stops apache because we're aleady using nginx
sudo systemctl disable apache2 # disables apache from starting on a server reboot

sudo mv /var/www/html/index.html /var/www/html/index.html.old # rename apache testing page
sudo mv /root/wordpress-project/configs/nginx.conf /etc/nginx/conf.d/nginx.conf

# dns_record=$(curl -s icanhazip.com | sed 's/^/ec2-/; s/\./-/g; s/$/.compute-1.amazonaws.com/')
my_domain=REPLACE_DOMAIN
elastic_ip=REPLACE_FRONTEND_IP

# Update nginx configuration file
sed -i "s/REPLACE_DOMAIN/$my_domain/g" /etc/nginx/conf.d/nginx.conf
nginx -t && systemctl reload nginx # this will only reload nginx if the test is successful

# Update package list and install Certbot and Certbot Nginx plugin
log "Installing Certbot and Certbot Nginx plugin..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y certbot python3-certbot-nginx

# Define your email
EMAIL=REPLACE_EMAIL
DOMAIN=REPLACE_DOMAIN

# Use Certbot to obtain and install the SSL certificate
log "Obtaining and installing SSL certificate..."
sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN || {
    log "Certbot failed to obtain certificate"
    exit 1
}
# Nginx unit test that will reload Nginx to apply changes ONLY if the test is successful
sudo nginx -t && systemctl reload nginx

# Install WordPress
sudo rm -rf /var/www/html
sudo apt -y install unzip
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip
sudo mv /var/www/wordpress /var/www/html

sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 0755 {} \;
sudo find /var/www/html/ -type f -exec chmod 0644 {} \;

# Update wp-config.php with the database credentials
sed -i "s/username_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/password_here/DB_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/localhost/BACKEND_IP/g" /var/www/html/wp-config.php

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php

# Install the AWS CLI tool using Snap for managing AWS resources
snap install aws-cli --classic

# This securely backsup and stores the wp-config.php credentials on S3 
aws s3 cp /var/www/html/wp-config.php s3://my-wp-deploy-bucket

# Install chkrootkit vulnerability scanning tool.
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install chkrootkit -y

# Run chrootkit scanning tool
sudo chkrootkit > vulnerability_scan_output.txt
