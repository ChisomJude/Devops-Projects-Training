# Testing and Validation

Now let's thoroughly test your load balancing and auto-scaling setup to verify everything works as expected.

## Pre-Test Checklist

Before testing, verify:

✅ Auto Scaling group shows 2 healthy instances  
✅ Target group shows 2 healthy targets  
✅ Load balancer state is "Active"  
✅ Load balancer DNS name is accessible  

## Test 1: Basic Load Balancer Functionality

### Objective
Verify the load balancer distributes traffic between instances.

### Steps

1. **Get your load balancer DNS name:**
   - EC2 → Load Balancers → lb-test-alb
   - Copy the DNS name

2. **Open the application in browser:**
   ```
   http://YOUR-LOAD-BALANCER-DNS
   ```

3. **Take note of the server hostname/IP displayed**

4. **Refresh the page multiple times (10-15 times)**

### Expected Results

✅ Application loads successfully  
✅ You see different server hostnames/IPs as you refresh  
✅ Traffic is distributed between 2 servers  
✅ No errors or timeouts  

### Verification Using curl (Optional)

If you have curl installed:

```bash
# Run this 10 times and observe different server IPs
for i in {1..10}; do
  curl -s http://YOUR-LOAD-BALANCER-DNS | grep "Server IP"
done
```

---

## Test 2: Health Check Endpoint

### Objective
Verify the health check endpoint works correctly.

### Steps

1. **Access health endpoint:**
   ```
   http://YOUR-LOAD-BALANCER-DNS/health
   ```

2. **Check the response**

### Expected Results

✅ Returns JSON:
```json
{
  "status": "healthy",
  "hostname": "container-id"
}
```
✅ HTTP status code: 200  
✅ Responds quickly (< 1 second)  

---

## Test 3: Auto-Healing - Instance Termination

### Objective
Verify Auto Scaling replaces terminated instances.

### Steps

1. **Note current instance IDs:**
   - EC2 → Instances
   - Note the 2 instance IDs with tag: lb-test-asg-instance

2. **Keep load balancer open in browser**

3. **Terminate one instance:**
   - Select one instance
   - Instance state → Terminate instance
   - Confirm

4. **Immediately check load balancer:**
   - Refresh your browser on the load balancer URL
   - Application should still work!

5. **Watch the activity:**
   - Go to: Auto Scaling Groups → lb-test-asg → Activity tab
   - You should see: "Terminating EC2 instance"
   - Then: "Launching a new EC2 instance"

6. **Monitor target group:**
   - EC2 → Target Groups → lb-test-tg → Targets
   - Watch the terminated instance become "unhealthy"
   - After ~5 minutes, new instance appears and becomes "healthy"

7. **Continue testing load balancer:**
   - Keep refreshing during this time
   - Application continues to work
   - Initially all traffic goes to 1 server
   - After new instance is healthy, traffic distributes again

### Expected Results

✅ Load balancer continues working during instance replacement  
✅ Auto Scaling launches new instance within 1-2 minutes  
✅ New instance becomes healthy within 5-7 minutes  
✅ Instance count returns to 2  
✅ Zero downtime experienced  

### Timeline

- **T+0:** Instance terminated
- **T+1 min:** Auto Scaling detects and launches replacement
- **T+3 min:** New instance running, Docker installing
- **T+5 min:** Application started, health checks passing
- **T+6 min:** Instance added to load balancer rotation

---

## Test 4: Auto-Healing - Container Failure

### Objective
Verify Auto Scaling replaces instances when the application fails.

### Steps

1. **SSH into one instance:**
   ```bash
   ssh -i lb-test-key.pem ec2-user@INSTANCE_PUBLIC_IP
   ```

2. **Stop the Docker container:**
   ```bash
   sudo docker stop lb-test-app
   ```

3. **Exit SSH:**
   ```bash
   exit
   ```

4. **Monitor target group health:**
   - EC2 → Target Groups → lb-test-tg → Targets
   - After ~1 minute: Instance shows "unhealthy"

5. **Monitor Auto Scaling activity:**
   - After health checks fail, Auto Scaling terminates the instance
   - New instance launches automatically

6. **Check load balancer:**
   - Application continues working
   - Traffic routes to healthy instance

### Expected Results

✅ Container stops, health checks fail  
✅ Target marked unhealthy within 1 minute  
✅ Auto Scaling terminates unhealthy instance  
✅ New instance launches automatically  
✅ Application remains accessible throughout  

---

## Test 5: Multiple Availability Zones

### Objective
Verify instances are distributed across availability zones.

### Steps

1. **Check instance distribution:**
   - EC2 → Instances
   - Select both Auto Scaling instances
   - Check "Details" tab → "Availability Zone"

### Expected Results

✅ Instances are in different availability zones  
✅ Example: one in us-east-1a, one in us-east-1b  

This provides AZ-level fault tolerance!

---

## Test 6: Load Balancer Sticky Sessions (Optional)

### Objective
Verify each request can go to any server (no sticky sessions).

### Steps

1. **Open browser DevTools:**
   - Press F12
   - Go to Network tab

2. **Load the application:**
   ```
   http://YOUR-LOAD-BALANCER-DNS
   ```

3. **Check response headers:**
   - Look for any "Set-Cookie" headers
   - Should be none related to load balancing

