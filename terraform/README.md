# Terraform Infrastructure for To-Do Application

This directory contains Terraform Infrastructure as Code (IaC) for deploying the To-Do application on AWS.

## 🏗️ Infrastructure Components

### Network Layer

- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Public Subnet**: 10.0.1.0/24 in one availability zone
- **Internet Gateway**: For internet connectivity
- **Route Table**: Routes internet traffic through IGW

### Compute Layer

- **EC2 Instance**: t3.micro (free tier eligible)
- **Elastic IP**: Static public IP for consistent access
- **AMI**: Ubuntu 22.04 LTS (latest)
- **Root Volume**: 20GB gp3 EBS volume (encrypted)

### Security Layer

- **Security Group**: Controls inbound/outbound traffic
  - Port 22: SSH access
  - Port 80: HTTP (Frontend)
  - Port 443: HTTPS (Future SSL)
  - Port 5000: Backend API
- **IAM Role**: EC2 instance role with CloudWatch and ECR permissions
- **IAM Instance Profile**: Attached to EC2

### Automation

- **User Data Script**: Installs Docker, Git, CloudWatch agent
- **Deployment Script**: Automated deployment helper
- **Health Check Script**: Monitors application health

## 💰 Cost Optimization

### Free Tier Eligible Resources

- EC2 t3.micro: 750 hours/month free (first 12 months)
- EBS: 30GB free
- Data Transfer: 15GB out free
- VPC, Subnet, IGW, Route Tables: Free
- Elastic IP (while attached): Free

### Estimated Monthly Cost (After Free Tier)

- EC2 t3.micro: ~$7.50/month (on-demand)
- EBS 20GB gp3: ~$1.60/month
- Data Transfer: Variable (minimal for this app)
- **Total**: ~$9-10/month

### Cost Reduction Tips

1. Use Spot Instances for non-production (~70% savings)
2. Stop instance during non-business hours
3. Use reserved instances for production (~50% savings)
4. Enable detailed monitoring only when needed

## 📋 Prerequisites

### 1. Install Required Tools

**Terraform:**

```bash
# macOS
brew install terraform

# Windows (Chocolatey)
choco install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**AWS CLI:**

```bash
# macOS
brew install awscli

# Windows
# Download from: https://aws.amazon.com/cli/

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

### 3. Generate SSH Key Pair

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/todo-app-key
# This creates:
# - Private key: ~/.ssh/todo-app-key
# - Public key: ~/.ssh/todo-app-key.pub
```

## 🚀 Deployment Steps

### Step 1: Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/CI-CD-Project.git
cd CI-CD-Project/terraform
```

### Step 2: Configure Variables

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Required variables:**

```hcl
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... your-email@example.com"
github_repo    = "https://github.com/YOUR_USERNAME/CI-CD-Project.git"
ssh_allowed_ips = ["YOUR_IP/32"]  # Get your IP: curl ifconfig.me
```

### Step 3: Initialize Terraform

```bash
terraform init
```

This downloads required providers and modules.

### Step 4: Plan Infrastructure

```bash
terraform plan
```

Review the planned changes. Should show:

- 12 resources to create
- 0 to change
- 0 to destroy

### Step 5: Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This takes ~5 minutes.

### Step 6: Get Outputs

```bash
terraform output
```

Save these important values:

- `ec2_public_ip`: Your EC2 public IP
- `application_url`: Frontend URL
- `ssh_command`: SSH connection command

## 🔧 Post-Deployment Configuration

### 1. SSH into EC2

```bash
# Use the SSH command from terraform output
ssh -i ~/.ssh/todo-app-key ubuntu@<EC2_PUBLIC_IP>
```

### 2. Verify Docker Installation

```bash
docker --version
docker compose version
```

### 3. Clone and Deploy Application

```bash
cd /home/ubuntu/app
git clone https://github.com/YOUR_USERNAME/CI-CD-Project.git .
docker compose up -d --build
```

### 4. Verify Deployment

```bash
# Check containers
docker compose ps

# Check logs
docker compose logs -f

# Test endpoints
curl http://localhost:5000/api/health
curl http://localhost
```

## 🔄 GitHub Actions Setup

### Step 1: Add GitHub Secrets

