# EC2-Docker-Pipeline — End-to-End DevOps Pipeline with AWS Deployment

A 3-tier To-Do application (React + Node.js + MongoDB) deployed on AWS using Terraform for infrastructure provisioning and GitHub Actions for automated CI/CD.

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?logo=github-actions)

---

## Architecture

```
Developer → git push → GitHub Actions → SSH → EC2 (Docker Compose)

                        ┌─────────────────────────────┐
                        │         AWS VPC             │
                        │                             │
                        │   ┌─────────────────────┐   │
                        │   │    EC2 (t3.micro)   │   │
                        │   │                     │   │
                        │   │  ┌───────────────┐  │   │
                        │   │  │ Docker Compose│  │   │
                        │   │  │               │  │   │
                        │   │  │ Frontend :80  │  │   │
                        │   │  │ Backend :5000 │  │   │
                        │   │  │ MongoDB :27017│  │   │
                        │   │  └───────────────┘  │   │
                        │   └─────────────────────┘   │
                        │   Security Group + IGW + EIP │
                        └─────────────────────────────┘
```

---

## Tech Stack

| Layer            | Technology                       |
| ---------------- | -------------------------------- |
| Frontend         | React 18, Vite, Nginx            |
| Backend          | Node.js 18, Express.js, Mongoose |
| Database         | MongoDB 7.0 (Docker Volume)      |
| Infrastructure   | Terraform, AWS (VPC, EC2, IAM)   |
| CI/CD            | GitHub Actions, GitHub Secrets   |
| Containerization | Docker, Docker Compose           |

---

## Project Structure

```
EC2-Docker-Pipeline/
├── frontend/               # React app (multi-stage Docker build)
├── backend/                # Express REST API
├── database/               # MongoDB init scripts
├── terraform/              # IaC — VPC, EC2, Security Groups, IAM
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── user-data.sh        # EC2 bootstrap (installs Docker, Git)
├── .github/workflows/
│   └── deploy.yml          # GitHub Actions CI/CD workflow
└── docker-compose.yml
```

---

## How It Works

### One-Time Setup

**1. Provision infrastructure with Terraform**

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Fill in your SSH public key, AWS region, and allowed IPs

terraform init
terraform apply
# Creates: VPC, EC2, Security Groups, Elastic IP, IAM role
# EC2 user-data script auto-installs Docker and Git (~5-10 min)
```

**2. Deploy the app manually (first time only)**

```bash
# SSH into EC2
ssh -i ~/.ssh/your-key ubuntu@<EC2_PUBLIC_IP>

# Wait for user-data to finish
tail -f /var/log/cloud-init-output.log

# Clone and start the app
mkdir -p /home/ubuntu/app && cd /home/ubuntu/app
git clone https://github.com/harshit-kandhwey/EC2-Docker-Pipeline.git .
docker compose up -d --build
```

**3. Configure GitHub Secrets**

Go to: `GitHub → Settings → Secrets and variables → Actions`

| Secret                  | Value                                                         |
| ----------------------- | ------------------------------------------------------------- |
| `EC2_HOST`              | EC2 public IP (`terraform output ec2_public_ip`)              |
| `EC2_SSH_PRIVATE_KEY`   | Full content of your `~/.ssh/your-key` file                   |
| `AWS_ACCESS_KEY_ID`     | From your IAM user                                            |
| `AWS_SECRET_ACCESS_KEY` | From your IAM user                                            |
| `GIT_REPO`              | `https://github.com/harshit-kandhwey/EC2-Docker-Pipeline.git` |

---

### Automated Deployments (Every Push)

After setup, every `git push origin main` triggers GitHub Actions to:

1. SSH into the EC2 instance
2. Pull the latest code
3. Stop running containers
4. Rebuild Docker images with updated code
5. Start new containers and run a health check

Deployment takes ~2-3 minutes.

---

## Local Development

```bash
git clone https://github.com/YOUR_USERNAME/EC2-Docker-Pipeline.git
cd aws-cicd-pipeline
docker compose up --build

# Frontend: http://localhost
# Backend:  http://localhost:5000/api/health
```

---

## API Endpoints

| Method | Endpoint         | Description   |
| ------ | ---------------- | ------------- |
| GET    | `/api/health`    | Health check  |
| GET    | `/api/todos`     | Get all todos |
| POST   | `/api/todos`     | Create a todo |
| PUT    | `/api/todos/:id` | Update a todo |
| DELETE | `/api/todos/:id` | Delete a todo |

---

## AWS Cost

| Resource            | Cost           |
| ------------------- | -------------- |
| EC2 t3.micro (24/7) | ~$7.50/month   |
| EBS 20GB gp3        | ~$1.60/month   |
| Data Transfer       | ~$1.00/month   |
| **Total**           | **~$10/month** |

Covered by AWS Free Tier for the first 12 months. To avoid charges while not in use:

```bash
# Stop instance (preserves data)
aws ec2 stop-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Destroy everything when done
cd terraform && terraform destroy
```

---

## Troubleshooting

**Cannot SSH to EC2**

```bash
# Get your current IP and update terraform.tfvars
curl ifconfig.me
# ssh_allowed_ips = ["YOUR_IP/32"]
terraform apply

chmod 600 ~/.ssh/your-key  # Fix key permissions
```

**Application not accessible after deploy**

```bash
ssh -i ~/.ssh/your-key ubuntu@<EC2_IP>
docker compose ps         # Check container status
docker compose logs       # Check for errors
sudo cat /var/log/cloud-init-output.log  # Check user-data finished
```

**GitHub Actions workflow fails**

- Verify all 5 secrets are set
- `EC2_HOST` should be just the IP — no `http://`
- `EC2_SSH_PRIVATE_KEY` must include the `-----BEGIN` and `-----END` lines
- Check the Actions tab for the specific error

---

## Security

- VPC with isolated public subnet
- Security Groups with minimal open ports (22, 80, 5000)
- SSH restricted to specific IPs (configurable in `terraform.tfvars`)
- IAM role with least-privilege policy
- EBS encryption enabled, IMDSv2 required
- No credentials stored in code — all via GitHub Secrets
