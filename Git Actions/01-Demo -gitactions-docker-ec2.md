# Deployment : Docker Image to EC2



## Build your CI
- Create your file - ci-docker.yml
- This file handles CI for Docker - Continuous Integration with Docker
- What it does: builds your Flask app into a Docker image and pushes it to DockerHub, This workflow runs every time you push to the main branch

```yml
# The name shown in the GitHub Actions tab
name: CI- Workflow

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
name: Deploy to Server

# on: defines when this workflow should trigger
on:
  workflow_run:
    # This workflow listens for the CI Workflow to finish
    # It will only trigger after the CI Workflow completes
    workflows: ["CI Workflow"]
    types:
      # 'completed' means the CI workflow finished (success or failure)
      - completed
    branches:
      # Only trigger when the CI workflow ran on the master branch
      - master

# jobs: the list of tasks to run
jobs:
  deploy:
    # Use a fresh GitHub-hosted Linux machine
    runs-on: ubuntu-latest

    # IMPORTANT: Only deploy if the CI workflow actually SUCCEEDED
    # workflow_run triggers on 'completed' which includes failures
    # This if-condition filters to only successful runs
    if: ${{ github.event.workflow_run.conclusion == 'success' }}

    steps:

      # ──────────────────────────────────────────────────────
      # STEP 1: Set up SSH key so we can connect to AWS servers
      # ──────────────────────────────────────────────────────
      - name: Set up SSH key
        run: |
          # Create the .ssh directory if it does not already exist
          mkdir -p ~/.ssh

          # Write the private key from GitHub Secrets into a file
          # This is the same .pem key you use to SSH into your EC2 instances
          echo "${{ secrets.EC2_SSH_KEY }}" > ~/.ssh/deploy_key.pem

          # Set permission to 600 so only this user can read the key
          # SSH will refuse the key if permissions are too open
          chmod 600 ~/.ssh/deploy_key.pem

          # Configure SSH to skip host key verification
          # This prevents the interactive 'are you sure?' prompt
          # that would hang the automated pipeline
          echo "StrictHostKeyChecking no" >> ~/.ssh/config
          echo "UserKnownHostsFile /dev/null" >> ~/.ssh/config
          chmod 600 ~/.ssh/config

      # ──────────────────────────────────────────────────────
      # STEP 2: Deploy the new Docker image on Server 1
      # We SSH into the server and run Docker commands there
      # ──────────────────────────────────────────────────────
      - name: Deploy to Server 1
        run: |
          # SSH into Server 1 using the private key
          # -T disables pseudo-terminal allocation (not needed for scripts)
          # -i specifies the identity (private key) file
          # -o StrictHostKeyChecking=no skips host verification
          # vars.EC2_USER is stored as a variable (not a secret)
          # secrets.EC2_HOST1 is the IP address of Server 1
          ssh -T -i ~/.ssh/deploy_key.pem \
            -o StrictHostKeyChecking=no \
            ${{ vars.EC2_USER }}@${{ secrets.EC2_HOST1 }} << 'EOF'

            # Pull the latest image from DockerHub
            # This downloads the image just built and pushed by CI
            sudo docker pull ${{ secrets.DOCKER_USERNAME }}/demo-appwithflask:latest

            # Stop and remove the currently running container
            # || true means do not fail if no container is running yet
            sudo docker stop demo-appwithflask || true
            sudo docker rm demo-appwithflask || true

            # Start a new container from the updated image
            # --name gives the container a name for easy management
            # -d runs in detached (background) mode
            # -p 80:80 maps server port 80 to container port 80
            sudo docker run --name demo-appwithflask -d -p 80:80 \
              ${{ secrets.DOCKER_USERNAME }}/demo-appwithflask:latest
          EOF

      # ──────────────────────────────────────────────────────
      # STEP 3: Verify Server 1 is responding after deployment
      # ──────────────────────────────────────────────────────
      - name: Health check Server 1
        run: |
          # Wait 20 seconds for the container to fully start
          sleep 20

          # Trim any whitespace from the secret value
          # Trailing spaces or newlines in secrets can break URLs
          # tr -d '[:space:]' removes ALL whitespace characters
          HOST=$(echo "${{ secrets.EC2_HOST1 }}" | tr -d '[:space:]')

          # curl sends an HTTP request to the /health endpoint
          # -s = silent mode (no progress output)
          # -o /dev/null = discard the response body
          # -w "%{http_code}" = print only the HTTP status code
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${HOST}/health)

          # 200 means the server responded successfully
          # If not 200, something went wrong with the deployment
          if [ "$STATUS" != "200" ]; then
            echo "Server 1 health check failed. Status: $STATUS"
            exit 1
          fi
          echo "Server 1 is running. Status: $STATUS"

      # ──────────────────────────────────────────────────────
      # STEP 4: Deploy the new Docker image on Server 2
      # ──────────────────────────────────────────────────────
      - name: Deploy to Server 2
        run: |
          ssh -T -i ~/.ssh/deploy_key.pem \
            -o StrictHostKeyChecking=no \
            ${{ vars.EC2_USER }}@${{ secrets.EC2_HOST2 }} << 'EOF'

            # Pull the latest image from DockerHub onto Server 2
            sudo docker pull ${{ secrets.DOCKER_USERNAME }}/demo-appwithflask:latest

            # Stop and remove the old container on Server 2
            sudo docker stop demo-appwithflask || true
            sudo docker rm demo-appwithflask || true

            # Start a fresh container with the updated image
            sudo docker run --name demo-appwithflask -d -p 80:80 \
              ${{ secrets.DOCKER_USERNAME }}/demo-appwithflask:latest
          EOF

      # ──────────────────────────────────────────────────────
      # STEP 5: Verify Server 2 is responding after deployment
      # ──────────────────────────────────────────────────────
      - name: Health check Server 2
        run: |
          sleep 20

          # IMPORTANT: Use EC2_HOST2 here (not HOST1)
          # A common mistake is copying from Server 1 and forgetting to change
          HOST=$(echo "${{ secrets.EC2_HOST2 }}" | tr -d '[:space:]')
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${HOST}/health)

          if [ "$STATUS" != "200" ]; then
            echo "Server 2 health check failed. Status: $STATUS"
            exit 1
          fi
          echo "Server 2 is running. Status: $STATUS"
```

## Error Encountered and Resolutions:
1. Host key verification Error
   introduced a skip to host key verification prompt  using the  `-T` and `-o` to my ssh command
   ```sh
   ssh -T -i ~/.ssh/deploy_key.pem \
            -o StrictHostKeyChecking=no \
            ${{ vars.EC2_USER }}@${{ secrets.EC2_HOST1 }} << 'EOF'
   ```
1. Docker permission error
`permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.50/images/create?fromImage=docker.io%2F***%2Fdemo-appwithflask&tag=latest": dial unix /var/run/docker.sock: connect: permission denied`
Resolution: Added sudo to all docker command 
1. Server healthcheck Failure: 
Resolution: increase sleep from 5s to 20s, suspected a whitespace on my EC2 host so I introduced a white space to filter to the healthcheck command `  HOST=$(echo "${{ secrets.EC2_HOST1 }}" | tr -d '[:space:]')`
