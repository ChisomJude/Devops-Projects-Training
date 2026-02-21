# Deployment : Docker Image to EC2



## Build your CI
- Create your file - ci-docker.yml
- This file handles CI for Docker - Continuous Integration with Docker
- What it does: builds your Flask app into a Docker image and pushes it to DockerHub, This workflow runs every time you push to the main branch

```yml
# The name shown in the GitHub Actions tab
name: CI Docker - Build and Push Image to DockerHub

# on: defines when this workflow should trigger
on:
  push:
    # Only trigger when code is pushed to the main branch
    branches:
      - main

# jobs: the list of tasks to run
jobs:

  # This job is called "build-and-push"
  build-and-push:

    # Use a fresh GitHub-hosted Linux machine to run the steps
    runs-on: ubuntu-latest

    steps:

      # Step 1: Download your code onto the runner machine
      # Without this step the runner has no access to your files
      - name: Checkout code
        uses: actions/checkout@v4

      # Step 2: Log in to DockerHub
      # This is like running "docker login" in your terminal
      # We use GitHub Secrets to store the username and password safely
      # secrets.DOCKERHUB_USERNAME is the secret name you will create in GitHub
      # secrets.DOCKERHUB_TOKEN is a DockerHub access token, not your password
      - name: Log in to DockerHub
        uses: docker/login-action@v3
        with:
          # Your DockerHub username stored as a GitHub Secret
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          # Your DockerHub access token stored as a GitHub Secret
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Step 3: Build the Docker image and push it to DockerHub in one step
      # docker/build-push-action is an official pre-built Action for this
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          # context: . means use the current folder as the build context
          # This is the folder Docker looks in to find your Dockerfile and app files
          context: .

          # push: true means after building, send the image to DockerHub
          push: true

          # tags: is the name and version label for your image on DockerHub
          # Format is: dockerhub-username/repository-name:tag
          # latest means this is the most recent version of the image
          # secrets.DOCKERHUB_USERNAME pulls your username from GitHub Secrets
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/flask-load-balancer:latest
```

## Build your CD
- This file handles CD for Docker - Continuous Deployment with Docker
- What it does: SSHes into both AWS servers and tells them to pull the latest
- Docker image from DockerHub and run it as a container
- This workflow only runs after ci-docker.yml finishes successfully
```yaml

# The name shown in the GitHub Actions tab
name: CD Docker - Deploy Container to AWS Servers

# on: defines when this workflow should trigger
on:
  push:
    # Only trigger when code is pushed to the main branch
    branches:
      - main

# jobs: the list of tasks to run
jobs:

  # This job is called "deploy"
  deploy:

    # Use a fresh GitHub-hosted Linux machine
    runs-on: ubuntu-latest

    # needs: means this job waits for the build-and-push job in ci-docker.yml to pass
    # If the image build failed, we do not want to deploy an outdated or broken image
    needs: build-and-push

    steps:

      # Step 1: Set up the SSH key so we can connect to both AWS servers
      - name: Set up SSH key
        run: |
          # Create the .ssh directory if it does not already exist
          mkdir -p ~/.ssh

          # Write the private key from GitHub Secrets into a file
          # This is the same .pem key you use to SSH into your EC2 instances
          
          echo "${{ secrets.EC2_PRIVATE_KEY }}" > ~/.ssh/deploy_key.pem

          # Set the permission to 600 so only this user can read the key
          # SSH will refuse to use the key if the permission is too open
          chmod 600 ~/.ssh/deploy_key.pem

          # Add both server IPs to known_hosts
          # This prevents SSH from asking "are you sure you want to connect?" interactively
          ssh-keyscan -H ${{ secrets.SERVER_1_IP }} >> ~/.ssh/known_hosts
          ssh-keyscan -H ${{ secrets.SERVER_2_IP }} >> ~/.ssh/known_hosts

      # Step 2: Deploy the new Docker image on Server 1
      # We SSH into the server and run Docker commands there
      - name: Deploy to Server 1
        run: |
          ssh -i ~/.ssh/deploy_key.pem ${{ secrets.EC2_USER }}@${{ secrets.SERVER_1_IP }} << 'EOF'

            # Pull the latest version of the image from DockerHub
            # This downloads the image that was just built and pushed by ci-docker.yml
            # DOCKERHUB_USERNAME is passed as an environment variable below
            docker pull ${{ secrets.DOCKERHUB_USERNAME }}/flask-load-balancer:latest

            # Stop and remove the currently running container if one exists
            # The container is named "flask-app" so we can find it by name
            # || true means do not fail if no container is running yet
            docker stop flask-app || true
            docker rm flask-app || true

            # Start a new container from the updated image
            # --name flask-app gives the container a name so we can manage it later
            # -d means run in the background (detached mode)
            # -p 80:80 maps port 80 on the server to port 80 inside the container
            # This is how outside traffic reaches your Flask app inside the container
            docker run --name flask-app -d -p 80:80 ${{ secrets.DOCKERHUB_USERNAME }}/flask-load-balancer:latest

          EOF

      # Step 3: Verify Server 1 is responding after the new container started
      - name: Health check Server 1
        run: |
          # Wait for the container to fully start before checking
          sleep 5

          # curl sends an HTTP request to the /health route
          # -s is silent mode, no progress output
          # -o /dev/null throws away the response body
          # -w "%{http_code}" prints only the HTTP status code number
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.SERVER_1_IP }}/health)

          # 200 means the server responded successfully
          # If not 200, something went wrong starting the container
          if [ "$STATUS" != "200" ]; then
            echo "Server 1 health check failed. Status: $STATUS"
            exit 1
          fi

          echo "Server 1 is running. Status: $STATUS"

      # Step 4: Deploy the new Docker image on Server 2
      - name: Deploy to Server 2
        run: |
          ssh -i ~/.ssh/deploy_key.pem ${{ secrets.EC2_USER }}@${{ secrets.SERVER_2_IP }} << 'EOF'

            # Pull the latest image from DockerHub onto Server 2
            docker pull ${{ secrets.DOCKERHUB_USERNAME }}/flask-load-balancer:latest

            # Stop and remove the old container on Server 2
            docker stop flask-app || true
            docker rm flask-app || true

            # Start a fresh container with the updated image on Server 2
            docker run --name flask-app -d -p 80:80 ${{ secrets.DOCKERHUB_USERNAME }}/flask-load-balancer:latest

          EOF

      # Step 5: Verify Server 2 is responding after the new container started
      - name: Health check Server 2
        run: |
          sleep 5

          STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.SERVER_2_IP }}/health)

          if [ "$STATUS" != "200" ]; then
            echo "Server 2 health check failed. Status: $STATUS"
            exit 1
          fi

          echo "Server 2 is running. Status: $STATUS"
```