4. **Refresh multiple times:**
   - Clear Network tab each time
   - Verify you hit different servers

### Expected Results

✅ No sticky session cookies  
✅ Each request can go to any healthy instance  
✅ True round-robin distribution  

---

## Test 7: Concurrent Traffic

### Objective
Verify load balancer handles concurrent requests.

### Steps (Using Apache Bench or similar)

If you have `ab` (Apache Bench) installed:

```bash
ab -n 100 -c 10 http://YOUR-LOAD-BALANCER-DNS/
```

This sends 100 requests with 10 concurrent connections.

### Expected Results

✅ All requests succeed (no failures)  
✅ Requests distributed across both instances  
✅ Average response time < 500ms  
✅ No timeout errors  

---

## Test 8: Desired Capacity Maintenance

### Objective
Verify Auto Scaling maintains exactly 2 instances.

### Steps

1. **Terminate BOTH instances:**
   - EC2 → Instances
   - Select both Auto Scaling instances
   - Instance state → Terminate instance

2. **Immediately check Auto Scaling activity:**
   - Auto Scaling Groups → lb-test-asg → Activity tab

3. **Monitor:**
   - Should show 2 instances being launched
   - Maintains desired capacity of 2

4. **Wait for instances to be healthy:**
   - Check Instance management tab
   - Both instances should appear
   - Check target group for health status

### Expected Results

✅ Auto Scaling launches 2 new instances  
✅ Returns to desired capacity within 1-2 minutes  
✅ Instances become healthy within 5-7 minutes  
✅ Load balancer resumes normal operation  

**Note:** There will be brief downtime (5-7 minutes) when ALL instances are terminated, but this demonstrates Auto Scaling works correctly.

---

## Test 9: Manual Scaling (Optional Advanced)

### Objective
Test changing desired capacity.

### Steps

1. **Go to Auto Scaling Groups → lb-test-asg**

2. **Click "Edit" in the "Details" section**

3. **Change desired capacity to 3**

4. **Save**

5. **Monitor Activity tab:**
   - Should launch 1 additional instance

6. **Check target group:**
   - After ~5 minutes, should show 3 healthy targets

7. **Test load balancer:**
   - Should distribute traffic across 3 instances

8. **Scale back down:**
   - Edit again, set desired capacity to 2
   - Auto Scaling terminates 1 instance
   - Returns to 2 instances

### Expected Results

✅ Auto Scaling launches additional instances when desired > current  
✅ Auto Scaling terminates instances when desired < current  
✅ Load balancer adapts automatically  

---

## Test 10: Cost Monitor Check

### Objective
Understand your current AWS costs.

### Steps

1. **Go to AWS Billing Dashboard:**
   - Search for "Billing" in top search bar
   - Click "Billing Dashboard"

2. **Check current month costs:**
   - See charges for EC2 and ELB

3. **Review Free Tier usage:**
   - Click "Free Tier" in left menu
   - Check usage of EC2 and ELB services

### What to Expect

**Free Tier (first 12 months):**
- 750 hours of t2.micro/t3.micro per month
- 750 hours of Application Load Balancer
- You're using ~1,460 hours/month for 2 instances
- **You'll exceed free tier with 2 instances running 24/7**

**Estimated costs (after free tier):**
- ~$0.045/hour or ~$33/month

---

## Validation Checklist

After all tests, verify:

✅ Load balancer distributes traffic correctly  
✅ Health checks work on /health endpoint  
✅ Auto Scaling replaces failed instances  
✅ Zero downtime during instance replacement  
✅ Instances distributed across AZs  
✅ Desired capacity maintained (2 instances)  
✅ Application accessible via load balancer DNS  
✅ Target group shows 2 healthy targets  

---

## Common Issues and Solutions

### Issue: Instances stay unhealthy

**Solutions:**
1. Check Docker is running: `sudo docker ps`
2. Check container logs: `sudo docker logs <container-id>`
3. Test health endpoint directly on instance: `curl http://localhost/health`
4. Verify security group allows port 80
5. Increase health check grace period to 400 seconds

### Issue: Load balancer returns 503 errors

**Solutions:**
1. Check target group has healthy targets
2. Verify instances are running
3. Check security group allows load balancer to reach instances
4. Wait longer - instances may still be starting

### Issue: Auto Scaling not replacing instances

**Solutions:**
1. Verify health check type is "ELB"
2. Check health check grace period isn't too long
3. Check Auto Scaling activity tab for errors
4. Verify desired capacity = minimum capacity = 2

### Issue: Can't SSH into instances

**Solutions:**
1. Verify security group allows SSH (port 22)
2. Check you're using correct key file
3. Ensure key has correct permissions: `chmod 400 lb-test-key.pem`
4. Verify instance has public IP

---

## Performance Benchmarks

Expected performance for this setup:

- **Response time:** < 100ms (local server processing)
- **Load balancer latency:** < 50ms added
- **Health check interval:** 30 seconds
- **Instance replacement time:** 5-7 minutes
- **Concurrent connections:** 100+ per instance

---

## Next Steps

✅ All tests completed successfully!

Now proceed to: **08-cleanup-resources.md** to clean up and avoid charges

Or keep testing and exploring:
- Try scaling to 3-4 instances
- Monitor CloudWatch metrics
- Set up scaling policies based on CPU
- Add HTTPS with SSL certificate
- Test different failure scenarios
