# Load Balancer Test Application

A lightweight Flask application designed to demonstrate AWS Application Load Balancer, Auto Scaling, and high availability concepts.

##  What This Project Does

This project creates a simple web application that:
- Shows which server (instance) is responding to your request
- Displays the server's IP address and hostname
- Demonstrates load balancing across multiple instances
- Automatically recovers from instance failures
- Maintains high availability with auto-scaling

##  What You'll Learn

- Containerizing applications with Docker
- Publishing Docker images to Docker Hub
- Deploying applications on AWS EC2
- Setting up Application Load Balancers
- Configuring Auto Scaling Groups
- Implementing health checks
- Testing high availability scenarios
- Managing AWS infrastructure via the console

##  Architecture

```
Internet
    ↓
Application Load Balancer (distributes traffic)
    ↓
Target Group (health checks)
    ↓
┌─────────────┬─────────────┐
│  Instance 1 │  Instance 2 │  ← Auto Scaling Group (maintains 2 instances)
│   (AZ-1)    │   (AZ-2)    │  ← Different Availability Zones
└─────────────┴─────────────┘
        ↓             ↓
   Docker Container with Flask App
```

##  What's Included

```
Repo - [App Files](https://github.com/ChisomJude/sample/blob/master/lb-test-app)
├── app.py                         # Flask application
├── requirements.txt               # Python dependencies
├── Dockerfile                     # Container configuration
```

This Repo
```
├── 00-local-testing.md            # Test locally before deploying
├── 01-push-to-dockerhub.md        # Push image to Docker Hub
├── 02-create-security-group.md    # AWS Security Group setup
├── 03-create-ec2-instance.md      # Launch EC2 instances
├── 04-create-target-group.md      # Configure target group
├── 05-create-load-balancer.md     # Set up load balancer
├── 06-create-launch-template.md   # Create launch template
├── 07-create-auto-scaling-group.md # Configure auto-scaling
├── 08-testing-and-validation.md   # Test all scenarios
└── 09-cleanup-resources.md        # Remove everything to avoid charges
```

##  Quick Start

Follow the guides in order:

1. **[Local Testing](00-local-testing.md)** - Test the app on your machine
2. **[Push to Docker Hub](01-push-to-dockerhub.md)** - Make image available for AWS
3. **[Create Security Group](02-create-security-group.md)** - Configure firewall rules
4. **[Create EC2 Instances](03-create-ec2-instance.md)** - Launch virtual servers
5. **[Create Target Group](04-create-target-group.md)** - Set up health checks
6. **[Create Load Balancer](05-create-load-balancer.md)** - Distribute traffic
7. **[Create Launch Template](06-create-launch-template.md)** - Define instance blueprint
8. **[Create Auto Scaling Group](07-create-auto-scaling-group.md)** - Enable auto-scaling
9. **[Testing & Validation](08-testing-and-validation.md)** - Verify everything works
10. **[Cleanup Resources](09-cleanup-resources.md)** - Remove all resources

**Total setup time:** 45-60 minutes  
**Total testing time:** 30 minutes  
**Total cleanup time:** 10 minutes

##  Prerequisites

### For Local Testing
- Python 3.8 or higher
- Docker Desktop (for containerization)

### For AWS Deployment
- AWS account (free tier eligible)
- Docker Hub account (free)
- Basic understanding of AWS console

### Optional
- SSH client (for troubleshooting instances)
- curl or similar tool (for testing)

##  Cost Estimate

### Free Tier (First 12 Months)
If you're within the AWS free tier:
- **750 hours** of t2.micro/t3.micro EC2 per month
- **750 hours** of Application Load Balancer per month

**Note:** Running 2 instances 24/7 = 1,460 hours/month  
You'll use your free tier and incur some charges.

### After Free Tier
- **EC2 (2 × t2.micro):** ~$17/month
- **Application Load Balancer:** ~$16/month
- **Data transfer:** ~$1/month
- **Total:** ~$34/month

