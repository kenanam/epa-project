README: WordPress Deployment with Chatbot Integration
Table of Contents
Project Description

Prerequisites

Architecture Overview

Setup & Installation

Clone the Repository

AWS CloudFormation Deployment

SSH & VSCode Remote Setup

WordPress Configuration

Chatbot Integration

CI/CD Pipeline

Security & Best Practices

Troubleshooting & FAQ

License

1. Project Description
This project demonstrates an automated deployment of a WordPress site integrated with a custom AI chatbot powered by the OpenAI API. Infrastructure is provisioned using AWS CloudFormation, while GitHub Actions manages the CI/CD pipeline. The project follows best practices for DevOps, security, and version control, ensuring a robust and scalable environment.

Key Highlights:

Automated WordPress deployment on AWS EC2 (frontend and backend).

Custom chatbot plugin using the OpenAI API for instant user support.

Security measures including AWS security groups, IAM roles, and optional Cloudflare WAF/DDos protection.

CI/CD pipeline with GitHub Actions for testing and continuous integration.

2. Prerequisites
Before deploying this project, ensure the following prerequisites are met:

AWS Account:

Sufficient permissions to create EC2 instances, security groups, IAM roles, and CloudFormation stacks.

Key Pair:

A valid SSH key pair (e.g., wordpress-auto-key) uploaded in AWS.

OpenAI API Key:

Needed for chatbot functionality. Store it securely in wp-config.php or as an environment variable.

Local Tools:

Git for cloning the repository.

Visual Studio Code (with the Remote-SSH extension) or another suitable editor to manage remote files.

AWS CLI (optional) if you want to test S3 or other AWS services locally.

3. Architecture Overview
AWS CloudFormation Template:

Creates the infrastructure, including VPC, security groups, two EC2 instances (frontend & backend), and Elastic IP associations.

Frontend EC2 Instance:

Hosts Nginx, PHP, and WordPress.

Has a reserved Elastic IP for stable access.

Backend EC2 Instance:

Runs MariaDB to store WordPress data.

Also associated with a reserved Elastic IP.

Security & Networking:

Security group rules allow inbound traffic on ports 22 (SSH), 80 (HTTP), 443 (HTTPS), and 3306 (MySQL).

[Optional] Cloudflare WAF and DNS for domain-level security.

4. Setup & Installation
4.1 Clone the Repository
bash
Copy
Edit
git clone https://github.com/<YourUsername>/wordpress-chatbot-project.git
cd wordpress-chatbot-project
This repository contains:

CloudFormation Template (e.g., wordpress-stack.yaml)

Bash Scripts for front-end and back-end setup

GitHub Actions workflow files

4.2 AWS CloudFormation Deployment
Log into the AWS Console and open CloudFormation.

Create a New Stack, uploading the wordpress-stack.yaml template.

Specify Stack Details (stack name, etc.) and watch for CREATE_COMPLETE status.

4.3 SSH & VSCode Remote Setup
Install VSCode Remote-SSH Extension on your local machine.

Add SSH Host:

plaintext
Copy
Edit
Host my-frontend
    HostName <frontend-elastic-ip>
    User ubuntu
    IdentityFile C:/Users/Kenan/Downloads/wordpress-key.pem
Connect to the Frontend Server and verify the WordPress installation.

5. WordPress Configuration
SSH into the Frontend Instance:

bash
Copy
Edit
ssh -i "C:/Users/Kenan/Downloads/wordpress-key.pem" ubuntu@<frontend-elastic-ip>
Check the Document Root:

bash
Copy
Edit
ls -l /var/www/html
Update wp-config.php:

Ensure DB_HOST, DB_USER, and DB_PASSWORD match your backend instance and credentials.

SSL Certificate (Optional):

If using Certbot, confirm the domain is set and Certbot is installed to automatically manage SSL/TLS.

6. Chatbot Integration
Create a Plugin Folder (simple-chatbot) in wp-content/plugins.

Add Plugin Files:

simple-chatbot.php (main plugin code)

css/simple-chatbot.css (styling)

js/simple-chatbot.js (JavaScript logic for AJAX calls)

Secure the OpenAI API Key:

Define SCB_OPENAI_API_KEY in wp-config.php or use an environment variable.

Activate the Plugin via the WordPress admin dashboard under Plugins.

Embed the Chatbot:

Insert the [simple_chatbot] shortcode into a page or post.

Test the Chatbot:

Visit the page, type a query, and ensure the response comes from OpenAI.

7. CI/CD Pipeline
GitHub Actions Workflow:

Checkout: Retrieves the code.

SSH Debug: Confirms the keys and IP are correct.

SED Commands: Replaces placeholders (like REPLACE_DOMAIN) with real secrets from GitHub.

SCP & SSH: Copies files and runs scripts on the EC2 instances to configure WordPress and the chatbot plugin.

Deployment:

On every commit to main (or a specific branch), the workflow triggers, ensuring continuous integration.

Monitoring:

Check the GitHub Actions tab for logs and output.

8. Security & Best Practices
Securing Keys:

Store your private key locally with restricted permissions (chmod 600).

In AWS, ensure the public key is in the Key Pair used by your instance.

OpenAI API Key:

Use wp-config.php or environment variables to avoid committing secrets to Git.

Security Groups:

Limit traffic on port 22 to your IP address (for production).

Lock down port 3306 to only the backend instance if needed.

Cloudflare WAF (Optional):

Use Cloudflare to protect your domain from malicious traffic, DDoS, and other attacks.

Automation:

The entire environment can be re-created by re-running the CloudFormation stack, ensuring an immutable infrastructure.

9. Troubleshooting & FAQ
Error establishing a database connection:

Confirm DB_HOST in wp-config.php is the backend’s IP.

Check if MariaDB is running on the backend instance.

Permission denied (public key):

Verify the correct path to your .pem file.

Adjust file permissions (chmod 600).

Nginx not found:

Re-run the bash script that installs Nginx.

Check logs (sudo tail -n 50 /var/log/cloud-init-output.log or the script log).

Chatbot not responding:

Ensure your AJAX request in JavaScript points to scb_vars.ajax_url.

Check the browser console for any JS errors.

