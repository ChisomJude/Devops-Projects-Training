# Local Testing Guide

## Prerequisites
- Python 3.8 or higher installed
- Docker installed (for containerization)

## Step 1: Test Locally Without Docker

1. **Navigate to the project directory:**
   ```bash
   cd lb-test-app
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application:**
   ```bash
   python app.py
   ```
   
   Note: `sudo` is required because the app runs on port 80  ` sudo python app.py`

4. **Test the application:**
   - Open your browser and go to: `http://localhost`
   - You should see a page showing your server's hostname and IP address
   - Test the health endpoint: `http://localhost/health`

5. **Stop the application:**
   - Press `Ctrl + C` in the terminal

## Step 2: Test with Docker Locally

1. **Build the Docker image:**
   ```bash
   docker build -t lb-test-app .
   ```

2. **Run the container:**
   ```bash
   docker run -d -p 80:80 --name lb-test lb-test-app
   ```

3. **Test the application:**
   - Open your browser and go to: `http://localhost`
   - You should see the server information page

4. **Check container logs:**
   ```bash
   docker logs lb-test
   ```

5. **Stop and remove the container:**
   ```bash
   docker stop lb-test
   docker rm lb-test
   ```

## What to Expect
- The home page (`/`) shows:
  - Server hostname (container ID when running in Docker)
  - Server IP address
  - Status indicator
- The health endpoint (`/health`) returns JSON:
  ```json
  {
    "status": "healthy",
    "hostname": "container-id-or-hostname"
  }
  ```



## Troubleshooting

**Port 80 already in use:**
- Stop other services using port 80
- Or change the port mapping: `docker run -d -p 8080:80 --name lb-test lb-test-app`
- Then access at: `http://localhost:8080`

**Permission denied on port 80:**
- Use `sudo` when running Python directly
- Docker handles permissions automatically
