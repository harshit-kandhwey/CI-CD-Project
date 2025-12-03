# 🚀 Complete AWS Setup Guide

Step-by-step guide to deploy the To-Do application on AWS using Terraform and GitHub Actions.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [AWS Account Setup](#aws-account-setup)
3. [Generate SSH Keys](#generate-ssh-keys)
4. [Configure Terraform](#configure-terraform)
5. [Deploy Infrastructure](#deploy-infrastructure)
6. [Setup GitHub Actions](#setup-github-actions)
7. [Verify Deployment](#verify-deployment)
8. [Cost Management](#cost-management)

---

## 1. Prerequisites

### Required Tools

Install these before starting:

**Windows:**

```powershell
# Install Chocolatey first (if not installed)
# Then install tools:
choco install terraform awscli git

# Or download manually:
# Terraform: https://www.terraform.io/downloads
# AWS CLI: https://aws.amazon.com/cli/
```

**macOS:**

```bash
brew install terraform awscli git
```

**Linux:**

```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Verify Installation

```bash
terraform --version  # Should show v1.6.0 or higher
aws --version        # Should show aws-cli/2.x.x
git --version        # Should show git version 2.x.x
```

---

## 2. AWS Account Setup

### Step 2.1: Create AWS Account

1. Go to https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Follow the registration process
4. Add payment method (required, but free tier available)
5. Verify phone number
6. Choose "Basic Support (Free)"

### Step 2.2: Create IAM User

**Why?** Never use root account credentials.

1. **Login to AWS Console**

   - Go to https://console.aws.amazon.com/

2. **Navigate to IAM**

   - Search for "IAM" in the services search
   - Click "Identity and Access Management"

3. **Create New User**

   - Click "Users" → "Create user"
   - Username: `terraform-deploy-user`
   - Select: ✅ Provide user access to the AWS Management Console (optional)
   - Click "Next"

4. **Set Permissions**

   - Select "Attach policies directly"
   - Add these policies:
     - ✅ `AmazonEC2FullAccess`
     - ✅ `AmazonVPCFullAccess`
     - ✅ `IAMFullAccess`
   - Click "Next" → "Create user"

5. **Create Access Keys**
   - Click on the newly created user
   - Go to "Security credentials" tab
   - Click "Create access key"
   - Select "Command Line Interface (CLI)"
   - Check "I understand" → Click "Next"
   - Click "Create access key"
   - **IMPORTANT**: Save these credentials:
     - Access Key ID
     - Secret Access Key
   - Click "Download .csv file" (backup)

### Step 2.3: Configure AWS CLI

```bash
aws configure

# Enter when prompted:
AWS Access Key ID: <YOUR_ACCESS_KEY_ID>
AWS Secret Access Key: <YOUR_SECRET_ACCESS_KEY>
Default region name: us-east-1
Default output format: json
```

### Step 2.4: Verify AWS Access

```bash
# Test AWS credentials
aws sts get-caller-identity

# Should return:
# {
#     "UserId": "AIDXXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/terraform-deploy-user"
# }
```

---

## 3. Generate SSH Keys

### Step 3.1: Generate Key Pair

**Windows (PowerShell):**

```powershell
# Create .ssh directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $HOME\.ssh

# Generate SSH key
ssh-keygen -t rsa -b 4096 -f $HOME\.ssh\todo-app-key

# When prompted:
# - Enter passphrase: (press Enter for no passphrase, or set one)
# - Confirm passphrase: (press Enter or repeat passphrase)
```

**Linux/macOS:**

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/todo-app-key

# Press Enter for default location
# Press Enter twice for no passphrase (or set one)
```

### Step 3.2: View Public Key

**Windows:**

```powershell
Get-Content $HOME\.ssh\todo-app-key.pub
```

**Linux/macOS:**

```bash
cat ~/.ssh/todo-app-key.pub
```

Copy the entire output (starts with `ssh-rsa`). You'll need this for Terraform configuration.

---

## 4. Configure Terraform

### Step 4.1: Project Structure

Ensure your project has this structure:

```
CI-CD-Project/
├── frontend/
├── backend/
├── database/
├── terraform/          ← Create this directory
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user-data.sh
│   └── terraform.tfvars
├── .github/
│   └── workflows/
│       └── deploy.yml
└── docker-compose.yml
```

### Step 4.2: Create Terraform Directory

```bash
cd CI-CD-Project
mkdir terraform
cd terraform
```

### Step 4.3: Create Terraform Files

Copy all Terraform artifacts to the `terraform/` directory:

- `main.tf`
- `variables.tf`
- `outputs.tf`
- `user-data.sh`

### Step 4.4: Configure Variables

Create `terraform.tfvars`:

```bash
# Windows
notepad terraform.tfvars

# Linux/macOS
nano terraform.tfvars
```

Add this content (replace with your values):

```hcl
aws_region   = "us-east-1"
environment  = "production"
project_name = "todo-app"

vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

instance_type = "t3.micro"

# Get your IP: curl ifconfig.me
# IMPORTANT: Replace 0.0.0.0/0 with YOUR_IP/32 for security
ssh_allowed_ips = ["0.0.0.0/0"]

# Paste your SSH public key here (from step 3.2)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD... your-email@example.com"

# Your GitHub repository
github_repo = "https://github.com/harshit-kandhwey/CI-CD-Project.git"
```

**Security Note**: Change `ssh_allowed_ips` to your actual IP:

```bash
# Get your IP
curl ifconfig.me

# Then in terraform.tfvars:
ssh_allowed_ips = ["YOUR_IP/32"]
```

---

## 5. Deploy Infrastructure

### Step 5.1: Initialize Terraform

```bash
cd terraform
terraform init
```

Expected output:

```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized!
```

### Step 5.2: Validate Configuration

```bash
terraform validate
```

Should return: `Success! The configuration is valid.`

### Step 5.3: Plan Infrastructure

```bash
terraform plan
```

Review the output. Should show approximately:

```
Plan: 12 to add, 0 to change, 0 to destroy.
```

Resources to be created:

- VPC
- Internet Gateway
- Subnet
- Route Table
- Security Group
- IAM Role & Policy
- EC2 Instance
- Elastic IP
- And more...

### Step 5.4: Apply Infrastructure

```bash
terraform apply
```

1. Review the plan again
2. Type `yes` when prompted
3. Wait 3-5 minutes for completion

Expected output:

```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:
application_url = "http://54.123.45.67"
backend_api_url = "http://54.123.45.67:5000/api"
ec2_public_ip = "54.123.45.67"
ssh_command = "ssh -i ~/.ssh/todo-app-key ubuntu@54.123.45.67"
...
```

### Step 5.5: Save Important Outputs

```bash
# Save to file
terraform output > ../terraform-outputs.txt

# Or view specific output
terraform output ec2_public_ip
terraform output application_url
```

---

## 6. Setup GitHub Actions

### Step 6.1: Create GitHub Secrets

1. **Go to GitHub Repository**

   - Navigate to your repository on GitHub
   - Click "Settings" → "Secrets and variables" → "Actions"

2. **Add Repository Secrets**

Click "New repository secret" and add each of these:

| Secret Name             | Value                   | Where to Get                       |
| ----------------------- | ----------------------- | ---------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Your AWS access key ID  | From Step 2.2                      |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key     | From Step 2.2                      |
| `EC2_HOST`              | EC2 public IP address   | `terraform output ec2_public_ip`   |
| `EC2_SSH_PRIVATE_KEY`   | SSH private key content | See below                          |
| `GITHUB_REPO`           | Your repo URL           | `https://github.com/USER/REPO.git` |

**Get SSH Private Key:**

**Windows:**

```powershell
Get-Content $HOME\.ssh\todo-app-key
```

**Linux/macOS:**

```bash
cat ~/.ssh/todo-app-key
```

Copy the **entire content** including:

```
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

### Step 6.2: Create GitHub Actions Workflow

Create `.github/workflows/deploy.yml` in your repository root (copy from artifact).

### Step 6.3: Initial Manual Deployment

Before GitHub Actions can work, deploy the app manually once:

```bash
# SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@<EC2_PUBLIC_IP>

# Wait for user-data to complete (check every 30 seconds)
tail -f /var/log/cloud-init-output.log
# Press Ctrl+C when you see "Cloud-init finished"

# Verify Docker is installed
docker --version
docker compose version

# Create app directory and clone repo
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app
git clone https://github.com/YOUR_USERNAME/CI-CD-Project.git .

# Deploy application
docker compose up -d --build

# Wait and check status
sleep 30
docker compose ps

# Test locally
curl http://localhost:5000/api/health
curl http://localhost

# Exit SSH
exit
```

### Step 6.4: Test GitHub Actions

```bash
# Make a small change
echo "# Test Deployment" >> README.md

# Commit and push
git add .
git commit -m "Test GitHub Actions deployment"
git push origin main
```

Watch the deployment:

1. Go to GitHub → Your Repository
2. Click "Actions" tab
3. Watch the workflow run
4. Should complete in 2-3 minutes

---

## 7. Verify Deployment

### Step 7.1: Check Application

Open in browser:

```
http://<EC2_PUBLIC_IP>
```

You should see the To-Do application!

### Step 7.2: Test Backend API

```bash
# Health check
curl http://<EC2_PUBLIC_IP>:5000/api/health

# Get todos
curl http://<EC2_PUBLIC_IP>:5000/api/todos

# Create a todo
curl -X POST http://<EC2_PUBLIC_IP>:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"text":"Test from API"}'
```

### Step 7.3: Check Docker Containers

```bash
# SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@<EC2_PUBLIC_IP>

# Check containers
docker compose ps

# Should show:
# todo-frontend   Up   0.0.0.0:80->80/tcp
# todo-backend    Up   0.0.0.0:5000->5000/tcp
# todo-database   Up   0.0.0.0:27017->27017/tcp

# Check logs
docker compose logs -f
```

---

## 8. Cost Management

### Free Tier Coverage

Your setup is mostly covered by AWS Free Tier (12 months):

- ✅ EC2 t3.micro: 750 hours/month free
- ✅ EBS 30GB: 30GB free
- ✅ Data Transfer: 15GB out free
- ✅ VPC: Free

### Monthly Cost After Free Tier

| Resource            | Cost                   |
| ------------------- | ---------------------- |
| EC2 t3.micro (24/7) | $7.50                  |
| EBS 20GB gp3        | $1.60                  |
| Elastic IP          | $0.00 (while attached) |
| Data Transfer       | ~$1.00 (varies)        |
| **Total**           | **~$10/month**         |

### Cost Saving Tips

1. **Stop When Not in Use**

```bash
# Stop instance (data preserved)
aws ec2 stop-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Start instance
aws ec2 start-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Note: Elastic IP charges apply when instance is stopped ($0.005/hour)
```

2. **Use Spot Instances** (for non-production)

   - 60-70% cost savings
   - May be interrupted

3. **Set Billing Alerts**

```bash
# AWS Console → Billing → Budgets
# Create budget: $10/month
# Add email alert at 80% threshold
```

4. **Destroy When Done Testing**

```bash
cd terraform
terraform destroy
# Type 'yes' to confirm
```

---

## 🎉 Success Checklist

- [ ] AWS account created and configured
- [ ] IAM user created with access keys
- [ ] AWS CLI configured
- [ ] SSH keys generated
- [ ] Terraform initialized
- [ ] Infrastructure deployed (terraform apply)
- [ ] EC2 instance running
- [ ] Docker installed on EC2
- [ ] Application deployed and accessible
- [ ] GitHub secrets configured
- [ ] GitHub Actions workflow successful
- [ ] Application accessible via public IP
- [ ] Backend API responding
- [ ] Can create and manage todos

---

## 🐛 Troubleshooting

### Issue: Terraform Apply Fails

**Error:** "Error creating EC2 instance"

**Solution:**

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check IAM permissions
aws iam list-attached-user-policies --user-name terraform-deploy-user

# Try with verbose logging
TF_LOG=DEBUG terraform apply
```

### Issue: Cannot SSH to EC2

**Error:** "Connection refused" or "Connection timed out"

**Solution:**

```bash
# 1. Check instance is running
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id)

# 2. Check security group allows your IP
curl ifconfig.me

# 3. Update terraform.tfvars with your IP
ssh_allowed_ips = ["YOUR_IP/32"]
terraform apply

# 4. Check SSH key permissions
chmod 600 ~/.ssh/todo-app-key
```

### Issue: Application Not Accessible

**Check:**

```bash
# 1. SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@<EC2_IP>

# 2. Check if user-data completed
sudo cat /var/log/cloud-init-output.log | grep -i "cloud-init finished"

# 3. Check Docker containers
docker compose ps

# 4. Check application logs
docker compose logs

# 5. Test locally on EC2
curl http://localhost
curl http://localhost:5000/api/health
```

### Issue: GitHub Actions Failing

**Check:**

1. All secrets are set correctly in GitHub
2. SSH private key includes BEGIN and END lines
3. EC2_HOST is just the IP (no http://)
4. Application is accessible via browser first

---

## 📚 Next Steps

1. **Add HTTPS with SSL Certificate**

   - Use Let's Encrypt
   - Configure Nginx for SSL

2. **Set Up Monitoring**

   - CloudWatch dashboards
   - Application logs to CloudWatch

3. **Implement Backups**

   - EBS snapshots
   - MongoDB backups

4. **Add CI/CD Stages**

   - Testing stage
   - Staging environment
   - Production deployment

5. **Scale the Application**
   - Add Load Balancer
   - Multiple EC2 instances
   - Auto Scaling Group

---

**Congratulations! 🎊** You've successfully deployed a 3-tier application on AWS with automated CI/CD using GitHub Actions!
