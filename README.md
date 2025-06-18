# 📌 WordPress E-commerce Chatbot Deployment

This repository contains Infrastructure-as-Code (IaC) templates, automated deployment scripts, and comprehensive documentation for deploying a scalable WordPress e-commerce website integrated with an AI-powered chatbot on AWS.

---

## 🚀 Project Overview

The project leverages modern DevOps practices, including AWS CloudFormation for infrastructure provisioning, GitHub Actions for CI/CD automation, Cloudflare for enhanced security, AWS CloudWatch for real-time monitoring, and MariaDB for database management with automated backups stored securely in AWS S3.

---

## 🌟 Key Features

- **Infrastructure Automation:** AWS CloudFormation provisions immutable and consistent AWS environments.
- **CI/CD Automation:** GitHub Actions ensure frequent integration, testing, and deployments.
- **Robust Security:** SSL encryption and DDoS protection managed by Cloudflare.
- **Real-time Monitoring:** AWS CloudWatch configured for logs, metrics, and proactive alerts.
- **Reliable Data Persistence:** MariaDB provides efficient data management with automated backups to AWS S3.
- **User-centric Development:** Clear user stories documented within GitHub Issues.

---

## 📂 Repository Structure


---

## 🛠️ Technology Stack

| Area                    | Technology                      |
|-------------------------|---------------------------------|
| Infrastructure as Code  | AWS CloudFormation              |
| Database                | MariaDB                         |
| Security                | Cloudflare SSL & DDoS           |
| CI/CD Pipeline          | GitHub Actions                  |
| Monitoring & Logging    | AWS CloudWatch                  |
| Backup Storage          | AWS S3                          |
| Testing Framework       | Jest                            |
| Automation Scripts      | Bash                            |

---

## 📋 User Stories (GitHub Issues Examples)

User stories clearly define project requirements and acceptance criteria. Examples:

- [Infrastructure Setup via CloudFormation](#)
- [Automated CI/CD Pipeline](#)
- [Website Security with Cloudflare](#)
- [Monitoring with AWS CloudWatch](#)
- [Database Backup Automation](#)



---

## 📌 Project Analysis (300 words)

This project demonstrates the automated deployment and management of a WordPress e-commerce website with an AI chatbot, utilising AWS CloudFormation for immutable infrastructure provisioning. It provides two EC2 instances: a frontend server running WordPress with the chatbot plugin, and a backend server hosting a MariaDB database, ensuring consistent, scalable deployments (K7, S18, K12, S7, K8, S5).

Continuous integration and deployment are fully automated through GitHub Actions, including unit tests with Jest, significantly enhancing code quality, accelerating deployment cycles, and reducing manual intervention (K1, K14, K15, S14, S15). Collaboration is efficiently managed through Git branching and pull requests, ensuring transparent development workflows (K2, S20).

Security and data protection are effectively addressed through Cloudflare's SSL encryption, DDoS mitigation, and proactive threat monitoring, integrated seamlessly into workflows (K5, K16, K17, S9, S10). AWS CloudWatch delivers comprehensive monitoring, collecting detailed metrics and logs, and configured with proactive alerting for rapid issue identification and resolution (K11, S6, S19).

MariaDB handles data persistence reliably, with automated backups securely stored in AWS S3, supporting robust disaster recovery strategies (K12). Automation scripts written in Bash streamline the installation and configuration processes, reducing errors and manual workload (K13, S12, S17).

Clearly articulated user stories managed via GitHub Issues ensure user needs and acceptance criteria are transparently understood and accurately delivered (K10, S3). Incremental refactoring via controlled commits improves architecture stability and functionality over time without disruption (S22). Adopting the "You build it, you run it" approach, the project exhibits proactive monitoring, continuous improvement, and ownership accountability, documented effectively through resolved GitHub Issues (B3, S11).

---

## ✅ KSB Evidence Mapping

See the detailed KSB evidence mapping, organised by individual KSB numbers with corresponding screenshots and explanations.

---



