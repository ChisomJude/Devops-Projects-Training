# Create Launch Template

A launch template defines the configuration for EC2 instances that Auto Scaling will launch automatically.

## What is a Launch Template?

Think of it as a blueprint that tells AWS:
- What AMI to use
- What instance type
- What security groups
- What user data script to run
- Everything needed to create a new instance

Auto Scaling uses this template to create new instances automatically.

## Step 1: Navigate to Launch Templates

1. **Go to EC2 Dashboard**

2. **In the left sidebar:**
   - Scroll down to "Instances"
   - Click "Launch Templates"

3. **Click "Create launch template"** (orange button)

## Step 2: Launch Template Name and Description

### Launch template name
- **Name:** `lb-test-lt`

### Template version description
- **Description:** `Launch template for load balancer test app`

### Auto Scaling guidance
- ✅ Check the box: **"Provide guidance to help me set up a template that I can use with EC2 Auto Scaling"**
  - This ensures the template is compatible with Auto Scaling

## Step 3: Application and OS Images (AMI)

### Quick Start
1. Select **"Amazon Linux"**

2. **Amazon Machine Image (AMI):**
   - Choose: **"Amazon Linux 2023 AMI"**
   - Should show "Free tier eligible"

## Step 4: Instance Type

- **Instance type:** `t2.micro` (or t3.micro)
  - Free tier eligible
  - Same as your current instances

## Step 5: Key Pair (login)

- **Key pair name:** Select `lb-test-key`
  - Use the same key pair you created earlier
  - Or select "Don't include in launch template" if you don't need SSH access

## Step 6: Network Settings

### Subnet
- **Don't include in launch template**
  - Auto Scaling will handle subnet selection across AZs

### Firewall (security groups)
1. Click "Select existing security group"

2. **Security groups:**
   - Select: **lb-test-app-sg**
   - Remove any other security groups

## Step 7: Storage (volumes)

### Default volume
- **Size:** 8 GiB
- **Volume type:** gp3
- **Delete on termination:** Yes (checked)

Keep these defaults - they're sufficient for the Docker image.

## Step 8: Resource Tags

Click "Add tag" under "Resource tags":

**Tag 1:**
- **Key:** `Name`
- **Value:** `lb-test-auto`
- **Resource types:** Check "Instances" and "Volumes"

**Tag 2:**
- **Key:** `Project`
- **Value:** `LoadBalancerTest`
- **Resource types:** Check "Instances" and "Volumes"

These tags will be automatically applied to any instance created from this template.

## Step 9: Advanced Details

Expand "Advanced details" section:

### Scroll down to "User data"

Paste the following script:

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

**CRITICAL:** Replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username!

Example:
```bash
docker pull chisom/lb-test-app:latest
docker run -d -p 80:80 --name lb-test-app --restart unless-stopped chisom/lb-test-app:latest
```

### Leave other advanced settings as default

## Step 10: Summary

Review the summary on the right side:
- Launch template name: lb-test-lt
- AMI: Amazon Linux 2023
- Instance type: t2.micro
- Security group: lb-test-app-sg
- User data: Your Docker run script

## Step 11: Create Launch Template

1. **Click "Create launch template"** (orange button at bottom)

2. **Success message:**
   - "Successfully created lb-test-lt"
   - Click "View launch template"

## Step 12: Verify Launch Template

1. **Find your template** in the list: `lb-test-lt`

2. **Click on it** to view details

3. **Verify in the "Version" tab:**
   - Version: 1 (Default)
   - AMI: Amazon Linux 2023
   - Instance type: t2.micro
   - Security groups: lb-test-app-sg

4. **Check "Advanced details"** tab:
   - Scroll down to verify User data is present

## What You Created

The launch template defines:

✅ **What to launch:**
- Amazon Linux 2023 AMI
- t2.micro instance type

✅ **How to configure:**
- Security group: lb-test-app-sg
- 8 GiB storage
- Auto-assigned tags

✅ **What to run:**
- Install Docker
- Pull your app from Docker Hub
- Run the container on port 80

## Troubleshooting

### Can't find security group:

- Verify `lb-test-app-sg` exists
- Check you're in the correct region
- Security group must be in the same VPC

### User data not saving:

- Make sure you're in "Advanced details" section
- User data field is at the bottom
- Paste the entire script including `#!/bin/bash`

### Template creation fails:

- Check AMI is available in your region
- Verify instance type (t2.micro or t3.micro)
- Ensure you have permissions to create launch templates

## Testing the Template (Optional)

Before using it with Auto Scaling, you can test it:

1. **Go to Launch Templates**

2. **Select your template:** lb-test-lt

3. **Actions → Launch instance from template**

4. **Review and launch**

5. **Wait for instance** to start

6. **Test access** via its public IP

7. **Terminate the test instance** when done

This verifies your template works correctly!

## Next Steps

✅ Launch template created and ready for Auto Scaling!

Now proceed to: **06-create-auto-scaling-group.md**
