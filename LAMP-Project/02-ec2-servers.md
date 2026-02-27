# Section 02 — Launch EC2 Servers

> **Goal:** Launch two EC2 instances — one web server in the public subnet, one database server in the private subnet. Configure security groups so only the right traffic is allowed.

---

##  What Are Security Groups?

A **Security Group** is a virtual firewall attached to an EC2 instance. It has rules that say:
- **Inbound rules** — what traffic is ALLOWED IN
- **Outbound rules** — what traffic is ALLOWED OUT (default: all outbound is allowed)

Think of it like a bouncer at a club — the security group decides who gets in.

---

## Step 1 — Create Security Group for Web Server

1. Go to **EC2 → Security Groups → Create Security Group**

   | Field | Value |
   |-------|-------|
   | Name | `lamp-web-sg` |
   | Description | Security group for web server |
   | VPC | `lamp-vpc` |

2. **Inbound Rules — Add these:**

   | Type | Protocol | Port | Source | Why |
   |------|----------|------|--------|-----|
   | HTTP | TCP | 80 | `0.0.0.0/0` | Anyone can visit the website |
   | HTTPS | TCP | 443 | `0.0.0.0/0` | For future SSL setup |
   | SSH | TCP | 22 | `My IP` | Only YOU can SSH in |

   >  For SSH, always choose **My IP** — not `0.0.0.0/0`. Leaving SSH open to the world is a major security risk.

3. Click **Create Security Group**

---

## Step 2 — Create Security Group for Database Server

1. **Create Security Group**

   | Field | Value |
   |-------|-------|
   | Name | `lamp-db-sg` |
   | Description | Security group for MySQL database |
   | VPC | `lamp-vpc` |

2. **Inbound Rules — Add these:**

   | Type | Protocol | Port | Source | Why |
   |------|----------|------|--------|-----|
   | MySQL/Aurora | TCP | 3306 | `lamp-web-sg` | Only the web server can talk to MySQL |
   | SSH | TCP | 22 | `My IP` | Only YOU can SSH in (for setup) |

   >  For the MySQL rule, instead of entering an IP address, you can select another Security Group as the source. This means "only EC2 instances that have `lamp-web-sg` attached can connect on port 3306." This is much better than hardcoding IPs.

3. Click **Create Security Group**

---

## Step 3 — Create a Key Pair

A **key pair** is how you SSH into EC2. AWS keeps the public key; you download the private key (`.pem` file).

1. **EC2 → Key Pairs → Create Key Pair**

   | Field | Value |
   |-------|-------|
   | Name | `lamp-key` |
   | Key pair type | RSA |
   | Private key format | `.pem` (Mac/Linux) or `.ppk` (Windows PuTTY) |

2. Download it — **you can only download it once!** Save it somewhere safe.

3. On your terminal, set the correct permissions:
   ```bash
   chmod 400 ~/Downloads/lamp-key.pem
   ```
   > SSH will refuse to use the key if the permissions are too open.

---

## Step 4 — Launch Web Server (Public Subnet)

1. **EC2 → Instances → Launch Instance**

   | Field | Value |
   |-------|-------|
   | Name | `lamp-web-server` |
   | AMI | Ubuntu Server 24.04 LTS (Free Tier eligible) |
   | Instance type | `t2.micro` (Free Tier) |
   | Key pair | `lamp-key` |

2. **Network settings → Edit:**

   | Field | Value |
   |-------|-------|
   | VPC | `lamp-vpc` |
   | Subnet | `lamp-public-subnet` |
   | Auto-assign public IP | **Enable** |
   | Security group | Select existing → `lamp-web-sg` |

3. **Storage:** Leave default (8GB)

4. Click **Launch Instance**

5. Once running, copy the **Public IPv4 address** — you'll need it.

---

## Step 5 — Launch Database Server (Private Subnet)

1. **Launch Instance** again

   | Field | Value |
   |-------|-------|
   | Name | `lamp-db-server` |
   | AMI | Ubuntu Server 24.04 LTS |
   | Instance type | `t2.micro` |
   | Key pair | `lamp-key` |

2. **Network settings → Edit:**

   | Field | Value |
   |-------|-------|
   | VPC | `lamp-vpc` |
   | Subnet | `lamp-private-subnet` |
   | Auto-assign public IP | **Disable** |
   | Security group | Select existing → `lamp-db-sg` |

3. Click **Launch Instance**

   >  Notice: The DB server has NO public IP. You cannot reach it from the internet at all. The only way in is through the web server (this is called a **bastion host** pattern).

---

## Step 6 — SSH Into Web Server (Test Access)

```bash
ssh -i ~/Downloads/lamp-key.pem ubuntu@<WEB_SERVER_PUBLIC_IP>
```

You should see the Ubuntu welcome message. Type `exit` to leave.

---

## Step 7 — SSH Into DB Server (Via Web Server)

Since the DB server has no public IP, you need to SSH into the web server first, then SSH from there to the DB server. This is called **SSH tunnelling** or using a **bastion host**.

```bash
# Step 1: Copy your key to the web server
scp -i ~/Downloads/lamp-key.pem ~/Downloads/lamp-key.pem ubuntu@<WEB_SERVER_PUBLIC_IP>:~/.ssh/

# Step 2: SSH into web server
ssh -i ~/Downloads/lamp-key.pem ubuntu@<WEB_SERVER_PUBLIC_IP>

# Step 3: From the web server, SSH into DB server using its PRIVATE IP
ssh -i ~/.ssh/lamp-key.pem ubuntu@<DB_SERVER_PRIVATE_IP>
```

>  The DB server's **Private IP** is in the AWS console → EC2 → your DB instance → Private IPv4 address. It will look like `10.0.2.xxx`.

---

##  Check Your Work

| Server | Subnet | Has Public IP? | Reachable from internet? |
|--------|--------|----------------|--------------------------|
| lamp-web-server | Public |  Yes | Yes (port 80, 22) |
| lamp-db-server | Private |  No |  No (by design!) |

---

>  Servers are up! Move on to **[Section 03 → MySQL Setup](./03-mysql-setup.md)**
