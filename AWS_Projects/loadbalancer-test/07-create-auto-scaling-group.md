# Create Auto Scaling Group

Auto Scaling automatically maintains your desired number of instances, replacing failed instances and scaling based on demand.

## What Will This Do?

- **Maintain 2 running instances** at all times
- **Replace failed instances** automatically
- **Health checks** via load balancer
- **Distribute instances** across multiple availability zones

## Step 1: Navigate to Auto Scaling Groups

1. **Go to EC2 Dashboard**

2. **In the left sidebar:**
   - Scroll to "Auto Scaling"
   - Click "Auto Scaling Groups"

3. **Click "Create Auto Scaling group"** (orange button)

## Step 2: Choose Launch Template

### Auto Scaling group name
- **Name:** `lb-test-asg`

### Launch template
1. Click the dropdown under "Launch template"
2. Select: **lb-test-lt**
3. **Version:** Latest (1)

### Click "Next" at the bottom

## Step 3: Choose Instance Launch Options

This is where you configure WHERE instances will be launched.

### Network

**VPC:**
- Select your **default VPC** (same VPC as everything else)

**Availability Zones and subnets:**
- This is critical for high availability
- **Select at least 2 availability zones** (same as your load balancer)
- Click "Select all" or manually select:
  - ✅ us-east-1a (subnet)
  - ✅ us-east-1b (subnet)
  - ✅ us-east-1c (subnet) - if available
  
The more AZs, the more resilient your application!

### Instance type requirements (skip this section)
- Leave as default

### Click "Next" at the bottom

## Step 4: Configure Advanced Options

This connects your Auto Scaling group to the load balancer.

### Load balancing

1. **Select:** ✅ **"Attach to an existing load balancer"**

2. **Choose from your load balancer target groups:**
   - Select: **"Choose from your load balancer target groups"**

3. **Existing load balancer target groups:**
   - Select: **lb-test-tg**
   - This is the target group connected to your load balancer

### Health checks

This is VERY important!

1. **Health check type:**
   - ✅ Check **"ELB"** (Elastic Load Balancer)
   - This uses the load balancer health checks
   - More reliable than EC2 status checks alone

2. **Health check grace period:**
   - Change to: **300 seconds** (5 minutes)
   - This gives new instances time to boot and start Docker
   - Prevents premature termination of starting instances

### Additional settings (optional)

**Monitoring:**
- ✅ Check **"Enable group metrics collection within CloudWatch"**
- Helps you monitor Auto Scaling activity

### Click "Next" at the bottom

## Step 5: Configure Group Size and Scaling Policies

This is where you define how many instances to maintain.

### Group size

**Desired capacity:**
- Set to: **2**
- This is how many instances you want running normally

**Minimum capacity:**
- Set to: **2**
- Auto Scaling will never go below this number
- Even if instances fail, it will launch new ones

**Maximum capacity:**
- Set to: **4**
- Maximum instances that can be launched
- Room for scaling up if needed

### Scaling policies (Optional - Advanced)

For now, select: **"None"**
- We'll maintain 2 instances at all times
- No dynamic scaling based on CPU or traffic
- You can add this later if needed

### Instance maintenance policy
- Leave as default

### Click "Next" at the bottom

## Step 6: Add Notifications (Optional)

**Skip this section** - click "Next"

You can add SNS notifications later if you want alerts when:
- Instances are launched
- Instances are terminated
- Scaling events occur

## Step 7: Add Tags (Optional but Recommended)

Click "Add tag":

**Tag 1:**
- **Key:** `Name`
- **Value:** `lb-test-asg-instance`
- Tag new instances: ✅ (checked)

**Tag 2:**
- **Key:** `Project`
- **Value:** `LoadBalancerTest`
- Tag new instances: ✅ (checked)

**Tag 3:**
- **Key:** `ManagedBy`
- **Value:** `AutoScaling`
- Tag new instances: ✅ (checked)

## Step 8: Review

Review all settings:

**Auto Scaling group:**
- Name: lb-test-asg
- Launch template: lb-test-lt

**Network:**
- VPC: Your default VPC
- Subnets: 2+ availability zones

**Load balancing:**
- Target group: lb-test-tg
- Health check: ELB

**Group size:**
- Desired: 2
- Minimum: 2
- Maximum: 4

## Step 9: Create Auto Scaling Group

1. **Click "Create Auto Scaling group"** (orange button at bottom)

2. **Success!**
   - You'll see your Auto Scaling group in the list

## Step 10: Monitor Auto Scaling Group

### View Auto Scaling Activity

1. **Click on your Auto Scaling group:** lb-test-asg

