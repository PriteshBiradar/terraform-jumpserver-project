# 🚀 AWS Jump Server with Terraform

This project demonstrates how to provision and configure an **AWS Jump Server (Bastion Host)** using **Terraform**.

The Jump Server provides a controlled entry point into a private network. Instead of exposing private EC2 instances directly to the internet, administrators connect to the Jump Server first and then access private resources through it.

---

## 📌 Project Overview

The infrastructure is created using **Terraform** and AWS.

### Architecture

```text
                         Internet
                            │
                            │ SSH
                            ▼
                  ┌─────────────────────┐
                  │    Jump Server      │
                  │   Windows Server    │
                  │                     │
                  │  Public Subnet      │
                  │  Public IP          │
                  └──────────┬──────────┘
                             │
                       SSH / RDP / Tunnel
                             │
                             ▼
                  ┌─────────────────────┐
                  │   Private Server    │
                  │     EC2 / Linux     │
                  │                     │
                  │   Private Subnet    │
                  │   No Public IP      │
                  └─────────────────────┘
```

The important idea is:

> **Internet → Jump Server → Private Server**

The private server does not need to be directly accessible from the internet.

---

# 🎯 Why Do We Need a Jump Server?

Normally, if an EC2 instance is placed in a private subnet, it does not have a public IP address.

Therefore, an administrator cannot directly connect to it from the internet.

Instead of giving the private server a public IP, we use a Jump Server.

### Without Jump Server

```text
Internet
   │
   ├──────────────► Private Server
   │                  ❌ No direct access
```

### With Jump Server

```text
Internet
   │
   ▼
Jump Server
   │
   ▼
Private Server
   ✅ Secure administrative access
```

This reduces the number of resources exposed to the public internet.

---

# 🏗️ Infrastructure

The Terraform configuration creates infrastructure similar to:

- AWS VPC
- Public subnet
- Private subnet
- Internet Gateway
- Route tables
- Security groups
- Windows Jump Server
- Private Linux EC2 instance
- Network connectivity between the resources

---

# 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| EC2 | Compute instances |
| VPC | Network isolation |
| Security Groups | Network access control |
| Internet Gateway | Internet connectivity |
| Windows Server | Jump Server |
| OpenSSH | SSH connectivity |
| SSH Port Forwarding | Access private services |

---

# 📁 Project Structure

```text
jump-server-terraform/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── provider.tf
├── outputs.tf
├── .gitignore
└── README.md
```

---

# ⚙️ Prerequisites

Before running the project, install:

- Terraform
- AWS CLI
- Git

You also need an AWS account with appropriate permissions.

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

---

# 🔐 AWS Authentication

Terraform needs permission to create AWS resources.

For local development, configure the AWS CLI:

```bash
aws configure
```

Provide:

```text
AWS Access Key ID
AWS Secret Access Key
Default region
Output format
```

For production environments, avoid storing credentials directly inside Terraform files.

---

# 🚀 Terraform Deployment

## 1. Clone the Repository

```bash
git clone <repository-url>
cd jump-server-terraform
```

---

## 2. Initialize Terraform

```bash
terraform init
```

This downloads the required Terraform providers and initializes the working directory.

---

## 3. Format the Configuration

```bash
terraform fmt
```

---

## 4. Validate the Configuration

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

## 5. Review the Infrastructure

```bash
terraform plan
```

Always review the plan before applying infrastructure changes.

---

## 6. Create the Infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

Terraform will provision the AWS resources.

---

# 🖥️ Windows Jump Server

The Jump Server in this project is a **Windows Server EC2 instance**.

The Windows server is placed in the public subnet so that an administrator can connect to it from the internet.

Once connected to the Windows server, it can be used as the entry point to reach private resources.

---

# 🔑 Connecting to the Windows Jump Server

The Jump Server can be accessed using RDP or SSH depending on the configuration.

For SSH access, OpenSSH needs to be installed and configured on the Windows Server.

After configuring OpenSSH, the SSH service can be started using PowerShell:

```powershell
Start-Service sshd
```

To verify the service:

```powershell
Get-Service sshd
```

The expected state is:

```text
Status   Name
------   ----
Running  sshd
```

---

# 🔐 SSH Authentication

The SSH connection follows this general flow:

```text
Local Machine
     │
     │ SSH
     ▼
Windows Jump Server
     │
     │ SSH
     ▼
Private Linux Server
```

The administrator authenticates to the Jump Server first.

