# Network Fundamentals for DevOps Engineers



## 1. 


---

## 2. The OSI Model

The OSI (Open Systems Interconnection) model is a conceptual framework that standardizes network communication into 7 layers.

```
Layer 7 - Application   → HTTP, HTTPS, DNS, FTP, SMTP          [DevOps Focus]
Layer 6 - Presentation  → TLS/SSL, Encryption, Encoding        [DevOps Focus]
Layer 5 - Session       → Sessions, Authentication
Layer 4 - Transport     → TCP, UDP (Ports live here)           [DevOps Focus]
Layer 3 - Network       → IP Addressing, Routing (Routers)     [DevOps Focus]
Layer 2 - Data Link     → MAC Addresses, Switches, ARP
Layer 1 - Physical      → Cables, NICs, Fiber, Wi-Fi signals
```

> **DevOps Focus:** You'll mostly work at Layers 3–7. Layers 3–4 for infrastructure routing and port management, Layer 7 for application debugging, reverse proxies, and load balancing.

---

## 3. IP Addressing

### 3.1 What is an IP Address?

An IP address is a unique identifier assigned to every device on a network. It tells the network *where* to send packets.

**IPv4** — 32-bit address written in dotted decimal notation:

```
192.168.1.10
```

Each octet is 8 bits (0–255), totaling 4 octets.

```
192       .  168      .  1        .  10
11000000  .  10101000 .  00000001 .  00001010
```

**IPv6** — 128-bit address (for when IPv4 ran out):

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

---

### 3.2 IP Address Classes (Classful — Legacy but Important)

| Class | Range                         | Default Subnet Mask | CIDR | Usage                  |
|-------|-------------------------------|---------------------|------|------------------------|
| A     | 1.0.0.0 – 126.255.255.255     | 255.0.0.0           | /8   | Large networks         |
| B     | 128.0.0.0 – 191.255.255.255   | 255.255.0.0         | /16  | Medium networks        |
| C     | 192.0.0.0 – 223.255.255.255   | 255.255.255.0       | /24  | Small networks         |
| D     | 224.0.0.0 – 239.255.255.255   | N/A                 | —    | Multicast              |
| E     | 240.0.0.0 – 255.255.255.255   | N/A                 | —    | Reserved/Experimental  |

---

### 3.3 Private vs Public IP Addresses

Private IP addresses are **not routable on the internet**. They are used inside VPCs, LANs, and internal networks.

| Range                           | Class | CIDR           | Notes                          |
|---------------------------------|-------|----------------|-------------------------------|
| 10.0.0.0 – 10.255.255.255       | A     | 10.0.0.0/8     | Preferred for AWS VPCs         |
| 172.16.0.0 – 172.31.255.255     | B     | 172.16.0.0/12  | Common for Docker networks     |
| 192.168.0.0 – 192.168.255.255   | C     | 192.168.0.0/16 | Home networks / small offices  |

**Special Addresses:**

```
127.0.0.1         → Loopback (localhost) — your own machine
0.0.0.0           → Represents "any address" (used in routing/binding)
255.255.255.255   → Limited broadcast
169.254.0.0/16    → Link-local (APIPA — auto-assigned when DHCP fails)
100.64.0.0/10     → AWS uses this range for NAT internally
```

---

## 4. Subnetting and CIDR

### 4.1 What is a Subnet?

A subnet (subnetwork) divides a large network into smaller, more manageable pieces. This improves:
- **Security** — isolate workloads
- **Performance** — reduce broadcast domains
- **Organization** — public vs private tiers

### 4.2 Subnet Mask

A subnet mask tells you which part of the IP is the **network** and which is the **host**.

```
IP Address:    192.168.1.10
Subnet Mask:   255.255.255.0

In binary:
IP:   11000000.10101000.00000001.00001010
Mask: 11111111.11111111.11111111.00000000
      |-------- Network Part ---------|Host|
```

The `1`s in the mask = Network portion
The `0`s in the mask = Host portion

