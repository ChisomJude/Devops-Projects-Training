# Section 04 — App Setup & Docker on Web Server

> **Goal:** Install Docker on the web server, pull your Flask app image from DockerHub, and run it as a container — passing database credentials securely via environment variables.

---

##  Why Docker Here?

Instead of installing Python, pip, and all dependencies directly on the server, we package everything into a **Docker container**. This means:
- The app runs the same way in CI, on your laptop, and on this server
- Updating the app = pulling a new image (one command)
- Rollback = run the old image again (one command)

---

## Step 1 — Install Docker on Web Server

SSH into your web server:
```bash
ssh -i ~/Downloads/lamp-key.pem ubuntu@<WEB_SERVER_PUBLIC_IP>
```

Install Docker:
```bash
# Update packages
sudo apt update

# Install Docker
sudo apt install -y docker.io

# Start Docker and enable it to start on reboot
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to the docker group (so you don't need sudo every time)
sudo usermod -aG docker ubuntu

# Apply the group change (or log out and back in)
newgrp docker

# Confirm Docker is installed
docker --version
```

---

## Step 2 — Pull and Run Your App

>  For this step, we're running the container manually first to test it. The CI/CD pipeline (Section 06) will automate this for every future deployment.

```bash
# Pull the image from DockerHub
# Replace 'yourdockerhubusername' with your actual DockerHub username
sudo docker pull yourdockerhubusername/lamp-demo:latest

# Run the container, passing DB credentials as environment variables
# -d = run in background (detached)
# --name = give the container a name
# --restart unless-stopped = restart automatically if server reboots
# -p 5000:5000 = map port 5000 on the host to port 5000 in the container
# -e = environment variable (this is how we pass secrets without hardcoding)
sudo docker run -d \
  --name lamp-app \
  --restart unless-stopped \
  -p 5000:5000 \
  -e DB_HOST=<DB_SERVER_PRIVATE_IP> \
  -e DB_PORT=3306 \
  -e DB_NAME=lampdb \
  -e DB_USER=lampuser \
  -e DB_PASSWORD=yourpassword \
  -e FLASK_ENV=production \
  yourdockerhubusername/lamp-demo:latest
```

>  Replace the values above with your actual DB private IP, username, and password.

---

## Step 3 — Verify the Container is Running

```bash
# List running containers
sudo docker ps

# Should show something like:
# CONTAINER ID   IMAGE                         COMMAND                  STATUS
# a1b2c3d4e5f6   yourusername/lamp-demo:latest "gunicorn -w 2 -b 0.…" Up 10 seconds
```

Check the app is responding:
```bash
curl http://localhost:5000/health
# Should return: {"status": "healthy", "hostname": "...", "database": " Connected — MySQL ..."}
```

If you see `"database": " Connected"` — your app is talking to the database in the private subnet! 

---

## Step 4 — Useful Docker Commands (Reference)

```bash
# See running containers
sudo docker ps

# See ALL containers (including stopped ones)
sudo docker ps -a

# See logs from your app container (useful for debugging)
sudo docker logs lamp-app

# Follow logs in real time (like tail -f)
sudo docker logs -f lamp-app

# Stop the container
sudo docker stop lamp-app

# Start it again
sudo docker start lamp-app

# Remove the container
sudo docker rm lamp-app

# See all images downloaded on this server
sudo docker images
```

---

## Step 5 — Understand the Environment Variable Flow

Here's how credentials flow through the system without ever being hardcoded:

```
GitHub Secrets (stored safely in GitHub)
         │
         │  GitHub Actions reads them
         ▼
docker run -e DB_PASSWORD=${{ secrets.DB_PASSWORD }}
         │
         │  Docker injects into container environment
         ▼
os.environ.get("DB_PASSWORD")   ← your app.py reads it here
         │
         │  used to connect to MySQL
         ▼
MySQL on private subnet
```

The password never appears in your code, your Dockerfile, or your logs. 

---

##  Check Your Work

```bash
# Container is running
sudo docker ps | grep lamp-app

# App responds on port 5000
curl http://localhost:5000/health

# App shows DB connected
curl http://localhost:5000/
```

---

>  App is running in Docker! Move on to **[Section 05 → NGINX Setup](./05-nginx-setup.md)**
