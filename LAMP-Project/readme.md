#  LAMP Stack on AWS — Complete Beginner's Guide

> **L**inux · **A**pache/NGINX · **M**ySQL · **P**ython (Flask)

This guide walks you through building and deploying a real production-style web application on AWS — from scratch. Every step is explained in plain English with commands you can copy and run.

---

##  What You Will Build

By the end of this project, you will have:

- A **VPC** (your own private network on AWS) with a **public subnet** and a **private subnet**
- A **Web Server** (EC2) in the public subnet running your Flask app inside Docker, sitting behind NGINX
- A **Database Server** (EC2) in the private subnet running MySQL — not accessible from the internet
- A **CI/CD pipeline** using GitHub Actions that automatically deploys your app every time you push code

```
                        INTERNET
                            │
                            ▼
                    ┌───────────────┐
                    │  NGINX (Web)  │  ← Public Subnet (10.0.1.0/24)
                    │  Port 80      │    anyone can reach this
                    │               │
                    │  Flask App    │
                    │  (Docker)     │
                    │  Port 5000    │
                    └───────┬───────┘
                            │
                    Private Communication Only
                            │
                    ┌───────▼───────┐
                    │  MySQL 3306   │  ← Private Subnet (10.0.2.0/24)
                    │               │    internet CANNOT reach this
                    │  DB Server    │    only web server can
                    └───────────────┘
```


<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/1e032b95-001b-4be2-845c-77c1e942d1ff" />

---

##  Guide Sections

Follow these in order:

The App to Come - https://github.com/ChisomJude/sample/tree/master/LAMP-APP

| Section | File | What You Do |
|---------|------|-------------|
| **01** | [01-vpc-setup.md](./01-vpc-setup.md) | Create your VPC, subnets, route tables |
| **02** | [02-ec2-servers.md](./02-ec2-servers.md) | Launch web server and database server |
| **03** | [03-mysql-setup.md](./03-mysql-setup.md) | Install and configure MySQL on private subnet |
| **04** | [04-app-setup.md](./04-app-setup.md) | Set up the Flask app + Docker on web server |
| **05** | [05-nginx-setup.md](./05-nginx-setup.md) | Install and configure NGINX as reverse proxy |
| **06** | [06-cicd-setup.md](./06-cicd-setup.md) | Set up GitHub Actions CI/CD pipeline |
| **07** | [07-testing.md](./07-testing.md) | Test everything end to end |

---

##  What You Need Before Starting

- An AWS account (free tier is enough)
- A GitHub account
- A DockerHub account (free at hub.docker.com)
- A computer with a Linux terminal or Git Bash (Windows) or VSCode
- Basic comfort with the terminal (you've done the Linux module!)

---

##  Key Concepts at a Glance

| Term | Plain English |
|------|--------------|
| **VPC** | Your own private section of AWS — like renting a floor in a building |
| **Public Subnet** | Part of your VPC that the internet can reach |
| **Private Subnet** | Part of your VPC the internet CANNOT reach — safe for databases |
| **Security Group** | A firewall — controls what traffic is allowed in and out |
| **NGINX** | A web server that sits in front of your app and forwards requests to it |
| **Docker** | Packages your app so it runs the same way everywhere |
| **CI/CD** | Automation — your code is tested and deployed automatically on every push |
| **GitHub Secrets** | Where you store passwords and keys safely — never in your code |

---