---

### 4.3 CIDR — Classless Inter-Domain Routing

CIDR replaced the old classful system. Instead of fixed masks, CIDR uses a **prefix length** (slash notation) to define how many bits belong to the network.

```
192.168.1.0/24

/24 means → 24 bits for network, 8 bits for hosts
           → 2^8 = 256 total addresses
           → 256 - 2 = 254 usable hosts
             (subtract network address and broadcast address)
```

---

### 4.4 CIDR Prefix Cheat Sheet

| CIDR | Subnet Mask         | Total IPs   | Usable Hosts | Common Use                      |
|------|---------------------|-------------|--------------|----------------------------------|
| /8   | 255.0.0.0           | 16,777,216  | 16,777,214   | Large org / Class A equivalent   |
| /16  | 255.255.0.0         | 65,536      | 65,534       | AWS VPC (recommended)            |
| /24  | 255.255.255.0       | 256         | 254          | Standard subnet size             |
| /25  | 255.255.255.128     | 128         | 126          | Split /24 in half                |
| /26  | 255.255.255.192     | 64          | 62           | Quarter of /24                   |
| /27  | 255.255.255.224     | 32          | 30           | Small subnet                     |
| /28  | 255.255.255.240     | 16          | 14           | Very small subnet                |
| /29  | 255.255.255.248     | 8           | 6            | Point-to-point links             |
| /30  | 255.255.255.252     | 4           | 2            | Router-to-router links           |
| /32  | 255.255.255.255     | 1           | 1            | Single host route                |

---

### 4.5 CIDR Math: How to Subnet (Step by Step)

**Scenario:** You're given `10.0.0.0/16` and need to create 4 equal subnets for your AWS VPC.

```
Step 1: Total IPs in /16
  /16 → 32 - 16 = 16 host bits
  2^16 = 65,536 total IPs

Step 2: Borrow 2 bits to create 4 subnets
  2^2 = 4 subnets
  New prefix = /16 + 2 = /18
  Each subnet = 2^(32-18) = 2^14 = 16,384 IPs

Step 3: Your 4 subnets
  Subnet 1: 10.0.0.0/18    → 10.0.0.0   – 10.0.63.255
  Subnet 2: 10.0.64.0/18   → 10.0.64.0  – 10.0.127.255
  Subnet 3: 10.0.128.0/18  → 10.0.128.0 – 10.0.191.255
  Subnet 4: 10.0.192.0/18  → 10.0.192.0 – 10.0.255.255
```

---

### 4.6 AWS Reserved IPs in Every Subnet

AWS reserves **5 IP addresses** in every subnet (not just 2 like standard networking):

```
Example subnet: 10.0.1.0/24

10.0.1.0   → Network address (reserved)
10.0.1.1   → VPC Router (AWS reserved)
10.0.1.2   → DNS Server (AWS reserved)
10.0.1.3   → Future use (AWS reserved)
10.0.1.255 → Broadcast address (AWS reserved)

Usable IPs: 256 - 5 = 251 hosts
```

---

## 5. Key Networking Protocols

### 5.1 TCP vs UDP

| Feature        | TCP                                    | UDP                           |
|----------------|----------------------------------------|-------------------------------|
| Connection     | Connection-oriented (3-way handshake)  | Connectionless                |
| Reliability    | Guaranteed delivery                    | Best effort — no guarantee    |
| Ordering       | Ordered packets                        | No ordering                   |
| Speed          | Slower (overhead)                      | Faster (low overhead)         |
| Use cases      | HTTP, HTTPS, SSH, databases            | DNS, video streaming, VoIP    |



---

### 5.2 Important Ports to Know

