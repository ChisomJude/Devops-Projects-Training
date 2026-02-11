# Cleanup Resources

To avoid ongoing AWS charges, follow this guide to clean up all resources created during this project.

**Important:** Delete resources in the correct order to avoid dependency issues.

## Estimated Time
- 10-15 minutes to delete all resources
- Most deletions are immediate

## Cost Impact
After cleanup, you will have **$0 ongoing charges** from this project.

---

## Step 1: Delete Auto Scaling Group

**Why first?** This ensures no new instances are launched while you're cleaning up.

1. **Navigate to:**
   - EC2 Dashboard → Auto Scaling Groups

2. **Select:** lb-test-asg
   - ✅ Check the box next to it

3. **Click:** Actions → Delete

4. **Confirmation:**
   - Type "delete" in the confirmation box
   - Click "Delete"

5. **Wait for deletion:**
   - This also terminates all instances managed by Auto Scaling
   - Takes 1-2 minutes

✅ **Verify:** Auto Scaling group should be removed from the list

---

## Step 2: Delete Load Balancer

**Why now?** The load balancer can be deleted once Auto Scaling is gone.

1. **Navigate to:**
   - EC2 Dashboard → Load Balancers

2. **Select:** lb-test-alb
   - ✅ Check the box

3. **Actions → Delete load balancer**

4. **Confirmation:**
   - Type "confirm" in the confirmation box
   - Click "Delete"

5. **Wait:**
   - Deletion takes 2-3 minutes
   - Status changes to "deleted"

✅ **Verify:** Load balancer disappears from the list

**Note:** You can't access your application anymore after this step.

---

## Step 3: Delete Target Group

**Why now?** Target group can be deleted after the load balancer is gone.

1. **Navigate to:**
   - EC2 Dashboard → Target Groups

2. **Select:** lb-test-tg
   - ✅ Check the box

3. **Actions → Delete**

4. **Confirm deletion**

✅ **Verify:** Target group removed from list

---

## Step 4: Terminate Any Remaining EC2 Instances

**Why check?** Manual instances or test instances may still exist.

1. **Navigate to:**
   - EC2 Dashboard → Instances

2. **Check for instances:**
   - Look for any instances with tags:
     - lb-test-server-1
     - lb-test-server-2
     - lb-test-asg-instance
     - Any test instances

3. **If any exist:**
   - Select them (✅ check boxes)
   - Instance state → Terminate instance
   - Confirm termination

4. **Wait for termination:**
   - State changes to "Terminated"
   - After 1 hour, they'll disappear from the list

✅ **Verify:** No running instances related to the project

---

## Step 5: Delete Launch Template

1. **Navigate to:**
   - EC2 Dashboard → Launch Templates

2. **Select:** lb-test-lt
   - ✅ Check the box

3. **Actions → Delete template**

4. **Confirm deletion**

✅ **Verify:** Launch template removed

---

## Step 6: Delete Security Group

**Why last?** Other resources may depend on it.

1. **Navigate to:**
   - EC2 Dashboard → Security Groups

2. **Select:** lb-test-app-sg
   - ✅ Check the box

3. **Actions → Delete security groups**

4. **Confirm deletion**

### If deletion fails:

**Error:** "has a dependent object"

**Solution:**
1. Wait 5 more minutes for all instances to fully terminate
2. Check no load balancers or instances are using it
3. Try deletion again

✅ **Verify:** Security group removed from list

---

## Step 7: Delete Key Pair (Optional)

Only delete if you won't need this key pair for other projects.

1. **Navigate to:**
   - EC2 Dashboard → Key Pairs

2. **Select:** lb-test-key
   - ✅ Check the box

3. **Actions → Delete**

4. **Confirm deletion**

**Warning:** Once deleted, you can't recover this key pair. If you might use it for other EC2 instances, keep it.

✅ **Verify:** Key pair removed (or kept if you need it)

---

## Step 8: Verify All Resources Deleted

Go through each section to confirm:

### Auto Scaling Groups
- EC2 → Auto Scaling Groups
- ✅ Should be empty (or no lb-test-asg)

### Load Balancers
- EC2 → Load Balancers  
- ✅ Should be empty (or no lb-test-alb)

### Target Groups
- EC2 → Target Groups
- ✅ Should be empty (or no lb-test-tg)

### Instances
- EC2 → Instances
- ✅ No running instances with project tags
- Terminated instances will show briefly, then disappear

### Launch Templates
- EC2 → Launch Templates
- ✅ Should be empty (or no lb-test-lt)

