# Push to Docker Hub

## Prerequisites
- Docker installed and running
- Docker Hub account (create one at https://hub.docker.com if you don't have one)

## Step 1: Login to Docker Hub

1. **Login via command line:**
   ```bash
   docker login
   ```

2. **Enter your credentials:**
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password (or access token)

   You should see: `Login Succeeded`

## Step 2: Build and Tag Your Image

1. **Build the Docker image:**
   ```bash
   docker build -t lb-test-app .
   ```

2. **Tag the image with your Docker Hub username:**
   
   Replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username
   
   ```bash
   docker tag lb-test-app YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
   ```
   
   Example:
   ```bash
   docker tag lb-test-app chisom/lb-test-app:latest
   ```

## Step 3: Push to Docker Hub

1. **Push the image:**
   ```bash
   docker push YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
   ```
   
   Example:
   ```bash
   docker push chisomjude/lb-test-app:latest
   ```

2. **Wait for the upload to complete:**
   - You'll see progress bars for each layer
   - When complete, you'll see: `latest: digest: sha256:...`

## Step 4: Verify Upload

1. **Visit Docker Hub:**
   - Go to: `https://hub.docker.com/r/YOUR_DOCKERHUB_USERNAME/lb-test-app`
   - You should see your image listed

2. **Make the repository public (if needed):**
   - Click on your repository
   - Go to Settings
   - Make it public so EC2 instances can pull without authentication

## What You Need for EC2

After pushing, you'll use this image on EC2 with:

```bash
docker pull YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
docker run -d -p 80:80 YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
```

**Important:** Remember to replace `YOUR_DOCKERHUB_USERNAME` with your actual username in all EC2 setup steps!

## Quick Reference Commands

```bash
# Login to Docker Hub
docker login

# Build image
docker build -t lb-test-app .

# Tag image
docker tag lb-test-app YOUR_DOCKERHUB_USERNAME/lb-test-app:latest

# Push image
docker push YOUR_DOCKERHUB_USERNAME/lb-test-app:latest

# Test pulling image
docker pull YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
```

## Troubleshooting

**"denied: requested access to the resource is denied":**
- Make sure you're logged in: `docker login`
- Verify the image tag includes your username
- Check your Docker Hub username is correct

**"Get https://registry-1.docker.io/v2/: unauthorized":**
- Your login session expired
- Run `docker login` again

**Image too large:**
- The Python slim image is already optimized
- Total size should be around 150-200MB
