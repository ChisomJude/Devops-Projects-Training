# Section 07 — Testing & Verification

> **Goal:** Verify that every part of the stack works — from the browser all the way down to the database on the private subnet.

---

## The Full Stack Test Checklist

Work through these in order. Each one proves a different part of the system is working.

---

###  Test 1 — VPC & Subnet Setup

In the AWS Console, verify:

- [ ] VPC `lamp-vpc` exists with CIDR `10.0.0.0/16`
- [ ] Public subnet `10.0.1.0/24` has auto-assign public IP enabled
- [ ] Private subnet `10.0.2.0/24` has no public IP assignment
- [ ] Internet Gateway `lamp-igw` is attached to the VPC
- [ ] Public route table has a route `0.0.0.0/0 → lamp-igw`
- [ ] Private route table has NO internet route

---

###  Test 2 — Security Groups

Verify the security groups are correctly configured:

**lamp-web-sg should allow:**
```
Inbound:  Port 80  from 0.0.0.0/0   (anyone can visit)
Inbound:  Port 443 from 0.0.0.0/0   (HTTPS)
Inbound:  Port 22  from your IP only (SSH)
Outbound: All traffic (default)
```

**lamp-db-sg should allow:**
```
Inbound:  Port 3306 from lamp-web-sg only (MySQL from web server only)
Inbound:  Port 22   from your IP only (SSH for setup)
Outbound: All traffic (default)
```

---

###  Test 3 — SSH Access

```bash
# Can you SSH into the web server directly?
ssh -i ~/Downloads/lamp-key.pem ubuntu@<WEB_SERVER_PUBLIC_IP>
# Expected: Ubuntu welcome message 

# Can you reach the DB server through the web server?
ssh -i ~/.ssh/lamp-key.pem ubuntu@<DB_SERVER_PRIVATE_IP>
# Expected: Ubuntu welcome message 
```

---

###  Test 4 — Database is Running

On the DB server:

```bash
sudo systemctl status mysql
# Expected: active (running) 

sudo mysql -e "SHOW DATABASES;"
# Expected: lampdb is in the list 

sudo mysql -e "SELECT user, host FROM mysql.user WHERE user='lampuser';"
# Expected: lampuser | 10.0.1.% 
```

---

###  Test 5 — Public/Private Subnet Communication

This is the key networking test. From the **web server**, connect to the database:

```bash
mysql -h <DB_SERVER_PRIVATE_IP> -u lampuser -p lampdb
```

Enter your password. If you get a `mysql>` prompt — the two subnets are communicating correctly! 

```sql
SHOW TABLES;
-- Expected: visitors table 
EXIT;
```

> If this fails, check: security group `lamp-db-sg` allows port 3306 from `lamp-web-sg`, and MySQL `bind-address` is set to `0.0.0.0`.

---

###  Test 6 — Docker Container is Running

On the web server:

```bash
sudo docker ps
# Expected: lamp-app container listed with status "Up" 

sudo docker logs lamp-app
# Expected: Gunicorn workers started, no errors 

curl http://localhost:5000/health
# Expected: {"status": "healthy", "database": " Connected..."} 
```

---

### Test 7 — NGINX is Forwarding Traffic

On the web server:

```bash
sudo systemctl status nginx
# Expected: active (running) 

sudo nginx -t
# Expected: syntax is ok / test is successful 

# Test NGINX forwards to Flask
curl http://localhost/health
# Expected: same response as port 5000  (NGINX is forwarding it)
```

---

###  Test 8 — App is Live in Browser

Open a browser and visit:
```
http://<WEB_SERVER_PUBLIC_IP>
```

You should see:

```
┌─────────────────────────────────────┐
│         LAMP Stack Demo App       │
│                                      │
│  Server Hostname: ip-10-0-1-xxx     │
│  Server IP: 10.0.1.xxx              │
│  App Status:  Server is running!  │
│  Database:  Connected — MySQL 8.0 │
└─────────────────────────────────────┘
```

All four items showing means the full stack is working end to end.

---

###  Test 9 — CI/CD Pipeline Works

1. Make a small edit to `app.py` (change any text in the HTML)
2. Push to GitHub:
   ```bash
   git add app.py
   git commit -m "Test deployment via CI/CD"
   git push origin main
   ```
3. Go to GitHub → **Actions tab** and watch the pipeline run
4. After it finishes (2-3 minutes), refresh your browser
5. Your change should be live — without you touching the server

---

###  Test 10 — Private Subnet Security (The "Prove It" Test)

Try to connect to MySQL directly from your **local machine** (not through the web server):

```bash
# From your laptop:
mysql -h <DB_SERVER_PRIVATE_IP> -u lampuser -p lampdb
```

This should **fail** or **time out** — because:
1. The DB server has no public IP
2. Even if it did, the security group blocks port 3306 from the internet

This is exactly what we want.  The private subnet is protecting the database.

---

## Full Stack Summary

If all 10 tests pass, you have successfully built:

```
Internet (anyone)
     │
     ▼ Port 80
┌──────────────────────────────────────┐
│          PUBLIC SUBNET               │
│                                      │
│  NGINX (reverse proxy)               │
│    ↓ forwards to port 5000           │
│  Flask App (Docker container)        │
│    ↓ connects to private IP          │
└──────────────────────────────────────┘
     │ Port 3306 (internal only)
     ▼
┌──────────────────────────────────────┐
│          PRIVATE SUBNET              │
│                                      │
│  MySQL Database                      │
│  (not reachable from internet)       │
└──────────────────────────────────────┘

Deployed automatically by:
GitHub → GitHub Actions CI/CD → DockerHub → EC2
```

---

##  Cleanup (Avoid AWS Charges)

When you're done, stop or terminate your resources:

```bash
# In AWS Console:
# 1. EC2 → Instances → select both → Instance State → Terminate
# 2. VPC → Your VPCs → select lamp-vpc → Actions → Delete VPC
#    (this also deletes subnets, route tables, security groups)
```

>  Stopped EC2 instances still charge for the EBS storage. Terminate them fully when done with the project.

---

**Congratulations — you've built a production-style LAMP stack on AWS from scratch! Give this repo a star ** 
