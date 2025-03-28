#!/bin/bash
# Backend Setup Script for WordPress Database
# -----------------------------------------------------
# This script installs and configures MariaDB for our WordPress backend.
# It creates a dedicated database and user, updates the WordPress configuration,
# and backs up the credentials and database dump to an S3 bucket.
#
# IMPORTANT:
# - Ensure you have created the S3 bucket (e.g., s3://my-wp-deploy-bucket).
# - Replace placeholders (REPLACE_DBUSERNAME, REPLACE_DBPASSWORD, REPLACE_FRONTEND_IP)
#   with your actual values.
# - Confirm that /var/www/html/wp-config.php is the correct path for your WordPress config file.
# - For your backend instance, the public IP is: 13.43.103.133

# 1. Update and upgrade system packages.
sudo apt -y update && sudo apt -y upgrade

# 2. Install the AWS CLI using Snap to interact with AWS services.
snap install aws-cli --classic

# 3. Install MariaDB server and client packages.
sudo apt install mariadb-server mariadb-client -y

# 4. Change MariaDB's bind-address so that it listens on all network interfaces.
sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# 5. Restart MariaDB to apply the configuration changes.
mysqladmin ping && sudo systemctl restart mariadb

# 6. Set fixed credentials for the WordPress database.
#    We are using preset secrets (not random generated values).
username=DB_USERNAME    # Replace with your chosen database username - now correct
password=DB_PASSWORD    # Replace with your chosen database password - now correct

# 7. Save these credentials to a file (creds.txt) for backup and future reference.
echo $password > /home/ubuntu/creds.txt
echo $username >> /home/ubuntu/creds.txt

# 8. Create a new database for WordPress using the username as the database name.
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"

# 9. Create a new MariaDB user that can connect from your frontend server.
#    Replace REPLACE_FRONTEND_IP with your actual frontend instance IP.
sudo mysql -e "CREATE USER IF NOT EXISTS '$username'@'FRONTEND_IP' IDENTIFIED BY '$password'"

# 10. Grant the new user full privileges on their database.
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'FRONTEND_IP'"

# 11. Refresh MariaDB privileges to apply the changes immediately.
sudo mysql -e "FLUSH PRIVILEGES"

# 12. Update the WordPress configuration file with the new database credentials.
#     Make sure that /var/www/html/wp-config.php is the correct location.
#sudo sed -i "s/password_here/$password/g" /var/www/html/wp-config.php
#sudo sed -i "s/username_here/$username/g" /var/www/html/wp-config.php
#sudo sed -i "s/database_name_here/$username/g" /var/www/html/wp-config.php

# 13. Back up the credentials file (creds.txt) to your S3 bucket.
aws s3 cp /home/ubuntu/creds.txt s3://my-wp-deploy-bucket

# 14. Create a backup of your database and store it on S3.
#     (When prompted for the MySQL root password, enter the correct password.)
# mysqldump -u root -p $username > /tmp/wordpressDB.sql
# aws s3 cp /tmp/wordpressDB.sql s3://my-wp-deploy-bucket

15. (Optional) Restore commands for your database (commented out for now):
aws s3 cp s3://my-wp-deploy-bucket/wpdb.sql /tmp/wpdb.sql
sudo mysql $username < /tmp/wpdb.sql

# 16. (The IAM Role creation instructions are moved to the README for clarity.)