Go to your GitHub repo → Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name             | Value                   | How to Get                         |
| ----------------------- | ----------------------- | ---------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Your AWS access key     | AWS IAM Console                    |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key     | AWS IAM Console                    |
| `EC2_HOST`              | EC2 public IP           | `terraform output ec2_public_ip`   |
| `EC2_SSH_PRIVATE_KEY`   | SSH private key content | `cat ~/.ssh/todo-app-key`          |
| `GITHUB_REPO`           | Your repo URL           | `https://github.com/USER/REPO.git` |

### Step 2: Test GitHub Actions

```bash
# Make a change and push
echo "# Test" >> README.md
git add .
git commit -m "Test deployment"
git push origin main
```

Watch the deployment in: GitHub → Actions tab

### Step 3: Verify Auto-Deployment

After push, check:

1. GitHub Actions workflow completes successfully
2. Application is updated on EC2
3. Services are running: `docker compose ps`

## 📊 Monitoring & Management

### View Terraform State

```bash
terraform show
terraform state list
```

### Update Infrastructure

```bash
# Modify variables in terraform.tfvars
nano terraform.tfvars

# Apply changes
terraform plan
terraform apply
```

### Check EC2 Instance

```bash
# Get instance details
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=todo-app-app-server" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table
```

### View Logs

```bash
# SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@<EC2_IP>

# View user-data logs
sudo cat /var/log/cloud-init-output.log

# View Docker logs
cd /home/ubuntu/app
docker compose logs -f
```

## 🛠️ Troubleshooting

### Issue: SSH Connection Refused

**Solution:**

```bash
# Check security group allows your IP
terraform output security_group_id

# Verify your IP
curl ifconfig.me

# Update terraform.tfvars
ssh_allowed_ips = ["YOUR_CURRENT_IP/32"]
terraform apply
```

### Issue: Application Not Accessible

**Check:**

1. EC2 is running: `aws ec2 describe-instances`
2. Security group allows port 80: Check AWS Console
3. Docker containers running: SSH and run `docker compose ps`
4. Application logs: `docker compose logs`

### Issue: Docker Not Installed

**Solution:**

```bash
# SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@<EC2_IP>

# Check user-data status
sudo cat /var/log/cloud-init-output.log

# Manually run user-data script
sudo bash /var/lib/cloud/instance/scripts/part-001
```

### Issue: Out of Memory

**Solution:**

```bash
# Upgrade instance type
# In terraform.tfvars:
instance_type = "t3.small"

terraform apply
```

## 🗑️ Cleanup

### Destroy All Resources

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy

# Type 'yes' to confirm
```

**Warning**: This will delete:

- EC2 instance
- Elastic IP
- Security groups
- VPC and subnets
- All associated resources

### Cost of Leaving Resources Running

If you forget to destroy:

- t3.micro: ~$0.01/hour = $7.50/month
- EBS: ~$0.08/GB/month
- Elastic IP (detached): $0.005/hour

**Best Practice**: Destroy when not in use, especially for learning/testing.

## 📚 Terraform Commands Reference

```bash
# Initialize
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Output values
terraform output

# Destroy infrastructure
terraform destroy

# Refresh state
terraform refresh

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0
```

## 🔐 Security Best Practices

1. **SSH Access**: Restrict to your IP only
2. **Secrets**: Never commit `terraform.tfvars` to Git
3. **IAM**: Use least privilege principle
4. **Encryption**: Enable EBS encryption (already done)
5. **Updates**: Keep AMI and packages updated
6. **Backups**: Regular backups of application data
7. **Monitoring**: Enable CloudWatch for alerts
8. **SSL/TLS**: Add HTTPS with Let's Encrypt (future enhancement)

## 📈 Scaling Considerations

### Horizontal Scaling (Future)

- Add Application Load Balancer
- Multiple EC2 instances across AZs
- Auto Scaling Group
- Managed MongoDB (DocumentDB/Atlas)

### Vertical Scaling (Immediate)

- Change `instance_type` to t3.small or t3.medium
- Add more EBS storage
- Increase Docker resource limits

## 📝 Additional Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Free Tier Details](https://aws.amazon.com/free/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

**Need Help?** Check the troubleshooting section or open an issue on GitHub!
