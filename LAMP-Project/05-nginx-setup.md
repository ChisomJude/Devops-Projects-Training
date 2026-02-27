# Section 05 — NGINX Reverse Proxy Setup

> **Goal:** Install NGINX on the web server and configure it to sit in front of the Flask app — so users hit port 80 (standard HTTP), and NGINX forwards the request to Flask on port 5000.

---

##  What Is a Reverse Proxy?

Without NGINX:
```
User → port 80 → ??? (nothing listening here)
User → port 5000 → Flask app (but weird port for users)
```

With NGINX:
```
User → port 80 → NGINX → port 5000 → Flask app 
```

NGINX acts as the **front door**. It receives every request, then passes it back to Flask. This is called a **reverse proxy**.

Why bother?
- Users use normal port 80 (they don't need to know Flask is running on 5000)
- NGINX handles SSL termination (HTTPS) much better than Flask
- NGINX can serve static files faster
- It's the standard pattern in production

---

## Step 1 — Install NGINX

On your web server:

```bash
sudo apt update
sudo apt install -y nginx

# Start NGINX and enable on reboot
sudo systemctl start nginx
sudo systemctl enable nginx

# Check it's running
sudo systemctl status nginx
```

Test in your browser: visit `http://<WEB_SERVER_PUBLIC_IP>` — you should see the default NGINX welcome page.

---

## Step 2 — Configure NGINX as a Reverse Proxy

We'll replace the default NGINX config with one that forwards traffic to our Flask app.

```bash
# Create a new config file for our app
sudo nano /etc/nginx/sites-available/lamp-app
```

Paste this configuration:

```nginx
server {
    # Listen on port 80 (standard HTTP)
    listen 80;

    # Accept requests for any domain or IP
    server_name _;

    # Forward all requests to Flask running on port 5000
    location / {
        proxy_pass http://127.0.0.1:5000;

        # Pass the original request headers to Flask
        # so Flask knows the real client IP, not just 127.0.0.1
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

Save and exit: `Ctrl+X` → `Y` → `Enter`

---

## Step 3 — Enable the Config

```bash
# Create a symbolic link to enable this site
sudo ln -s /etc/nginx/sites-available/lamp-app /etc/nginx/sites-enabled/

# Remove the default site (so it doesn't conflict)
sudo rm /etc/nginx/sites-enabled/default

# Test the config for syntax errors
sudo nginx -t

# If you see: "syntax is ok" and "test is successful" → reload NGINX
sudo systemctl reload nginx
```

---

## Step 4 — Test the Full Flow

Now test in your browser:

```
http://<WEB_SERVER_PUBLIC_IP>
```

You should see the LAMP Stack Demo App page — and it should show the database connection status.

If it works: requests are flowing like this:
```
Browser
  → port 80
  → NGINX on web server
  → port 5000
  → Flask (Docker container)
  → port 3306
  → MySQL (private subnet DB server)
```

The entire LAMP stack in action! 

---

## Step 5 — Test the Health Endpoint

```bash
curl http://<WEB_SERVER_PUBLIC_IP>/health
```

Should return:
```json
{
  "status": "healthy",
  "hostname": "ip-10-0-1-xxx",
  "database": " Connected — MySQL 8.0.xx"
}
```

---

## Common Issues

**NGINX won't reload — "nginx -t" fails:**
Check for typos in your config. Common mistake: missing semicolons at end of lines.

**Browser shows NGINX welcome page instead of your app:**
The default site wasn't removed. Run: `sudo rm /etc/nginx/sites-enabled/default && sudo systemctl reload nginx`

**Browser shows 502 Bad Gateway:**
NGINX is running but can't reach Flask. Check your container is running: `sudo docker ps`

**App page loads but shows database unreachable:**
Check the DB_HOST environment variable you passed matches the DB server's private IP. Verify MySQL is running on the DB server.

---

##  NGINX Config Reference

```
/etc/nginx/
├── nginx.conf                  ← main config (don't touch this)
├── sites-available/
│   └── lamp-app                ← your config file
└── sites-enabled/
    └── lamp-app → ...          ← symlink to enable it
```

---

>  NGINX is configured! Move on to **[Section 06 → CI/CD Setup](./06-cicd-setup.md)**
