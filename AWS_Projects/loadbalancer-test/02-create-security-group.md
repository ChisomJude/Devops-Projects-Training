# Create Security Group

Security groups act as virtual firewalls for your EC2 instances. You'll need to create one before launching instances.

## Step 1: Navigate to Security Groups

1. **Login to AWS Console:**
   - Go to: https://console.aws.amazon.com
   - Login with your credentials

2. **Go to EC2 Dashboard:**
   - Search for "EC2" in the top search bar
   - Click on "EC2" to open the EC2 Dashboard

3. **Access Security Groups:**
   - In the left sidebar, scroll down to "Network & Security"
   - Click on "Security Groups"

## Step 2: Create New Security Group

1. **Click "Create security group" button** (orange button in top right)

2. **Configure Basic Details:**
   - **Security group name:** `lb-test-app-sg`
   - **Description:** `Security group for load balancer test application`
   - **VPC:** Select your default VPC (usually pre-selected)

## Step 3: Configure Inbound Rules

Add the following rules by clicking "Add rule" for each:

### Rule 1: HTTP Access
- **Type:** HTTP
- **Protocol:** TCP
- **Port range:** 80
- **Source:** Anywhere-IPv4 (0.0.0.0/0)
- **Description:** Allow HTTP traffic from anywhere

### Rule 2: SSH Access
- **Type:** SSH
- **Protocol:** TCP
- **Port range:** 22
- **Source:** My IP (recommended) or Anywhere-IPv4
- **Description:** Allow SSH access for management

### Optional Rule 3: HTTPS (for future use)
- **Type:** HTTPS
- **Protocol:** TCP
- **Port range:** 443
- **Source:** Anywhere-IPv4 (0.0.0.0/0)
- **Description:** Allow HTTPS traffic

## Step 4: Configure Outbound Rules

**Leave default outbound rule:**
- **Type:** All traffic
- **Destination:** 0.0.0.0/0
- This allows your instances to reach the internet (needed to pull Docker images)

## Step 5: Add Tags (Optional but Recommended)

Click "Add new tag":
- **Key:** `Name`
- **Value:** `lb-test-app-sg`

Click "Add new tag" again:
- **Key:** `Project`
- **Value:** `LoadBalancerTest`

## Step 6: Create Security Group

1. **Review your configuration:**
   - Verify all inbound rules are correct
   - Check the VPC is selected

2. **Click "Create security group"** (orange button at bottom)

3. **Success!**
   - You'll see a success message
   - Note down the **Security Group ID** (format: sg-xxxxxxxxx)
   - You'll need this ID when creating EC2 instances

## Quick Summary

Your security group should have:

**Inbound Rules:**
- Port 80 (HTTP) from 0.0.0.0/0
- Port 22 (SSH) from your IP
- Port 443 (HTTPS) optional

**Outbound Rules:**
- All traffic to 0.0.0.0/0

**Name:** lb-test-app-sg

## Security Best Practices

 **Important Security Notes:**

1. **SSH Access:** 
   - Use "My IP" instead of "Anywhere" for SSH (port 22) in production
   - This limits SSH access to only your current IP address

2. **Regular Reviews:**
   - Periodically review and update security group rules
   - Remove rules that are no longer needed

3. **Principle of Least Privilege:**
   - Only open ports that are absolutely necessary
   - Port 80 is needed for the load balancer to reach instances

## Next Steps

✅ Security group created and ready!

Now proceed to: **02-create-ec2-instance.md**
