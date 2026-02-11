# Create EC2 Instance

This guide shows how to create EC2 instances that will run your Dockerized app.

## Step 1: Navigate to EC2 Instances

1. **Login to AWS Console** and go to EC2 Dashboard

2. **Click "Instances"** in the left sidebar

3. **Click "Launch instances"** (orange button)

## Step 2: Configure Instance Details

### Name and Tags
- **Name:** `lb-test-server-1`
- Click "Add additional tags" (optional):
  - Key: `Project`, Value: `LoadBalancerTest`
  - Key: `Environment`, Value: `Test`

### Application and OS Images (Amazon Machine Image)
1. **Quick Start:** Select "Amazon Linux"
2. **Amazon Machine Image (AMI):** Choose "Amazon Linux 2023 AMI"
   - This is free tier eligible
   - Has Docker support

### Instance Type
- **Instance type:** `t2.micro` (or t3.micro)
  - Free tier eligible
  - 1 vCPU, 1 GB RAM
  - Sufficient for testing

### Key Pair (login)
1. **Create new key pair:**
   - Click "Create new key pair"
   - **Key pair name:** `lb-test-key`
   - **Key pair type:** RSA
   - **Private key file format:** .pem (for Mac/Linux) or .ppk (for Windows/PuTTY)
   - Click "Create key pair"
   - **Save the downloaded file securely!** You can't download it again

2. **Or select existing key pair** if you have one

### Network Settings

1. **Click "Edit"** in the Network settings section

2. **VPC:** Select your default VPC

3. **Subnet:** Select any availability zone (e.g., us-east-1a)

4. **Auto-assign public IP:** **Enable** (important for load balancer)

5. **Firewall (security groups):**
   - Select "Select existing security group"
   - Choose the security group you created: `lb-test-app-sg`

### Configure Storage
- **Storage:** Keep default (8 GiB gp3)
- This is sufficient for the Docker image and application

### Advanced Details
Expand "Advanced details" section:

1. **Scroll down to "User data"**

2. **Paste the following script:**

```bash
#!/bin/bash
# Update system
yum update -y

# Install Docker
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Pull and run the application
# REPLACE 'YOUR_DOCKERHUB_USERNAME' with your actual Docker Hub username
docker pull YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
docker run -d -p 80:80 --name lb-test-app --restart unless-stopped YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
```

**IMPORTANT:** Replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username (e.g., chisom/lb-test-app:latest)

## Step 3: Launch Instance

1. **Review Summary** on the right side:
   - Number of instances: 1
   - Instance type: t2.micro
   - Security group: lb-test-app-sg

2. **Click "Launch instance"** (orange button)

3. **Wait for launch:**
   - You'll see "Successfully initiated launch of instance"
   - Click "View all instances"

## Step 4: Wait for Instance to be Ready

1. **Monitor instance state:**
   - **Instance State:** Should change from "Pending" to "Running" (takes 1-2 minutes)
   - **Status Check:** Should change to "2/2 checks passed" (takes 2-3 minutes)

2. **Select your instance** (checkbox on the left)

3. **Copy the Public IP address:**
   - Look at the "Details" tab at the bottom
   - Copy the **Public IPv4 address** (e.g., 54.123.45.67)

## Step 5: Test Your Application

1. **Wait 2-3 minutes** after the instance is running (for user data script to complete)

2. **Open your browser and visit:**
   ```
   http://YOUR_INSTANCE_PUBLIC_IP
   ```
   
   Example:
   ```
   http://54.123.45.67
   ```

3. **You should see:**
   - The load balancer test page
   - Server hostname (will be the container ID)
   - Server IP address

4. **Test health endpoint:**
   ```
   http://YOUR_INSTANCE_PUBLIC_IP/health
   ```

## Step 6: Create a Second Instance (for Load Balancer)

Repeat the entire process to create a second instance:

1. **Click "Launch instances"** again

2. **Use the same configuration** but:
   - **Name:** `lb-test-server-2`
   - Use the same security group: `lb-test-app-sg`
   - Use the same key pair: `lb-test-key`
   - **Use the same User data script** (with your Docker Hub username)

3. **Launch the second instance**

4. **Wait for it to be ready** and test it:
   ```
   http://SECOND_INSTANCE_PUBLIC_IP
   ```

## Verification Checklist

✅ Both instances are in "Running" state  
✅ Both instances have public IP addresses  
✅ Both instances pass 2/2 status checks  
✅ You can access the app on both IPs via browser  
✅ Each instance shows different hostname/container ID  

## Troubleshooting

### Can't access the application:

1. **Check security group:**
   - Port 80 should be open to 0.0.0.0/0

2. **Check user data logs:**
   - SSH into the instance: `ssh -i lb-test-key.pem ec2-user@YOUR_IP`
   - Check logs: `sudo cat /var/log/cloud-init-output.log`

3. **Check Docker status:**
   - SSH into instance
   - Run: `sudo docker ps`
   - Should show the running container

4. **Manually run if needed:**
   ```bash
   sudo docker pull YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
   sudo docker run -d -p 80:80 YOUR_DOCKERHUB_USERNAME/lb-test-app:latest
   ```

### Instance won't start:

- Check you selected the correct AMI (Amazon Linux 2023)
- Verify the instance type is available in your region
- Check AWS service health status

## SSH Access (Optional)

To SSH into your instance:

**Mac/Linux:**
```bash
chmod 400 lb-test-key.pem
ssh -i lb-test-key.pem ec2-user@YOUR_INSTANCE_PUBLIC_IP
```

**Windows (using PuTTY):**
- Convert .pem to .ppk using PuTTYgen
- Use PuTTY with the .ppk file

## Next Steps

✅ Two EC2 instances created and running!

Now proceed to: **03-create-target-group.md**