From there, the private server can be accessed through the internal network.

---

# 🔄 SSH Port Forwarding

One of the useful capabilities of the Jump Server is **SSH tunneling / port forwarding**.

For example, suppose the private Linux server has an application running on:

```text
10.0.2.5:80
```

and the Jump Server has a public IP:

```text
98.70.58.48
```

We can create an SSH tunnel:

```bash
ssh -L 8080:10.0.2.5:80 -i jump-server.pem azureuser@98.70.58.48
```

The command means:

```text
Local Machine
     │
     │ localhost:8080
     ▼
SSH Tunnel
     │
     ▼
Jump Server
     │
     │ 10.0.2.5:80
     ▼
Private Server
```

After establishing the tunnel, opening:

```text
http://localhost:8080
```

can access the web service running on the private server.

---

# 🧠 Understanding the SSH `-L` Option

The syntax is:

```bash
ssh -L LOCAL_PORT:PRIVATE_IP:PRIVATE_PORT USER@JUMP_SERVER
```

For example:

```bash
ssh -L 8080:10.0.2.5:80 -i jump-server.pem azureuser@98.70.58.48
```

Breakdown:

| Component | Meaning |
|---|---|
| `-L` | Local port forwarding |
| `8080` | Port on your local machine |
| `10.0.2.5` | Private server IP |
| `80` | Private server web port |
| `jump-server.pem` | SSH private key |
| `azureuser` | SSH username |
| `98.70.58.48` | Jump Server public IP |

---

# 🔒 Security Group Design

The Jump Server should **not** allow unrestricted access wherever possible.

A better security model is:

```text
Internet
   │
   │ SSH 22
   │ Only trusted IPs
   ▼
Jump Server
   │
   │ SSH 22
   │ Private network
   ▼
Private Server
```

For example:

### Jump Server Security Group

Inbound:

```text
SSH
TCP
22
YOUR_PUBLIC_IP/32
```

Avoid:

```text
0.0.0.0/0
```

for SSH in production.

### Private Server Security Group

Inbound SSH should allow traffic from the Jump Server's security group rather than the entire internet.

Conceptually:

```text
Source:
JumpServerSecurityGroup

Protocol:
TCP

Port:
22
```

This creates a much stronger security boundary.

---

# 🌐 Network Flow

The network is designed around public and private subnets.

```text
                    Internet
                       │
                       ▼
                Internet Gateway
                       │
                       ▼
                Public Subnet
                       │
                       ▼
                Windows Jump Server
                       │
                       ▼
                Private Subnet
                       │
                       ▼
                Private EC2 Server
```

The public subnet has a route to the Internet Gateway.

The private subnet does not expose the private EC2 instance directly to the internet.

---

# 🧩 Problems We Encountered

During the implementation, several real-world issues were encountered.

## 1. Windows OpenSSH Configuration

OpenSSH was installed on the Windows Server, but SSH connectivity required additional configuration.

We had to:

- Install OpenSSH Server
- Configure the SSH service
- Start the `sshd` service
- Verify the service
- Check firewall rules
- Verify port 22 connectivity

This demonstrated an important point:

> Installing OpenSSH and successfully configuring SSH access are two different steps.

---

## 2. `localhost` Connection Problem

We initially encountered:

```text
This site can't be reached

localhost refused to connect
```

This occurred because accessing `localhost` only works when a service is actually listening on that port on the machine where the browser is running.

For a private server, we needed either:

- Network connectivity to the private server, or
- SSH port forwarding

---

## 3. Understanding SSH Tunneling

Initially, it was not obvious why the SSH command used:

```bash
-L 8080:10.0.2.5:80
```

The important concept is that the local port:

```text
localhost:8080
```

is forwarded through the Jump Server to:

```text
10.0.2.5:80
```

This allows access to a private service without exposing that service publicly.

---

## 4. Terraform Configuration Errors

During Terraform development, several configuration errors were encountered.

Examples included:

### Invalid CIDR syntax

Incorrect:

```hcl
cidr_block = 0.0.0.0/0
```

Correct:

```hcl
cidr_block = "0.0.0.0/0"
```

---

### Incorrect Terraform block name

Incorrect:

```hcl
required_provider
```

Correct:

```hcl
required_providers
```

---

### Invalid Gateway Configuration

A route cannot use multiple gateway types simultaneously.

For example, a route should not specify both:

```hcl
gateway_id = ...
```

and:

```hcl
vpc_peering_connection_id = ...
```

