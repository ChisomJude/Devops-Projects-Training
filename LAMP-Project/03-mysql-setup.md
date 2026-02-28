# Section 03 — MySQL Setup (Private Subnet)

> **Goal:** Install MySQL on the database server, create a database and user for our app, and verify that the web server can connect to it.

---

##  Why Is the Database on a Private Subnet?

Databases contain your most sensitive data. Putting it on a private subnet means:
- The internet **cannot** reach it directly
- Only servers inside your VPC (like your web server) can connect
- Even if someone finds the IP, they cannot reach port 3306 from outside

This is standard practice in real-world production systems.

---

## Step 1 — SSH Into the Database Server

Remember — you can't SSH directly to the DB server. Go through the web server:

```bash
# On your local machine: SSH into web server
ssh -i ~/Downloads/lamp-key.pem ubuntu@<WEB_SERVER_PUBLIC_IP>

# On the web server: SSH into DB server
ssh -i ~/.ssh/lamp-key.pem ubuntu@<DB_SERVER_PRIVATE_IP>
```

You should now be on the DB server. Confirm with:
```bash
hostname
# e.g. ip-10-0-2-45
```

---

## Step 2 — Install MySQL Server

```bash
# Update package list
sudo apt update

# Install MySQL server
sudo apt install -y mysql-server

# Check MySQL is running
sudo systemctl status mysql
```

You should see `active (running)` in green.

If it's not running, start it:
```bash
sudo systemctl start mysql
sudo systemctl enable mysql   # start automatically on reboot
```

---

## Step 3 — Secure MySQL

Run the MySQL security script that comes with the installation:

```bash
sudo mysql_secure_installation
```

Answer the prompts:
- **Validate password component?** → `N` (for now, to keep it simple)
- **Remove anonymous users?** → `Y`
- **Disallow root login remotely?** → `Y`
- **Remove test database?** → `Y`
- **Reload privilege tables?** → `Y`

---

## Step 4 — Create Database and App User

Log into MySQL:
```bash
sudo mysql
```

You're now in the MySQL shell (prompt changes to `mysql>`). Run these commands:

```sql
-- Create the database our app will use
CREATE DATABASE lampdb;

-- Create a dedicated user for our app
-- Replace 'yourpassword' with a strong password
-- '10.0.1.%' means: only allow connections from IPs in the 10.0.1.x range (our public subnet)
CREATE USER 'lampuser'@'10.0.1.%' IDENTIFIED BY 'yourpassword';

-- Give this user full access to the lampdb database only
GRANT ALL PRIVILEGES ON lampdb.* TO 'lampuser'@'10.0.1.%';

-- Apply the changes
FLUSH PRIVILEGES;

-- Confirm the database was created
SHOW DATABASES;

-- Exit MySQL
EXIT;
```

>  We use `10.0.1.%` instead of `%` (all IPs) because we only want the web server (which is in the `10.0.1.0/24` subnet) to connect. This is the principle of **least privilege** — only give access to what actually needs it.  ENSURE THE SUBNET IS SAME AS YOUR WEB SERVER

---

## Step 5 — Configure MySQL to Listen for Remote Connections

By default, MySQL only accepts connections from `localhost` (the same machine). We need it to accept connections from our web server.

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Find this line:
```
bind-address = 127.0.0.1
```

Change it to:
```
bind-address = 0.0.0.0 
```

>  `0.0.0.0` means "accept connections on all network interfaces." This is safe because our security group already blocks port 3306 from everything except `lamp-web-sg`.

Save and exit: `Ctrl+X` → `Y` → `Enter`

Restart MySQL to apply:
```bash
sudo systemctl restart mysql
```

---

## Step 6 — Create a Sample Table (Optional but Recommended)

Log back into MySQL and add a simple table so the app has real data to show:

```bash
sudo mysql
```

```sql
USE lampdb;

-- Create a simple visitors table
CREATE TABLE visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert a test record
INSERT INTO visitors () VALUES ();

-- Confirm it's there
SELECT * FROM visitors;

EXIT;
```

---

## Step 7 — Test Connection From Web Server

Go back to the web server (exit the DB server, you'll be on the web server):

```bash
exit   # leaves DB server, you're back on web server
```

Install MySQL client on the web server:
```bash
sudo apt update && sudo apt install -y mysql-client
```

Now test the connection:
```bash
mysql -h <DB_SERVER_PRIVATE_IP> -u lampuser -p lampdb
# Enter the password you set in Step 4
```

If you see the `mysql>` prompt — the public/private subnet communication is working! 🎉

```sql
SHOW TABLES;
-- Should show: visitors
EXIT;
```

---

##  Checks & TROUBLESHOOTING

| Task | Command to Verify |
|------|-------------------|
| MySQL is running on DB server | `sudo systemctl status mysql` |
| Database exists | `SHOW DATABASES;` in mysql shell |
| App user exists | `SELECT user, host FROM mysql.user;` |
| Web server can connect | `mysql -h <DB_PRIVATE_IP> -u lampuser -p lampdb` from web server |
| login to the DB | sudo mysql|

---



**Drop user and recreate it if needed (on ur DB Server)**

```
DROP USER 'lampuser'@'localhost';
CREATE USER 'lampuser'@'10.0.1.%' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON lampdb.* TO 'lampuser'@'10.0.1.%';
FLUSH PRIVILEGES;
EXIT;
```


>  Database ready! Move on to **[Section 04 → App Setup](./04-app-setup.md)**
