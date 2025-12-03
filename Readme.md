# 📝 3-Tier To-Do Application with AWS Deployment

A professional, full-stack To-Do application built with a microservices architecture using Docker containers, complete with Infrastructure as Code (IaC) using Terraform and automated CI/CD pipeline via GitHub Actions for AWS deployment.

![Architecture](https://img.shields.io/badge/Architecture-3--Tier-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)
![Node.js](https://img.shields.io/badge/Node.js-18-339933?logo=node.js)
![MongoDB](https://img.shields.io/badge/MongoDB-7.0-47A248?logo=mongodb)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?logo=github-actions)

## 🏗️ Complete Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      DEVELOPER WORKFLOW                         │
│                                                                 │
│  Developer → Git Push → GitHub → GitHub Actions → AWS EC2       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         AWS CLOUD (VPC)                         │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐     │
│  │              EC2 Instance (Ubuntu 22.04)               │     │
│  │                                                        │     │
│  │  ┌──────────────────────────────────────────────────┐  │     │
│  │  │           Docker Compose Environment             │  │     │
│  │  │                                                  │  │     │
│  │  │  ┌────────────┐  ┌────────────┐  ┌───────────┐   │  │     │
│  │  │  │  Frontend  │  │  Backend   │  │ Database  │   │  │     │
│  │  │  │   Nginx    │→ │  Node.js   │→ │  MongoDB  │   │  │     │
│  │  │  │  Port 80   │  │  Port 5000 │  │Port 27017 │   │  │     │
│  │  │  └────────────┘  └────────────┘  └───────────┘   │  │     │
│  │  └──────────────────────────────────────────────────┘  │     │
│  └────────────────────────────────────────────────────────┘     │
│                              ↕                                  │
│  ┌────────────────────────────────────────────────────────┐     │
│  │           Security Group (Firewall Rules)              │     │
│  │  • Port 22 (SSH)  • Port 80 (HTTP)  • Port 5000 (API)  │     │
│  └────────────────────────────────────────────────────────┘     │
│                              ↕                                  │
│  ┌────────────────────────────────────────────────────────┐     │
│  │              Internet Gateway (IGW)                    │     │
│  └────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                         PUBLIC INTERNET                         │
│                      Users Access Application                   │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Complete Project Structure

```
CI-CD-Project/
├── frontend/                    # Tier 1: Presentation Layer
│   ├── .dockerignore
│   ├── Dockerfile              # Multi-stage: Build + Nginx
│   ├── package.json
│   ├── vite.config.js
│   ├── nginx.conf              # Reverse proxy configuration
│   ├── index.html
│   ├── main.jsx
│   ├── App.jsx
│   ├── styles.css
│   └── README.md
│
├── backend/                     # Tier 2: Business Logic Layer
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js               # Express REST API
│   ├── .env                    # Environment variables
│   └── README.md
│
├── database/                    # Tier 3: Data Layer
│   ├── init-db.js              # MongoDB initialization
│   ├── backup.sh               # Backup script
│   ├── restore.sh              # Restore script
│   ├── mongod.conf             # MongoDB configuration
│   └── README.md
│
├── terraform/                   # Infrastructure as Code (NEW!)
│   ├── .gitignore
│   ├── main.tf                 # VPC, EC2, Security Groups, IAM
│   ├── variables.tf            # Configurable parameters
│   ├── outputs.tf              # Infrastructure outputs
│   ├── user-data.sh            # EC2 bootstrap script
│   ├── terraform.tfvars.example
│   └── README.md
│
├── .github/                     # CI/CD Pipeline (NEW!)
│   └── workflows/
│       └── deploy.yml          # Automated deployment workflow
│
├── docker-compose.yml           # Local development orchestration
├── README.md                    # This file
├── AWS-SETUP-GUIDE.md          # Complete AWS deployment guide
├── SETUP-CHECKLIST.md          # Local setup verification
├── PROJECT-SUMMARY.md          # Architecture documentation
├── verify-structure.sh         # Linux/Mac file verification
└── verify-structure.ps1        # Windows file verification
```

## ✨ Key Features

### 🎨 Frontend (React + Nginx)

- ✅ Modern, responsive UI with gradient design
- ✅ Real-time task statistics dashboard
- ✅ Filter tasks by All/Active/Completed
- ✅ Smooth animations and transitions
- ✅ Production-optimized build with Vite
- ✅ Nginx reverse proxy for API routing

### 🚀 Backend (Node.js + Express)

- ✅ RESTful API with full CRUD operations
- ✅ MongoDB integration with Mongoose ODM
- ✅ Input validation and error handling
- ✅ CORS enabled for cross-origin requests
- ✅ Health check endpoint for monitoring
- ✅ Environment-based configuration

### 💾 Database (MongoDB)

- ✅ Persistent data storage with Docker volumes
- ✅ Automatic initialization with sample data
- ✅ Performance indexes for optimization
- ✅ Backup and restore scripts included
- ✅ Data survives container restarts

### ☁️ AWS Infrastructure (Terraform)

- ✅ Complete VPC with public subnet
- ✅ EC2 instance (t3.micro - free tier eligible)
- ✅ Security Groups with minimal access
- ✅ Elastic IP for static public access
- ✅ IAM roles and policies
- ✅ Automated Docker and Git installation
- ✅ Cost-optimized (~$0-10/month)

### 🔄 CI/CD Pipeline (GitHub Actions)

- ✅ Automated deployment on git push
- ✅ Zero-downtime updates
- ✅ Automatic rollback on failure
- ✅ Health checks after deployment
- ✅ SSH-based secure deployment
- ✅ Secret management via GitHub Secrets

## 🚀 Quick Start Options

### Option 1: Local Development (Fastest)

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/CI-CD-Project.git
cd CI-CD-Project

# 2. Verify file structure
./verify-structure.sh      # Linux/Mac
.\verify-structure.ps1     # Windows

# 3. Start all services
docker-compose up --build

# 4. Access application
# Frontend: http://localhost
# Backend: http://localhost:5000/api
# Health: http://localhost:5000/api/health
```

### Option 2: AWS Deployment (Production)

**Prerequisites:**

- AWS Account
- Terraform installed
- AWS CLI configured
- SSH key pair generated

**Quick Deploy:**

```bash
# 1. Configure Terraform
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 2. Deploy infrastructure
terraform init
terraform apply

# 3. Wait for user-data (5-10 min) & deploy app manually
# See POST-TERRAFORM-DEPLOYMENT.md for complete steps

# 4. Configure GitHub Actions secrets
# Then future deployments are automatic!
```

**📖 Critical:** After `terraform apply`, you MUST follow [POST-TERRAFORM-DEPLOYMENT.md](POST-TERRAFORM-DEPLOYMENT.md) for:

- Manual first deployment on EC2
- GitHub Actions configuration
- Automated deployment setup

**Detailed Guides:**

- [AWS-SETUP-GUIDE.md](AWS-SETUP-GUIDE.md) - Complete AWS setup
- [POST-TERRAFORM-DEPLOYMENT.md](POST-TERRAFORM-DEPLOYMENT.md) - Post-Terraform steps
- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Visual workflow

### Option 3: Automated CI/CD (Recommended)

```bash
# 1. Deploy infrastructure with Terraform (one-time)
cd terraform
terraform apply

# 2. Configure GitHub Secrets
# Add to GitHub → Settings → Secrets:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - EC2_HOST
# - EC2_SSH_PRIVATE_KEY
# - GITHUB_REPO

# 3. Push code to deploy automatically
git add .
git commit -m "Deploy to AWS"
git push origin main

# GitHub Actions will automatically:
# - Clone repo to EC2
# - Build Docker images
# - Start containers
# - Verify deployment
```

## 📡 API Endpoints

| Method | Endpoint         | Description           |
| ------ | ---------------- | --------------------- |
| GET    | `/api/health`    | Health check endpoint |
| GET    | `/api/todos`     | Get all todos         |
| POST   | `/api/todos`     | Create a new todo     |
| PUT    | `/api/todos/:id` | Update a todo         |
| DELETE | `/api/todos/:id` | Delete a todo         |

### Example API Usage

```bash
# Health Check
curl http://localhost:5000/api/health

# Get All Todos
curl http://localhost:5000/api/todos

# Create Todo
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"text":"Buy groceries"}'

# Update Todo
curl -X PUT http://localhost:5000/api/todos/ \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'

# Delete Todo
curl -X DELETE http://localhost:5000/api/todos/
```

## 🐳 Docker Commands

### Local Development

```bash
# Start all containers
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Stop and remove volumes (deletes data)
docker-compose down -v

# Rebuild specific service
docker-compose up -d --build frontend

# Check container status
docker-compose ps

# Execute commands in container
docker exec -it todo-backend sh
```

### Individual Containers

```bash
# Build individual services
docker build -t todo-frontend ./frontend
docker build -t todo-backend ./backend

# Run standalone database
docker run -d -p 27017:27017 -v todo-data:/data/db mongo:7.0
```

## ☁️ Terraform Infrastructure Management

### Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# Destroy infrastructure
terraform destroy
```

### Get Infrastructure Info

```bash
# Get EC2 public IP
terraform output ec2_public_ip

# Get application URL
terraform output application_url

# Get SSH command
terraform output ssh_command

# View all outputs
terraform output
```

### SSH into EC2

```bash
# Use output command
ssh -i ~/.ssh/todo-app-key ubuntu@

# Or get from Terraform
ssh -i ~/.ssh/todo-app-key ubuntu@$(terraform output -raw ec2_public_ip)
```

## 💰 AWS Cost Breakdown

### Free Tier (First 12 Months)

| Resource         | Free Tier       | This Project  |
| ---------------- | --------------- | ------------- |
| EC2 t3.micro     | 750 hours/month | ✅ Used       |
| EBS Storage      | 30 GB           | ✅ 20 GB used |
| Data Transfer    | 15 GB/month out | ✅ Covered    |
| VPC, Subnet, IGW | Free            | ✅ Free       |

### After Free Tier

| Resource              | Monthly Cost   |
| --------------------- | -------------- |
| EC2 t3.micro (24/7)   | $7.50          |
| EBS 20GB gp3          | $1.60          |
| Data Transfer         | ~$1.00         |
| Elastic IP (attached) | $0.00          |
| **Total**             | **~$10/month** |

### Cost Optimization Tips

```bash
# Stop instance when not in use
aws ec2 stop-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Start when needed
aws ec2 start-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Or destroy completely
terraform destroy
```

## 💾 Database Management

### Backup Database

```bash
# Make script executable
chmod +x database/backup.sh

# Run backup
./database/backup.sh

# Backups stored in: ./backups/
```

### Restore Database

```bash
# Make script executable
chmod +x database/restore.sh

# List backups
ls -lh backups/

# Restore from backup
./database/restore.sh ./backups/todoapp_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Access MongoDB Shell

```bash
# Local
docker exec -it todo-database mongosh

# On EC2
ssh -i ~/.ssh/todo-app-key ubuntu@
docker exec -it todo-database mongosh

# Use database
use todoapp

# View todos
db.todos.find().pretty()
```

## 🔍 Monitoring & Debugging

### Check Application Health

```bash
# Local
curl http://localhost:5000/api/health
curl http://localhost

# AWS
curl http://:5000/api/health
curl http://
```

### View Logs

```bash
# Local - All services
docker-compose logs -f

# Local - Specific service
docker-compose logs -f backend

# AWS - SSH and check logs
ssh -i ~/.ssh/todo-app-key ubuntu@
cd /home/ubuntu/app
docker-compose logs -f
```

### Check Infrastructure

```bash
# Terraform state
terraform show

# AWS resources
aws ec2 describe-instances
aws ec2 describe-vpcs
aws ec2 describe-security-groups

# Container status (on EC2)
docker compose ps
docker stats
```

## 🧪 Testing

### Local Testing

```bash
# Start application
docker-compose up -d

# Run tests
./verify-structure.sh  # Verify file structure
curl http://localhost:5000/api/health  # Backend health
curl http://localhost  # Frontend

# Create a todo
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"text":"Test todo"}'
```

### AWS Testing

```bash
# Get EC2 IP
EC2_IP=$(cd terraform && terraform output -raw ec2_public_ip)

# Test endpoints
curl http://$EC2_IP:5000/api/health
curl http://$EC2_IP

# Test from browser
echo "Visit: http://$EC2_IP"
```

### GitHub Actions Testing

```bash
# Trigger deployment
git add .
git commit -m "Test deployment"
git push origin main

# Watch workflow
# GitHub → Actions tab

# Verify deployment
curl http://:5000/api/health
```

## 🛠️ Troubleshooting

### Local Issues

**Port already in use:**

```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :5000

# Stop conflicting services or change ports in docker-compose.yml
```

**Container fails to start:**

```bash
# Check logs
docker-compose logs

# Rebuild without cache
docker-compose build --no-cache
docker-compose up -d
```

### AWS Issues

**Cannot SSH to EC2:**

```bash
# Check security group allows your IP
curl ifconfig.me

# Update terraform.tfvars
ssh_allowed_ips = ["YOUR_IP/32"]
terraform apply

# Verify SSH key permissions
chmod 600 ~/.ssh/todo-app-key
```

**Application not accessible:**

```bash
# SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@

# Check if Docker is installed
docker --version

# Check if containers are running
docker compose ps

# Check application logs
docker compose logs

# Verify user-data completed
sudo cat /var/log/cloud-init-output.log
```

### GitHub Actions Issues

**Workflow fails:**

1. Check all GitHub Secrets are set correctly
2. Verify EC2_HOST is just the IP (no http://)
3. Ensure SSH private key includes BEGIN/END lines
4. Check EC2 instance is running
5. View workflow logs in GitHub Actions tab

## 📈 Scaling Guide

### Vertical Scaling (Immediate)

```hcl
# In terraform/variables.tf
variable "instance_type" {
  default = "t3.small"  # or t3.medium
}

# Apply changes
terraform apply
```

### Horizontal Scaling (Future)

Add these to your Terraform:

- Application Load Balancer
- Auto Scaling Group
- Multiple EC2 instances
- Managed MongoDB (DocumentDB)

## 🔐 Security Best Practices

### Current Security Features

- ✅ VPC with isolated subnets
- ✅ Security Groups with minimal ports
- ✅ SSH restricted to specific IPs
- ✅ IAM roles with least privilege
- ✅ EBS encryption enabled
- ✅ IMDSv2 required
- ✅ Secrets managed via GitHub Secrets

### Production Recommendations

- [ ] Add SSL/TLS with Let's Encrypt
- [ ] Enable AWS WAF for DDoS protection
- [ ] Use AWS Secrets Manager
- [ ] Enable CloudWatch monitoring
- [ ] Set up VPN or Bastion host
- [ ] Implement rate limiting
- [ ] Add authentication/authorization

## 📚 Documentation

- **[README.md](README.md)** - This file (main documentation)
- **[AWS-SETUP-GUIDE.md](AWS-SETUP-GUIDE.md)** - Complete AWS deployment guide
- **[PROJECT-SUMMARY.md](PROJECT-SUMMARY.md)** - Architecture and technology overview
- **[SETUP-CHECKLIST.md](SETUP-CHECKLIST.md)** - File structure verification
- **[frontend/README.md](frontend/README.md)** - Frontend documentation
- **[backend/README.md](backend/README.md)** - Backend API documentation
- **[database/README.md](database/README.md)** - Database management guide
- **[terraform/README.md](terraform/README.md)** - Infrastructure documentation

## 🎓 Learning Outcomes

This project demonstrates:

- ✅ Full-stack web development (React, Node.js, MongoDB)
- ✅ Docker containerization and orchestration
- ✅ Infrastructure as Code with Terraform
- ✅ AWS cloud services (VPC, EC2, IAM)
- ✅ CI/CD pipelines with GitHub Actions
- ✅ DevOps best practices
- ✅ Cost optimization strategies
- ✅ Security implementation
- ✅ Documentation and maintenance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- React team for the amazing frontend library
- Express.js for the lightweight backend framework
- MongoDB for the flexible NoSQL database
- Docker for containerization technology
- Terraform for Infrastructure as Code
- AWS for cloud infrastructure
- GitHub Actions for CI/CD automation

## 📞 Support

- **Issues**: Report bugs via [GitHub Issues](https://github.com/YOUR_USERNAME/CI-CD-Project/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/YOUR_USERNAME/CI-CD-Project/discussions)
- **Documentation**: Check the docs folder for detailed guides

## 🚀 Quick Reference

```bash
# Local Development
docker-compose up --build                    # Start all services
docker-compose down                          # Stop services

# AWS Deployment
cd terraform && terraform apply              # Deploy infrastructure
terraform output application_url             # Get app URL
terraform destroy                            # Remove all resources

# CI/CD
git push origin main                         # Auto-deploy via GitHub Actions

# Monitoring
docker-compose logs -f                       # View logs
curl http://localhost:5000/api/health       # Health check

# Database
./database/backup.sh                         # Backup database
./database/restore.sh          # Restore database
```

---

**⭐ Star this repository if you found it helpful!**

**Built with ❤️ for learning DevOps, Cloud Computing, and Full-Stack Development**