### Testing Costs (6 hours)
- 2 instances × 6 hours × $0.0116/hour = $0.14
- Load balancer × 6 hours × $0.0225/hour = $0.14
- **Total: ~$0.28**

**Always clean up resources when done!**

##  Key Concepts Demonstrated

### 1. Containerization
- Application packaged in Docker container
- Consistent environment across dev and production
- Easy deployment and scaling

### 2. Load Balancing
- Distribute traffic across multiple servers
- Automatic failover to healthy instances
- Session-independent routing

### 3. High Availability
- Multi-AZ deployment
- Automatic health checks
- Zero downtime during instance failures

### 4. Auto Scaling
- Maintain desired instance count
- Automatic instance replacement
- Self-healing infrastructure

### 5. Infrastructure as Code Concepts
- Reproducible infrastructure
- Version-controlled configuration
- Documented setup process

##  The Application

### Features
- **Main endpoint (`/`):** Shows server information
  - Server hostname (container ID)
  - Server IP address
  - Visual status indicator

- **Health endpoint (`/health`):** Returns JSON health status
  - Used by load balancer for health checks
  - Returns 200 OK when healthy

### Technology Stack
- **Framework:** Flask (Python)
- **Container:** Docker
- **Base Image:** Python 3.11 Slim
- **Web Server:** Flask development server (sufficient for testing)

### Application Flow
```
User Request
    ↓
Load Balancer
    ↓
Selected Instance
    ↓
Docker Container
    ↓
Flask App (port 80)
    ↓
Returns HTML with server info
```

##  Testing Scenarios

The project includes tests for:

1. ✅ **Basic load balancing** - Traffic distribution
2. ✅ **Health checks** - Endpoint verification
3. ✅ **Instance failure** - Auto-healing behavior
4. ✅ **Container failure** - Application-level failures
5. ✅ **Multi-AZ** - Availability zone distribution
6. ✅ **Concurrent traffic** - Load handling
7. ✅ **Capacity maintenance** - Auto Scaling response

##  Success Criteria

After completing this project, you should see:

✅ Load balancer DNS accessible from anywhere  
✅ 2 instances running in different AZs  
✅ Traffic distributed between instances  
✅ Automatic instance replacement on failure  
✅ Zero downtime during instance termination  
✅ Health checks passing consistently  
✅ Application shows different server IPs on refresh  

##  Troubleshooting

Common issues and solutions are documented in each guide. Key areas:

- **Security groups:** Ensure port 80 is open
- **Health checks:** Verify `/health` endpoint works
- **Docker:** Check container is running with `docker ps`
- **Auto Scaling:** Review Activity tab for errors
- **User data:** Check `/var/log/cloud-init-output.log`

##  Next Steps

After completing this project, consider:

1. **Add HTTPS** - Set up SSL/TLS certificate
2. **Dynamic scaling** - Scale based on CPU or traffic
3. **CloudWatch alarms** - Set up monitoring alerts
4. **Blue/Green deployment** - Practice deployment strategies
5. **Infrastructure as Code** - Convert to Terraform or CloudFormation
6. **CI/CD pipeline** - Automate Docker builds and deployments

##  Real-World Applications

This setup pattern is used in production for:

- **E-commerce sites** - Handle traffic spikes
- **APIs** - Ensure high availability
- **Web applications** - Distribute load
- **Microservices** - Deploy scalable services
- **SaaS platforms** - Multi-tenant applications

##  Important Notes

1. **Always clean up** - Follow the cleanup guide to avoid charges
2. **Security** - This is a test setup; production needs HTTPS, WAF, etc.
3. **Monitoring** - Production should include CloudWatch, logging
4. **Backups** - Production needs backup and disaster recovery
5. **Cost monitoring** - Set up billing alerts in AWS


**Done testing?** Don't forget [09-cleanup-resources.md](09-cleanup-resources.md) and give this repo a Star!

##  Additional Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS ELB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)
- [Docker Documentation](https://docs.docker.com/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)
