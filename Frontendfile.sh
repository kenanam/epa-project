#!/bin/bash
# Frontend Setup Script for WordPress and Nginx Configuration

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

# Update package lists and upgrade packages
log "Running apt update..."
sudo apt -y update
check_exit_status "apt update"

log "Running apt upgrade..."
sudo apt -y upgrade
check_exit_status "apt upgrade"

# Install AWS CLI using Snap
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

# ===== Variable Declarations =====
# Use a single domain variable: my_domain.
my_domain=REPLACE_DOMAIN
# (Optional: if you do not need elastic_ip, you can remove this line)
elastic_ip=REPLACE_FRONTEND_IP

# Note: We rely on the GitHub Actions workflow to perform substitutions in our files.
# Therefore, we have removed duplicate sed substitutions from this script.

# ===== Set FastCGI Timeout Settings =====
# Append FastCGI timeout directives to nginx.conf if not already present.
if ! grep -q "fastcgi_read_timeout" /etc/nginx/conf.d/nginx.conf; then
  echo "fastcgi_read_timeout 300;" | sudo tee -a /etc/nginx/conf.d/nginx.conf
  echo "fastcgi_send_timeout 300;" | sudo tee -a /etc/nginx/conf.d/nginx.conf
  echo "fastcgi_connect_timeout 300;" | sudo tee -a /etc/nginx/conf.d/nginx.conf
fi

# Test and reload Nginx to apply changes
sudo nginx -t && sudo systemctl reload nginx

log "Installing Certbot and Certbot Nginx plugin..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y certbot python3-certbot-nginx

# ===== Use my_domain for Certbot =====
EMAIL=REPLACE_EMAIL
# Certbot will use $my_domain for the domain, ensuring consistency.
log "Obtaining and installing SSL certificate..."
sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $my_domain || {
    log "Certbot failed to obtain certificate"
    exit 1
}
sudo nginx -t && sudo systemctl reload nginx

# Install WordPress
sudo rm -rf /var/www/html
sudo apt -y install unzip
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip
sudo mv /var/www/wordpress /var/www/html

# This is the line to install my thg-chatbot
aws s3 cp s3://my-wp-deploy-bucket/thg-chatbot /var/www/html/wp-content/plugins/thg-chatbot --recursive
aws s3 cp s3://my-wp-deploy-bucket/blocksy /var/www/html/wp-content/themes/blocksy --recursive

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

# Insert WordPress secret keys
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php

# Install AWS CLI using Snap (if needed)
snap install aws-cli --classic

# Securely back up wp-config.php to S3
aws s3 cp /var/www/html/wp-config.php s3://my-wp-deploy-bucket

# Install chkrootkit vulnerability scanning tool and run it
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install chkrootkit -y
sudo chkrootkit > vulnerability_scan_output.txt