The correct target depends on what the route is supposed to reach.

---

### Invalid AWS Resource IDs

Terraform requires actual AWS resource IDs.

Incorrect examples:

```text
vpc_a
vpc-b
```

These are names, not valid AWS VPC IDs.

AWS resource IDs look like:

```text
vpc-0123456789abcdef
```

Terraform references should normally use resource attributes such as:

```hcl
vpc_id = aws_vpc.main.id
```

rather than manually typing IDs.

---

# 🧱 Infrastructure as Code Benefits

Using Terraform instead of manually creating the Jump Server provides several advantages.

### Reproducibility

The same infrastructure can be recreated whenever required.

### Version Control

Terraform configuration can be stored in Git.

### Automation

Infrastructure can be deployed without manually creating every AWS resource.

### Consistency

Terraform reduces configuration differences between environments.

### Collaboration

Multiple developers can review infrastructure changes through Git branches and pull requests.

---

# 🔀 Git Workflow

A recommended workflow for this project is:

```text
main
 │
 ├── feature/jump-server
 │
 │   └── Terraform development
 │
 ▼
Pull Request
 │
 ▼
Code Review
 │
 ▼
Merge
 │
 ▼
main
```

Example:

```bash
git checkout -b feature/jump-server
```

After making changes:

```bash
git add .
git commit -m "Add Terraform jump server infrastructure"
git push origin feature/jump-server
```

Then create a Pull Request and merge it into `main`.

---

# 🧹 Destroying the Infrastructure

When the infrastructure is no longer required:

```bash
terraform destroy
```

Review the resources Terraform plans to remove and confirm with:

```text
yes
```

⚠️ **Warning:** `terraform destroy` can permanently delete AWS resources.

Use it carefully, especially if resources contain important data.

---

# 🔐 Security Best Practices

For a production Jump Server:

- Restrict SSH access to trusted IP addresses.
- Do not expose private EC2 instances directly to the internet.
- Avoid `0.0.0.0/0` for administrative ports.
- Use security-group-to-security-group rules where possible.
- Keep the Windows Server patched.
- Keep OpenSSH updated.
- Use key-based authentication.
- Disable password authentication when appropriate.
- Monitor authentication logs.
- Consider AWS Systems Manager Session Manager to reduce the need for publicly accessible SSH.
- Never commit private keys such as `.pem` files to Git.

Add private keys to `.gitignore`:

```gitignore
*.pem
*.key
```

---

# 🚀 Future Improvements

This project can be extended with:

- AWS Systems Manager Session Manager
- IAM roles
- CloudWatch monitoring
- CloudTrail auditing
- Auto Scaling
- Terraform modules
- Remote Terraform state using S3
- DynamoDB state locking
- CI/CD with GitHub Actions
- Private EC2 instances
- NAT Gateway
- VPC Peering
- AWS Network Firewall
- Bastion host hardening

---

# ⭐ Recommended Architecture

For a production environment, a more secure design would be:

```text
                         Internet
                            │
                            ▼
                     AWS Management
                            │
                            ▼
                  Systems Manager (SSM)
                            │
                            ▼
                    Private EC2 Server
```

With **AWS Systems Manager Session Manager**, administrators can access private EC2 instances without exposing SSH/RDP directly to the internet.

The Jump Server approach is still valuable for learning and for environments where a bastion host is specifically required.

---

# 📚 What We Learned

Through this project, we learned:

- AWS VPC networking
- Public vs private subnets
- Internet Gateway
- Route tables
- Security Groups
- Windows Server administration
- OpenSSH on Windows
- SSH authentication
- SSH tunneling
- Local port forwarding
- Terraform variables
- Terraform resources
- Terraform `for_each`
- Terraform validation
- Terraform troubleshooting
- Git branching
- Pull Requests
- Secure infrastructure design

---

# 👨‍💻 Project Goal

The main goal of this project is to understand how a **Jump Server / Bastion Host** can provide controlled access to resources inside a private AWS network and how the entire infrastructure can be managed using **Terraform Infrastructure as Code**.

```text
Terraform
    │
    ▼
AWS VPC
    │
    ├── Public Subnet
    │       │
    │       └── Windows Jump Server
    │
    └── Private Subnet
            │
            └── Private EC2
                    │
                    └── Application
```

---

## 📌 Key Takeaway

> **A Jump Server acts as a controlled gateway between an administrator and private infrastructure. Terraform allows us to create and manage that infrastructure consistently and repeatably as code.**