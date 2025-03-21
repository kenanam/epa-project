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

# (Git clone and permission changes are handled by GitHub Actions)

log "Running lemp-setup.sh script..."

sudo apt update -y
sudo apt upgrade -y
sudo touch /root/testing.txt  # LEMP stack unit tests output
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx
sudo systemctl status nginx > /root/testing.txt
sudo apt -y install php php-cli php-common php-imap php-fpm php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v >> /root/testing.txt
sudo systemctl stop apache2    # Stop Apache since we're using Nginx
sudo systemctl disable apache2   # Disable Apache from rebooting

sudo mv /var/www/html/index.html /var/www/html/index.html.old  # Rename Apache test page

# Move the nginx.conf from the repository to Nginx's configuration directory
sudo mv /home/ubuntu/epa-project/nginx.conf /etc/nginx/conf.d/nginx.conf

# ===== Change Starts Here =====
# Use a single domain variable: my_domain
my_domain=REPLACE_DOMAIN
# (Optional: if you do not need elastic_ip in your script, you may remove or ignore this line)
elastic_ip=REPLACE_FRONTEND_IP

# Instead of performing a substitution here, rely on the workflow to replace placeholders.
# Remove or comment out the following two lines if using centralized workflow substitutions:
# sed -i "s/REPLACE_DOMAIN/$my_domain/g" /etc/nginx/conf.d/nginx.conf
# nginx -t && systemctl reload nginx
# ===== Change Ends Here =====

log "Installing Certbot and Certbot Nginx plugin..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y certbot python3-certbot-nginx

# ===== Change Starts Here =====
# Use my_domain for Certbot instead of a separate DOMAIN variable.
EMAIL=REPLACE_EMAIL
# Remove the separate DOMAIN variable declaration; use my_domain in its place.
# DOMAIN=REPLACE_DOMAIN
# Now, update Certbot to use $my_domain:
log "Obtaining and installing SSL certificate..."
sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $my_domain || {
    log "Certbot failed to obtain certificate"
    exit 1
}
# ===== Change Ends Here =====

# Nginx unit test to reload Nginx if the test is successful
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

# Update wp-config.php with database credentials and backend IP
sed -i "s/username_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/password_here/DB_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/localhost/BACKEND_IP/g" /var/www/html/wp-config.php

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php

# Install the AWS CLI tool using Snap (if needed)
snap install aws-cli --classic

# Securely back up wp-config.php to S3
aws s3 cp /var/www/html/wp-config.php s3://my-wp-deploy-bucket

# Install chkrootkit vulnerability scanning tool and run it
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install chkrootkit -y
sudo chkrootkit > vulnerability_scan_output.txt
