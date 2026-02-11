# Create Target Group

Target groups route requests to registered targets (your EC2 instances). You need to create this before setting up the load balancer.

## Step 1: Navigate to Target Groups

1. **Go to EC2 Dashboard**

2. **In the left sidebar:**
   - Scroll down to "Load Balancing"
   - Click on "Target Groups"

3. **Click "Create target group"** (blue button)

## Step 2: Specify Group Details

### Choose a target type
- Select: **"Instances"** (should be pre-selected)
- Click "Next" at the bottom

Wait! Don't click Next yet. Configure the following first:

### Target group name
- **Target group name:** `lb-test-tg`

### Protocol and Port
- **Protocol:** HTTP
- **Port:** 80
- **IP address type:** IPv4

### VPC
- Select your **default VPC** (same VPC where your instances are running)

### Protocol version
- **Protocol version:** HTTP1

## Step 3: Configure Health Checks

This is crucial for the load balancer to know which instances are healthy.

### Health check protocol
- **Protocol:** HTTP

### Health check path
- **Path:** `/health`
  - This matches the health endpoint in our Flask app

### Advanced health check settings (expand this section)

Click "Advanced health check settings" to expand:

- **Port:** Traffic port
- **Healthy threshold:** 2 (consecutive health checks)
- **Unhealthy threshold:** 2
- **Timeout:** 5 seconds
- **Interval:** 30 seconds
- **Success codes:** 200

These settings mean:
- Instance is marked healthy after 2 successful health checks
- Instance is marked unhealthy after 2 failed health checks
- Health checks happen every 30 seconds

## Step 4: Add Tags (Optional)

Click "Add tag":
- **Key:** `Name`
- **Value:** `lb-test-tg`

Click "Add tag" again:
- **Key:** `Project`
- **Value:** `LoadBalancerTest`

## Step 5: Click "Next"

Now click the blue "Next" button at the bottom.

## Step 6: Register Targets (EC2 Instances)

On this page, you'll select which instances to add to the target group.

1. **Available instances** section shows all your EC2 instances

2. **Select your instances:**
   - Check the boxes next to:
     - `lb-test-server-1`
     - `lb-test-server-2`

3. **Ports for the selected instances:**
   - The port should already show **80** (from the target group configuration)
   - Leave it as 80

4. **Click "Include as pending below"** button

5. **Verify in "Review targets" section:**
   - You should see both instances listed
   - Each should show port 80

## Step 7: Create Target Group

1. **Click "Create target group"** (blue button at bottom)

2. **Success!**
   - You'll see a success message
   - Your target group is now created

## Step 8: Verify Target Health

This is important to ensure your instances are healthy before creating the load balancer.

1. **Click on your target group name:** `lb-test-tg`

2. **Go to the "Targets" tab** (bottom section)

3. **Check the "Health status" column:**
   - Initially: Both instances will show "initial"
   - After ~30-60 seconds: Both should show "healthy"
   - If "unhealthy": See troubleshooting below

4. **Wait until both instances show "healthy"** before proceeding to create the load balancer

## Target Group Summary

You should see:

**Basic configuration:**
- Name: lb-test-tg
- Protocol: HTTP
- Port: 80
- Health check path: /health

**Registered targets:**
- lb-test-server-1 (healthy)
- lb-test-server-2 (healthy)

## Troubleshooting

### Targets showing "unhealthy":

1. **Check if the app is running on instances:**
   - Open browser: `http://INSTANCE_PUBLIC_IP`
   - Should show the app

2. **Check health endpoint specifically:**
   - Visit: `http://INSTANCE_PUBLIC_IP/health`
   - Should return JSON: `{"status": "healthy", "hostname": "..."}`

3. **Check security group:**
   - The security group must allow HTTP (port 80) from anywhere
   - Go to: EC2 → Security Groups → lb-test-app-sg
   - Verify inbound rule for port 80

4. **Wait longer:**
   - Health checks run every 30 seconds
   - Need 2 consecutive successes
   - Can take up to 2 minutes total

5. **Check instance logs:**
   - SSH into instance
   - Check Docker: `sudo docker ps`
   - Check logs: `sudo docker logs <container-id>`

### Targets showing "unused":

- This is normal if you haven't created the load balancer yet
- Will change to "healthy" once traffic is routed

### Can't find my instances:

- Ensure instances are in "running" state
- Verify they're in the same VPC as the target group
- Refresh the page

## What Happens Next

The target group will:
- Continuously monitor your instances using the /health endpoint
- Route traffic only to healthy instances
- Automatically remove unhealthy instances from rotation
- Add them back when they become healthy again

## Next Steps

✅ Target group created with 2 healthy instances!

Now proceed to: **04-create-load-balancer.md**
