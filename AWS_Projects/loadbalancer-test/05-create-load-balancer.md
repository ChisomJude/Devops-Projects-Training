# Create Application Load Balancer

The Application Load Balancer distributes incoming traffic across your EC2 instances for high availability.

## Step 1: Navigate to Load Balancers

1. **Go to EC2 Dashboard**

2. **In the left sidebar:**
   - Scroll to "Load Balancing"
   - Click "Load Balancers"

3. **Click "Create load balancer"** (orange button)

## Step 2: Select Load Balancer Type

You'll see three options:

- **Application Load Balancer** ← Select this one
  - Click "Create" under Application Load Balancer

## Step 3: Basic Configuration

### Load balancer name
- **Name:** `lb-test-alb`

### Scheme
- Select: **"Internet-facing"**
  - This allows public internet access to your load balancer

### IP address type
- Select: **"IPv4"**

## Step 4: Network Mapping

This is very important - you need to select multiple availability zones.

### VPC
- Select your **default VPC** (same as your instances)

### Mappings (Availability Zones)
You must select **at least 2 availability zones** for high availability.

1. **Check the boxes** for at least 2 availability zones:
   - ✅ us-east-1a (or your region's first AZ)
   - ✅ us-east-1b (or your region's second AZ)
   - You can select more if desired

2. **Subnet selection:**
   - For each AZ, select the public subnet
   - Usually only one subnet shows per AZ
   - Make sure they're public subnets (not private)

**Important:** Your EC2 instances can be in any of these AZs. The load balancer will work as long as they're in the same VPC.

## Step 5: Security Groups

### Remove default security group
- Click the "X" to remove the default security group

### Add your security group
1. Click in the security groups field
2. Select: **lb-test-app-sg**
   - This is the same security group your instances use
   - It allows HTTP traffic on port 80

## Step 6: Listeners and Routing

A listener checks for connection requests from clients.

### Default listener (already configured)
- **Protocol:** HTTP
- **Port:** 80

### Default action
1. Click the dropdown under "Default action"
2. Select: **lb-test-tg**
   - This is the target group you created earlier
3. The target group should appear with a green checkmark

## Step 7: Add Tags (Optional)

Scroll down and click "Add tag":
- **Key:** `Name`
- **Value:** `lb-test-alb`

Click "Add tag" again:
- **Key:** `Project`
- **Value:** `LoadBalancerTest`

## Step 8: Summary and Create

### Review the summary on the right:
- Load balancer name: lb-test-alb
- Scheme: Internet-facing
- Listeners: HTTP:80
- Availability Zones: 2 or more selected
- Security groups: lb-test-app-sg
- Target group: lb-test-tg

### Create the load balancer
1. **Click "Create load balancer"** (orange button at bottom)

2. **Success message appears:**
   - "Successfully created load balancer: lb-test-alb"
   - Click "View load balancer"

## Step 9: Wait for Load Balancer to Activate

1. **Find your load balancer** in the list

2. **Check the State column:**
   - Initially: "Provisioning" (takes 3-5 minutes)
   - Final state: "Active"
   - **Wait until it shows "Active"** before testing

3. **Copy the DNS name:**
   - Select your load balancer (checkbox on left)
   - In the "Description" tab below, find **DNS name**
   - Copy this DNS name (format: lb-test-alb-1234567890.us-east-1.elb.amazonaws.com)

## Step 10: Test Your Load Balancer

1. **Wait until State is "Active"** and both targets are healthy

2. **Open your browser** and paste the DNS name:
   ```
   http://lb-test-alb-1234567890.us-east-1.elb.amazonaws.com
   ```

3. **You should see:**
   - The load balancer test page
   - Server hostname and IP

4. **Refresh the page multiple times (F5 or Ctrl+R):**
   - You might see different hostnames/IPs
   - This shows the load balancer distributing traffic between instances!

5. **Test the health endpoint:**
   ```
   http://lb-test-alb-1234567890.us-east-1.elb.amazonaws.com/health
   ```

## Step 11: Verify Load Distribution

To see the load balancer in action:

1. **Keep refreshing the page** in your browser
   - Sometimes you'll hit server 1
   - Sometimes you'll hit server 2
   - The load balancer uses round-robin by default

2. **Open browser DevTools:**
   - Press F12
   - Go to Network tab
   - Refresh page and check which server responds

3. **Test from command line (if you have curl):**
   ```bash
   curl http://YOUR_LOAD_BALANCER_DNS_NAME
   ```
   
   Run it multiple times to see different servers respond

## Load Balancer Summary

You should have:

**Load Balancer:**
- Name: lb-test-alb
- Type: Application Load Balancer
- State: Active
- Scheme: Internet-facing

**Listener:**
- Protocol: HTTP
- Port: 80
- Target group: lb-test-tg

**Target Group:**
- 2 healthy targets (instances)

**Access:**
- Public DNS name working
- Traffic distributed between instances

## Troubleshooting

### Load balancer stuck in "Provisioning":

- Normal: Takes 3-5 minutes
- If >10 minutes: Check you selected at least 2 AZs
- Verify subnets are public (have internet gateway route)

### Can't access via DNS name:

1. **Verify load balancer state is "Active"**

2. **Check target health:**
   - EC2 → Target Groups → lb-test-tg → Targets tab
   - Both instances should show "healthy"

3. **Check security group:**
   - Load balancer security group must allow HTTP (port 80)
   - From source: 0.0.0.0/0

4. **Wait a bit longer:**
   - DNS propagation can take 1-2 minutes

### Getting 503 errors:

- Check if targets are healthy in the target group
- Verify instances are running
- Check if Docker containers are running on instances

### Not seeing traffic distributed:

- Keep refreshing - distribution may not be immediately obvious
- Load balancer uses sticky sessions by default (disabled in our setup)
- Both instances must be healthy

## Understanding What You Built

🎯 **Traffic Flow:**
1. User → Load Balancer DNS
2. Load Balancer → Checks target health
3. Load Balancer → Routes to healthy instance
4. Instance → Docker container → Flask app
5. Response back to user

🔄 **High Availability:**
- If one instance fails: Load balancer routes all traffic to healthy instance
- Health checks run every 30 seconds
- Unhealthy instances automatically removed from rotation

## Next Steps

✅ Load balancer created and distributing traffic!

Now proceed to: **05-create-launch-template.md** to set up auto-scaling