2. **Go to "Activity" tab:**
   - You'll see instances being launched
   - Status will show "Successful" when complete
   - This can take 5-10 minutes for both instances

3. **Go to "Instance management" tab:**
   - Shows currently running instances
   - Health status
   - Availability zone distribution

### Important: Terminate Your Original Instances

You now have Auto Scaling managing instances, so you should terminate the manual instances you created earlier.

1. **Go to EC2 → Instances**

2. **Find your original instances:**
   - lb-test-server-1
   - lb-test-server-2

3. **Select them** (checkboxes)

4. **Instance state → Terminate instance**

5. **Confirm termination**

**Why?** 
- Auto Scaling is now managing instance count
- The original instances would conflict with Auto Scaling
- Auto Scaling will maintain 2 instances automatically

## Step 11: Verify Everything Works

### Check Target Group Health

1. **Go to: EC2 → Target Groups → lb-test-tg**

2. **Click "Targets" tab:**
   - Wait for Auto Scaling instances to register (2-3 minutes)
   - Both instances should show "healthy"
   - They'll have the tag: lb-test-asg-instance

### Test Load Balancer

1. **Go to: EC2 → Load Balancers**

2. **Copy your load balancer DNS name**

3. **Open in browser:**
   ```
   http://lb-test-alb-1234567890.us-east-1.elb.amazonaws.com
   ```

4. **Verify:**
   - Application loads correctly
   - Refresh shows different servers
   - Health endpoint works

## Step 12: Test Auto-Healing

Let's verify Auto Scaling replaces failed instances!

### Simulate Instance Failure

1. **Go to: EC2 → Instances**

2. **Find one Auto Scaling instance** (tagged: lb-test-asg-instance)

3. **Select it** and click: **Instance state → Terminate instance**

4. **Confirm termination**

### Watch Auto Scaling React

1. **Go to: Auto Scaling Groups → lb-test-asg → Activity tab**

2. **Within 1-2 minutes, you'll see:**
   - "Terminating EC2 instance: i-xxxxx"
   - "Launching a new EC2 instance: i-yyyyy"
   - Auto Scaling maintains desired capacity of 2!

3. **Check Instances:**
   - Go to EC2 → Instances
   - New instance will appear
   - After ~5 minutes, it will be healthy in the target group

4. **Load balancer continues working:**
   - During replacement, traffic goes to healthy instance
   - Once new instance is healthy, traffic is distributed again
   - **Zero downtime!**

## Auto Scaling Group Summary

You now have:

✅ **Auto Scaling group maintaining 2 instances**  
✅ **Instances distributed across multiple AZs**  
✅ **Health checks via load balancer**  
✅ **Automatic instance replacement on failure**  
✅ **Load balancer distributing traffic**  

## Troubleshooting

### No instances launching:

1. **Check Activity tab:**
   - Look for error messages
   - Common: IAM permissions, quota limits

2. **Verify launch template:**
   - Has correct AMI
   - Has correct security group
   - User data script is valid

3. **Check subnet configuration:**
   - Subnets must be in the same VPC
   - Subnets should be public (for internet access)

### Instances launched but unhealthy:

1. **Check health check grace period:**
   - Should be at least 300 seconds
   - Gives time for Docker to install and start

2. **Verify target group health checks:**
   - Path: /health
   - Port: 80
   - Should return 200

3. **SSH into an instance** and check:
   ```bash
   sudo docker ps
   sudo docker logs <container-id>
   ```

### Instances stuck in pending:

- Normal: Takes 5-10 minutes total
- Docker installation takes time
- Check Activity tab for errors

## Understanding the Auto Scaling Lifecycle

 **Normal Operation:**
1. Auto Scaling maintains 2 healthy instances
2. Distributes across availability zones
3. Health checks every 30 seconds

 **When Instance Fails:**
1. Health check fails (2 consecutive failures)
2. Load balancer stops routing traffic to it
3. Auto Scaling detects unhealthy instance
4. Auto Scaling terminates unhealthy instance
5. Auto Scaling launches replacement instance
6. New instance boots, Docker installs, app starts
7. Health checks pass (2 consecutive successes)
8. Load balancer routes traffic to new instance

 **Result:** High availability with automatic recovery!

## Cost Awareness

**Current setup costs (approximate):**
- 2 x t2.micro instances: ~$0.0116/hour each = ~$0.0232/hour
- Application Load Balancer: ~$0.0225/hour
- **Total: ~$0.045/hour or ~$33/month**

Remember to clean up resources when done testing!

## Next Steps

✅ Auto Scaling group created and working!

Now proceed to: **07-testing-and-validation.md** to test all scenarios