| Port  | Protocol | Service                     | Notes                          |
|-------|----------|-----------------------------|-------------------------------|
| 22    | TCP      | SSH                         | Secure shell access            |
| 25    | TCP      | SMTP                        | Email sending                  |
| 53    | TCP/UDP  | DNS                         | Name resolution                |
| 80    | TCP      | HTTP                        | Unencrypted web                |
| 443   | TCP      | HTTPS                       | Encrypted web / payment APIs   |
| 3306  | TCP      | MySQL                       | Database                       |
| 5432  | TCP      | PostgreSQL                  | Database                       |
| 6379  | TCP      | Redis                       | Cache                          |
| 8080  | TCP      | HTTP Alt                    | App servers / proxies          |
| 27017 | TCP      | MongoDB                     | Database                       |
| 2375  | TCP      | Docker daemon (unsecured)   | Avoid exposing in production   |
| 2376  | TCP      | Docker daemon (TLS)         | Secured Docker API             |

---

### 5.3 DNS — Domain Name System

DNS translates human-readable names to IP addresses. Every service discovery, load balancer, and deployment you do depends on DNS.

```
Request Flow:

Browser → "What is google.com?"
       → Recursive Resolver (ISP or 8.8.8.8)
       → Root Name Server (.)
       → TLD Server (.com)
       → Authoritative Name Server (interswitch.com)
       → Returns: 41.58.20.10
```

**Common DNS Record Types:**

| Record | Purpose                                    | Example                              |
|--------|--------------------------------------------|--------------------------------------|
| A      | Hostname → IPv4                            | api.example.com → 192.168.1.5        |
| AAAA   | Hostname → IPv6                            | api.example.com → 2001:db8::1        |
| CNAME  | Alias → another hostname                   | www → api.example.com                |
| MX     | Mail server                                | mail.example.com                     |
| TXT    | Text (used for SPF, DKIM, verification)    | "v=spf1 include:..."                 |
| NS     | Name servers for domain                    | ns1.awsdns.com                       |
| PTR    | Reverse DNS (IP → hostname)                | 10.1.0.5 → db01.internal             |
| SOA    | Start of Authority (zone metadata)         | Serial, refresh, retry intervals     |

---

## 6. Routing Fundamentals

### 6.1 How Routing Works

Routing is the process of forwarding packets between networks. A **router** (or route table in AWS) examines the destination IP and decides where to send the packet.

```
Packet arrives → Check destination IP → Lookup route table → Forward to next hop
```

### 6.2 Route Tables

A route table is a list of rules:

```
Destination         Target / Next Hop
-----------         ----------------
10.0.0.0/16         local                ← Traffic within VPC
0.0.0.0/0           igw-0abc123          ← All other traffic → Internet Gateway
192.168.100.0/24    vpn-gateway-id       ← Internal network via VPN
10.10.0.0/16        pcx-0xyz456          ← Peered VPC
```

### 6.3 Longest Prefix Match Rule

When multiple routes match, the **most specific** (longest prefix) wins.

```
Packet destination: 10.0.1.5

  Matches 10.0.0.0/16  ✓
  Matches 10.0.1.0/24  ✓  ← This WINS (more specific)
  Matches 0.0.0.0/0    ✓
```

---

## 7. AWS VPC Deep Dive

### 7.1 VPC Structure

```
AWS Region
└── VPC (10.0.0.0/16)
    ├── Availability Zone A
    │   ├── Public Subnet  (10.0.1.0/24)  ← Has route to IGW
    │   └── Private Subnet (10.0.2.0/24)  ← Route via NAT Gateway
    ├── Availability Zone B
    │   ├── Public Subnet  (10.0.3.0/24)
    │   └── Private Subnet (10.0.4.0/24)
    └── Availability Zone C
        ├── Public Subnet  (10.0.5.0/24)
        └── Private Subnet (10.0.6.0/24)
```

### 7.2 Public vs Private Subnet

| Feature               | Public Subnet                  | Private Subnet                  |
|-----------------------|-------------------------------|----------------------------------|
| Route to Internet     | Via Internet Gateway (IGW)    | Via NAT Gateway (outbound only)  |
| Direct inbound access | Yes                           | No                               |
| Use cases             | Load Balancers, Bastion hosts | App servers, DBs, ECS tasks      |
| Has public IP?        | Can auto-assign public IP     | Private IPs only                 |