### Security Groups
- EC2 → Security Groups
- ✅ No lb-test-app-sg
- Default security group will remain (that's normal)

### Key Pairs (if deleted)
- EC2 → Key Pairs
- ✅ No lb-test-key (or keep it if you want)

---

## Step 9: Check AWS Billing

Wait 24 hours, then verify:

1. **Go to Billing Dashboard**

2. **Check current charges:**
   - Should see charges stop after deletion
   - Final charges for partial hours may appear

3. **Review Free Tier usage:**
   - EC2 hours will decrease to 0
   - Load balancer hours will decrease to 0

---

## Deletion Order Summary

Remember this order to avoid dependency errors:

1. ✅ Auto Scaling Group (includes terminating instances)
2. ✅ Load Balancer
3. ✅ Target Group
4. ✅ Any remaining EC2 Instances
5. ✅ Launch Template
6. ✅ Security Group
7. ✅ Key Pair (optional)

**Total time:** ~10-15 minutes

---

## What If I Want to Keep Testing?

If you want to pause but not delete everything:

### Option 1: Stop Instances Temporarily
**Doesn't work with Auto Scaling** - Auto Scaling will restart them.

You must delete the Auto Scaling group first.

### Option 2: Set Desired Capacity to 0
1. Auto Scaling Groups → lb-test-asg
2. Edit → Desired capacity: 0, Min: 0
3. Save

This stops all instances but keeps the configuration.

**When ready to resume:**
- Set desired capacity back to 2, min: 2
- Instances will launch automatically

**Note:** Load balancer still incurs charges even with 0 instances.

### Option 3: Delete and Recreate
- Full deletion: $0/hour
- Use your guides to recreate everything in 30-45 minutes
- Best option for saving money during long breaks

---

## Final Cost Calculation

### What you spent during testing:

**Example:** Tested for 6 hours
- 2 instances × 6 hours × $0.0116/hour = $0.14
- Load balancer × 6 hours × $0.0225/hour = $0.14
- **Total: ~$0.28**

Very affordable for learning!

### Free Tier impact:
- Used ~12 hours of your 750 free EC2 hours
- Used ~6 hours of your 750 free ALB hours
- Plenty left for other projects this month

---

## Docker Hub Cleanup (Optional)

If you want to remove the Docker image:

1. **Login to Docker Hub:**
   - https://hub.docker.com

2. **Go to your repositories**

3. **Find:** lb-test-app

4. **Settings → Delete repository**

5. **Confirm deletion**

This frees up your Docker Hub storage (though the free tier is generous).

---

## Local Cleanup (Optional)

Remove local Docker images and files:

```bash
# Remove Docker containers
docker stop lb-test
docker rm lb-test

# Remove Docker images
docker rmi lb-test-app
docker rmi YOUR_DOCKERHUB_USERNAME/lb-test-app:latest

# Remove project folder
cd ..
rm -rf lb-test-app
```

---

## Troubleshooting Deletion Issues

### Can't delete load balancer:
- Error: "has a dependent object"
- **Solution:** Delete Auto Scaling group first
- Wait 2-3 minutes, try again

### Can't delete target group:
- Error: "is currently in use"
- **Solution:** Delete load balancer first
- Wait 2-3 minutes, try again

### Can't delete security group:
- Error: "has a dependent object"
- **Solution:** Ensure all instances are terminated
- Delete load balancer and target group first
- Wait 5 minutes, try again

### Instances keep launching:
- **Cause:** Auto Scaling group still exists
- **Solution:** Delete Auto Scaling group first

### Getting billed after deletion:
- **Cause:** Partial hour charges
- **Normal:** Last charges appear within 24 hours
- **Verify:** Check no resources remain after 1 day

---

## Cleanup Checklist

After cleanup, verify:

✅ No Auto Scaling groups exist  
✅ No load balancers exist  
✅ No target groups exist  
✅ No EC2 instances running (except unrelated ones)  
✅ No launch templates exist  
✅ Security group deleted  
✅ Key pair deleted (if desired)  
✅ AWS billing shows $0/hour for EC2 and ELB  

---

## Re-Creation If Needed

All your setup steps are documented! You can recreate everything by following:

1. 01-push-to-dockerhub.md (if image removed)
2. 02-create-security-group.md
3. 03-create-ec2-instance.md
4. 04-create-target-group.md
5. 05-create-load-balancer.md
6. 06-create-launch-template.md
7. 07-create-auto-scaling-group.md

**Time to recreate:** 30-45 minutes

---

## Learning Completed! 

You've successfully:

✅ Built a containerized application  
✅ Deployed to EC2 instances  
✅ Set up load balancing  
✅ Configured auto-scaling  
✅ Tested high availability  
✅ Cleaned up properly  

These are real-world DevOps skills used in production environments!

### What You Learned:

- **Docker:** Containerization and Docker Hub
- **EC2:** Instance management and configuration
- **ELB:** Application Load Balancer setup
- **Auto Scaling:** Automatic capacity management
- **High Availability:** Multi-AZ deployment
- **Infrastructure:** Security groups, target groups
- **Best Practices:** Proper cleanup and cost management

Keep these files for future reference! 
