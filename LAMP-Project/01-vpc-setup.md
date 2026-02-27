# Section 01 — VPC & Network Setup

> **Goal:** Create your own private network on AWS with a public subnet (for the web server) and a private subnet (for the database).

---

##  Why Do We Need a VPC?

When you use AWS, you're sharing the same massive data center with millions of other people. A **VPC (Virtual Private Cloud)** gives you your own isolated section of that data centre — your own private network where you control what goes in and out.

Think of it like this:
- AWS is a huge apartment building
- Your VPC is your apartment — you control the locks
- The **public subnet** is your living room — visitors (the internet) can come here
- The **private subnet** is your bedroom — only people already inside your apartment can go there

---

##  What We're Building

```
VPC: 10.0.0.0/16
├── Public Subnet:  10.0.1.0/24  (web server lives here)
│   └── Route Table → Internet Gateway (allows internet traffic)
│
└── Private Subnet: 10.0.2.0/24  (database lives here)
    └── Route Table → Local only  (NO internet access)
```

---

## Step 1 — Create the VPC

1. Go to **AWS Console → VPC → Your VPCs → Create VPC**

2. Fill in:

   | Field | Value |
   |-------|-------|
   | Name tag | `lamp-vpc` |
   | IPv4 CIDR | `10.0.0.0/16` |
   | Tenancy | Default |

   >  `10.0.0.0/16` means your VPC can have up to 65,536 IP addresses. More than enough for this project.

3. Click **Create VPC**

---

## Step 2 — Create the Public Subnet

1. Go to **VPC → Subnets → Create Subnet**

2. Fill in:

   | Field | Value |
   |-------|-------|
   | VPC | `lamp-vpc` |
   | Subnet name | `lamp-public-subnet` |
   | Availability Zone | Pick any (e.g. `us-east-1a`) |
   | IPv4 CIDR | `10.0.1.0/24` |

3. Click **Create Subnet**

4. After creating, select the subnet → **Actions → Edit subnet settings**
   -  Enable **Auto-assign public IPv4 address**
   - This means any EC2 launched here automatically gets a public IP

---

## Step 3 — Create the Private Subnet

1. **Create Subnet** again

   | Field | Value |
   |-------|-------|
   | VPC | `lamp-vpc` |
   | Subnet name | `lamp-private-subnet` |
   | Availability Zone | Same as public (e.g. `us-east-1a`) |
   | IPv4 CIDR | `10.0.2.0/24` |

2. Click **Create Subnet**

   >  Do NOT enable auto-assign public IP for this subnet. The database server should never have a public IP.

---

## Step 4 — Create an Internet Gateway

An **Internet Gateway** is the door between your VPC and the internet. Without it, nothing in your VPC can talk to the outside world.

1. Go to **VPC → Internet Gateways → Create Internet Gateway**

   | Field | Value |
   |-------|-------|
   | Name | `lamp-igw` |

2. Click **Create**

3. After creating: **Actions → Attach to VPC → select `lamp-vpc`**

---

## Step 5 — Create Route Tables

A **Route Table** is like a GPS for network traffic — it tells packets where to go.

### Public Route Table (for web server)

1. **VPC → Route Tables → Create Route Table**

   | Field | Value |
   |-------|-------|
   | Name | `lamp-public-rt` |
   | VPC | `lamp-vpc` |

2. Select it → **Routes tab → Edit routes → Add route**

   | Destination | Target |
   |-------------|--------|
   | `0.0.0.0/0` | `lamp-igw` (your internet gateway) |

   >  `0.0.0.0/0` means "all traffic". So any traffic going anywhere on the internet gets sent to the internet gateway.

3. **Subnet Associations tab → Edit subnet associations**
   -  Associate `lamp-public-subnet`

### Private Route Table (for database)

1. **Create Route Table**

   | Field | Value |
   |-------|-------|
   | Name | `lamp-private-rt` |
   | VPC | `lamp-vpc` |

2. **No internet route** — leave it with only the default local route (`10.0.0.0/16 → local`)

3. **Subnet Associations → Edit → Associate `lamp-private-subnet`**

---

##  Check Your Work

Your VPC setup should look like this in the AWS console:

| Resource | Name | Status |
|----------|------|--------|
| VPC | lamp-vpc | Available |
| Subnet | lamp-public-subnet | Available, auto-assign public IP ON |
| Subnet | lamp-private-subnet | Available, auto-assign public IP OFF |
| Internet Gateway | lamp-igw | Attached to lamp-vpc |
| Route Table | lamp-public-rt | Associated with public subnet, route to IGW |
| Route Table | lamp-private-rt | Associated with private subnet, local only |

---

>  Network ready! Move on to **[Section 02 → Launch EC2 Servers](./02-ec2-servers.md)**