### 7.3 Key VPC Components

```
Internet Gateway (IGW)          → Enables two-way internet access for public subnets
NAT Gateway                     → Allows private subnet instances to reach internet (outbound only)
Security Groups                 → Stateful firewall at the instance/ENI level
Network ACLs (NACLs)            → Stateless firewall at the subnet level
VPC Peering                     → Connect two VPCs privately
Transit Gateway                 → Hub-and-spoke for connecting many VPCs
VPN Gateway                     → Connect on-premise to AWS over IPSec VPN
Direct Connect                  → Dedicated physical line between on-prem and AWS
Elastic IP (EIP)                → Static public IPv4 address
ENI (Elastic Network Interface) → Virtual NIC attached to EC2/ECS
```

### 7.4 Security Groups vs NACLs

| Feature         | Security Group              | Network ACL                      |
|-----------------|-----------------------------|----------------------------------|
| Level           | Instance / ENI              | Subnet                           |
| Statefulness    | Stateful                    | Stateless                        |
| Rules           | Allow only                  | Allow and Deny                   |
| Evaluation      | All rules evaluated         | Rules evaluated in number order  |
| Default         | Deny all inbound            | Allow all inbound/outbound       |

> **Stateful (SG):** If you allow inbound port 443, the return traffic is automatically allowed.
> **Stateless (NACL):** You must explicitly allow both inbound AND outbound for communication to work.

---

## 8. Load Balancing

### 8.1 Types of AWS Load Balancers

```
Application Load Balancer (ALB)
   → Layer 7 (HTTP/HTTPS)
   → Path-based routing  (/api → service A, /web → service B)
   → Host-based routing  (api.domain.com → service A)
   → Best for microservices, containers (ECS/EKS)

Network Load Balancer (NLB)
   → Layer 4 (TCP/UDP/TLS)
   → Extremely high performance, ultra-low latency
   → Static IP per AZ
   → Best for payment gateways, real-time systems

Gateway Load Balancer (GWLB)
   → Layer 3
   → For deploying 3rd party virtual appliances (firewalls, IDS)

Classic Load Balancer (CLB)
   → Legacy — avoid for new deployments
```

### 8.2 Health Check Configuration

```
Protocol:   HTTP
Path:       /health
Port:       traffic-port
Interval:   30 seconds
Timeout:    5 seconds
Healthy:    2 consecutive successes
Unhealthy:  3 consecutive failures
```

---

## 9. Network Troubleshooting (SRE Toolkit)

### 9.1 Layered Troubleshooting Checklist

```
Step 1: Physical / Link Layer
  → Is the instance running? Is the network interface up?
  → ip link show

Step 2: Network Layer
  → Can you ping the gateway?
  → ping 10.0.1.1
  → ip route show

Step 3: Transport Layer
  → Is the port open?
  → nc -zv <host> <port>
  → ss -tulnp | grep <port>

Step 4: Application Layer
  → Is the service responding?
  → curl -v http://localhost:8080/health
  → Check service logs

Step 5: DNS
  → Is the hostname resolving correctly?
  → dig <hostname>
  → nslookup <hostname>

Step 6: Firewall / Security Groups
  → Are Security Group rules correct (inbound + outbound)?
  → Are NACLs not blocking traffic?
  → Is VPC Flow Logs showing REJECT?
```

### 9.2 Core Diagnostic Commands

