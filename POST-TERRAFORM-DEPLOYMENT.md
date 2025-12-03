# 🚀 Post-Terraform Deployment Guide

## What Happens After `terraform apply`?

After Terraform completes, you'll have:

- ✅ EC2 instance running
- ✅ Docker and Git installed (via user-data script)
- ✅ Security groups configured
- ❌ **Application NOT yet deployed**

You need to do **3 steps** to complete the setup.

---

## 📋 Complete Deployment Steps

### Step 1: Wait for User-Data Script to Complete

**Time: 5-10 minutes**

The user-data script is installing Docker and Git on your EC2 instance. You need to wait for it to finish.

```bash
# Get your EC2 IP from Terraform
cd terraform
export EC2_IP=$(terraform output -raw ec2_public_ip)
echo "EC2 IP: $EC2_IP"

# SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@$EC2_IP

# Check if user-data is still running
tail -f /var/log/cloud-init-output.log

# Wait until you see:
# "Cloud-init v. XX.X.X finished at ..."
# Then press Ctrl+C
```

**Verify Docker is installed:**

```bash
docker --version
docker compose version

# If these work, user-data is complete ✅
```

---

### Step 2: Manual First Deployment on EC2

**Time: 5-10 minutes**

You need to deploy the application once manually. Future deployments will be automatic via GitHub Actions.

```bash
# Still in SSH session on EC2

# Create app directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Clone your repository
# Replace YOUR_USERNAME with your GitHub username
git clone https://github.com/YOUR_USERNAME/CI-CD-Project.git .

# Verify files are present
ls -la

# You should see:
# - docker-compose.yml
# - frontend/
# - backend/
# - database/

# Deploy the application
docker compose up -d --build

# This will:
# 1. Build frontend image (~2-3 minutes)
# 2. Build backend image (~1 minute)
# 3. Pull MongoDB image (~1 minute)
# 4. Start all containers

# Wait for it to complete...
```

**Verify deployment:**

```bash
# Check if containers are running
docker compose ps

# Should show:
# NAME              STATUS          PORTS
# todo-frontend     Up             0.0.0.0:80->80/tcp
# todo-backend      Up             0.0.0.0:5000->5000/tcp
# todo-database     Up             0.0.0.0:27017->27017/tcp

# Test locally on EC2
curl http://localhost:5000/api/health

# Should return:
# {"status":"OK","message":"Backend is running","database":"Connected"}

curl http://localhost

# Should return HTML of your frontend

# Exit SSH
exit
```

**Test from your local machine:**

```bash
# Test backend
curl http://$EC2_IP:5000/api/health

# Test frontend - Open in browser
echo "Open in browser: http://$EC2_IP"
```

---

### Step 3: Configure GitHub Actions

**Time: 5 minutes**

Now set up GitHub Actions so future code pushes automatically deploy.

#### 3.1: Add GitHub Secrets

Go to your GitHub repository:

1. Click **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each of these secrets:

| Secret Name             | Value                   | How to Get It                                        |
| ----------------------- | ----------------------- | ---------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Your AWS access key     | From AWS IAM (Step 2 of AWS-SETUP-GUIDE.md)          |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key     | From AWS IAM                                         |
| `EC2_HOST`              | EC2 public IP address   | `terraform output ec2_public_ip`                     |
| `EC2_SSH_PRIVATE_KEY`   | SSH private key content | `cat ~/.ssh/todo-app-key`                            |
| `GITHUB_REPO`           | Your GitHub repo URL    | `https://github.com/YOUR_USERNAME/CI-CD-Project.git` |

**Getting the SSH Private Key:**

```bash
# Display your private key
cat ~/.ssh/todo-app-key

# Copy the ENTIRE output including:
# -----BEGIN OPENSSH PRIVATE KEY-----
# ... content ...
# -----END OPENSSH PRIVATE KEY-----
```

#### 3.2: Verify GitHub Actions Workflow Exists

Ensure this file exists in your repository:

```
.github/workflows/deploy.yml
```

If it doesn't exist, create it with the content from the artifact.

#### 3.3: Test Automated Deployment

```bash
# Make a small change to trigger deployment
echo "# Automated Deployment Test" >> README.md

# Commit and push
git add .
git commit -m "Test: GitHub Actions automated deployment"
git push origin main
```

**Watch the deployment:**

1. Go to GitHub → Your Repository
2. Click **Actions** tab
3. You should see a workflow running
4. Click on it to see live logs

**The workflow will:**

1. ✅ Checkout code
2. ✅ Configure AWS credentials
3. ✅ Setup SSH key
4. ✅ SSH into your EC2
5. ✅ Pull latest code from GitHub
6. ✅ Stop old containers
7. ✅ Build new images
8. ✅ Start new containers
9. ✅ Run health checks

**Verify deployment:**

```bash
# Check if app is updated
curl http://$EC2_IP:5000/api/health

# Visit in browser
open http://$EC2_IP  # macOS
start http://$EC2_IP  # Windows
```

---

## 🎉 Success! You're Now Fully Automated

From now on:

- ✅ Push code to GitHub (`git push origin main`)
- ✅ GitHub Actions automatically deploys to AWS
- ✅ Zero manual intervention needed

---

## 📊 Deployment Timeline Summary

| Step                 | Time           | Status                 |
| -------------------- | -------------- | ---------------------- |
| 1. `terraform apply` | 5 min          | Infrastructure created |
| 2. User-data script  | 5-10 min       | Docker/Git installed   |
| 3. Manual deployment | 5-10 min       | App running on EC2     |
| 4. GitHub secrets    | 5 min          | CI/CD configured       |
| **Total**            | **~20-30 min** | ✅ Fully automated!    |

---

## 🔄 Future Deployments (Automatic)

```bash
# Make code changes
nano frontend/App.jsx

# Commit and push
git add .
git commit -m "Update: New feature"
git push origin main

# GitHub Actions automatically:
# 1. Detects push
# 2. Runs workflow
# 3. Deploys to EC2
# 4. Verifies health

# 2-3 minutes later: Your app is updated! ✅
```

---

## 🐛 Troubleshooting

### Issue 1: User-Data Script Not Completing

**Symptoms:** Docker commands not found on EC2

**Solution:**

```bash
# SSH into EC2
ssh -i ~/.ssh/todo-app-key ubuntu@$EC2_IP

# Check user-data status
sudo cat /var/log/cloud-init-output.log

# If errors, manually install Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker ubuntu

# Log out and back in
exit
ssh -i ~/.ssh/todo-app-key ubuntu@$EC2_IP
```

### Issue 2: Git Clone Fails (Private Repo)

**Symptoms:** "Repository not found" or "Permission denied"

**Solution:**

**Option A: Make repo public** (easiest for learning)

```bash
# GitHub → Settings → Change visibility → Public
```

**Option B: Use Personal Access Token** (for private repos)

```bash
# On EC2
cd /home/ubuntu/app
git clone https://YOUR_TOKEN@github.com/YOUR_USERNAME/CI-CD-Project.git .

# Get token from: GitHub → Settings → Developer settings → Personal access tokens
```

**Option C: Use SSH key for GitHub**

```bash
# On EC2, generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Display public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key

# Clone with SSH
git clone git@github.com:YOUR_USERNAME/CI-CD-Project.git .
```

### Issue 3: Docker Compose Build Fails

**Symptoms:** "ERROR: failed to solve..."

**Solution:**

```bash
# Check disk space
df -h

# If low, clean up
docker system prune -af

# Rebuild with verbose output
docker compose up -d --build

# Check logs
docker compose logs
```

### Issue 4: Containers Won't Start

**Symptoms:** `docker compose ps` shows "Exited" status

**Solution:**

```bash
# Check specific container logs
docker compose logs frontend
docker compose logs backend
docker compose logs database

# Common fixes:

# Frontend issue - usually build related
cd frontend
docker build -t test-frontend .

# Backend issue - usually MongoDB connection
# Check if database container is running
docker compose ps database

# Restart all services
docker compose down
docker compose up -d
```

### Issue 5: GitHub Actions Fails

**Symptoms:** Red X in Actions tab

**Check:**

```bash
# 1. Verify all secrets are set
# GitHub → Settings → Secrets → Actions
# Should have 5 secrets

# 2. Check EC2 is running
ssh -i ~/.ssh/todo-app-key ubuntu@$EC2_IP

# 3. Check app directory exists
ls -la /home/ubuntu/app

# 4. Verify .git directory exists
ls -la /home/ubuntu/app/.git

# 5. Check GitHub Actions logs for specific error
```

### Issue 6: Application Not Accessible

**Symptoms:** Cannot access http://<EC2_IP>

**Check:**

```bash
# 1. Verify EC2 public IP
cd terraform
terraform output ec2_public_ip

# 2. Check security group allows port 80
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw security_group_id)

# 3. SSH and check containers
ssh -i ~/.ssh/todo-app-key ubuntu@$EC2_IP
docker compose ps

# 4. Test locally on EC2
curl http://localhost

# 5. Check if nginx is listening
sudo netstat -tlnp | grep :80

# 6. Try accessing specific ports
curl http://<EC2_IP>:80
curl http://<EC2_IP>:5000/api/health
```

---

## 📝 Quick Command Reference

```bash
# Get EC2 IP
cd terraform && terraform output ec2_public_ip

# SSH to EC2
ssh -i ~/.ssh/todo-app-key ubuntu@$(cd terraform && terraform output -raw ec2_public_ip)

# Check application status (on EC2)
docker compose ps
docker compose logs -f

# Restart application (on EC2)
docker compose restart

# Rebuild and restart (on EC2)
docker compose down
docker compose up -d --build

# View GitHub Actions
# GitHub → Actions tab

# Trigger manual deployment
git commit --allow-empty -m "Trigger deployment"
git push origin main
```

---

## ✅ Final Verification Checklist

After completing all steps, verify:

- [ ] EC2 instance is running
- [ ] Docker is installed on EC2
- [ ] Application is cloned to `/home/ubuntu/app`
- [ ] All containers are running (`docker compose ps`)
- [ ] Frontend accessible at `http://<EC2_IP>`
- [ ] Backend responding at `http://<EC2_IP>:5000/api/health`
- [ ] Can create and manage todos
- [ ] All 5 GitHub secrets are configured
- [ ] `.github/workflows/deploy.yml` exists
- [ ] Git push triggers GitHub Actions
- [ ] GitHub Actions completes successfully
- [ ] Application updates after push

---

## 🎯 Summary

**One-Time Setup (Do Once):**

1. ✅ `terraform apply` (creates infrastructure)
2. ✅ Wait for user-data (installs Docker)
3. ✅ Manual deployment (first-time app setup)
4. ✅ Configure GitHub secrets (enables automation)

**Ongoing (Automatic):**

1. 🔄 Make code changes
2. 🔄 `git push origin main`
3. 🔄 GitHub Actions deploys automatically
4. ✅ Done!

---

**Need help?** Check the troubleshooting section or refer to [AWS-SETUP-GUIDE.md](AWS-SETUP-GUIDE.md) for detailed instructions.