```bash
# Check your IP address
ip addr show
ifconfig

# Test connectivity (ICMP)
ping 8.8.8.8
ping -c 4 google.com

# Trace packet path across network
traceroute google.com
tracepath google.com

# DNS lookup
nslookup google.com
dig google.com
dig +short google.com
dig google.com MX

# Reverse DNS lookup
dig -x 192.168.1.10

# Check open ports on a host
nmap -p 80,443,22 10.0.1.5
nmap -sV 10.0.1.5

# Check if a port is open (quick test)
telnet 10.0.1.5 443
nc -zv 10.0.1.5 443

# View routing table
ip route show
route -n

# Check active connections and listening ports
ss -tulnp
netstat -tulnp

# Capture packets on an interface
tcpdump -i eth0 port 443
tcpdump -i eth0 host 10.0.1.5 -w capture.pcap

# curl with verbose output (debug HTTP/HTTPS)
curl -v https://v/health
curl -I https://google.com          # Headers only

# Check SSL certificate
openssl s_client -connect google.com:443
echo | openssl s_client -connect google.com:443 2>/dev/null | openssl x509 -noout -dates
```

---

## 10. Common Networking Patterns in DevOps

### 10.1 Three-Tier Architecture

```
Internet
    │
    ▼
[ALB - Public Subnet]          ← Layer 7 routing, SSL termination
    │
    ▼
[App Servers - Private Subnet] ← ECS/EC2, no public IP
    │
    ▼
[Database - Private Subnet]    ← RDS, ElastiCache, no internet access
```

### 10.2 Outbound Internet from Private Subnet

```
Private EC2 / ECS Task
    │
    ▼
Route Table: 0.0.0.0/0 → NAT Gateway (in Public Subnet)
    │
    ▼
NAT Gateway (has Elastic IP)
    │
    ▼
Internet Gateway
    │
    ▼
Internet
```

### 10.3 Multi-Account VPC Layout (Enterprise)

```
Transit Gateway
├── Production VPC    (10.0.0.0/16)
├── Staging VPC       (10.1.0.0/16)
├── Dev VPC           (10.2.0.0/16)
├── Shared Services   (10.3.0.0/16)   ← DNS, monitoring, logging
└── On-Premise Network (192.168.0.0/16) ← VPN or Direct Connect
```

>  **Never overlap CIDR blocks** between VPCs you plan to peer or connect via Transit Gateway. Plan your IP address space *before* you build. Overlapping CIDRs cannot be fixed without destroying and recreating resources.

---

## 11. CIDR Planning Quick Reference for AWS

```
Large Organization VPC:    10.0.0.0/8    → 16M IPs
Medium Organization VPC:   10.0.0.0/16   → 65,536 IPs   ← most common
Small Project VPC:         10.0.0.0/20   → 4,096 IPs
Microservice subnet:       10.0.1.0/24   → 251 usable IPs (after AWS reserves 5)
Small service subnet:      10.0.1.0/26   → 59 usable IPs
Lambda/ECS tasks subnet:   10.0.1.0/24   → allocate generously, tasks consume IPs

Rules of thumb:
  • Always go bigger than you think you need
  • Use /16 for VPCs
  • Use /24 for subnets (easy to reason about, 251 usable)
  • Reserve separate CIDR ranges for each Availability Zone
  • Leave room for VPC peering — plan the full range upfront
```

---

## 12. Summary: Networking Mental Model for DevOps

| Concept              | DevOps Relevance                                             |
|----------------------|--------------------------------------------------------------|
| IP Addressing        | Assign IPs to instances, containers, load balancers          |
| Subnetting / CIDR    | Design VPCs, isolate workloads, plan capacity                |
| Routing              | Control traffic flow between subnets, VPCs, internet         |
| DNS                  | Service discovery, load balancing, failover                  |
| TCP/UDP / Ports      | Configure security groups, debug connectivity                |
| Load Balancing       | High availability, traffic distribution, SSL offload         |
| SG / NACLs           | Secure perimeter and internal traffic                        |
| NAT Gateway          | Allow private workloads to pull images, call APIs            |
| VPN / Direct Connect | Hybrid cloud, on-prem integration                            |
| VPC Flow Logs        | Audit, debug, and monitor network traffic                    |

>  Practice subnetting until it becomes second nature. Your VPC designs, incident response speed, and infrastructure security all depend on deeply understanding these fundamentals. **When in doubt, draw the network.**

---

