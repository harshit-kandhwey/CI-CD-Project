#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Git
apt-get install -y git

# Create application directory
mkdir -p /home/ubuntu/app
chown ubuntu:ubuntu /home/ubuntu/app

# Install AWS CloudWatch agent (optional, for monitoring)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# Create docker cleanup script
cat > /usr/local/bin/docker-cleanup.sh << 'EOF'
#!/bin/bash
# Clean up unused Docker resources
docker system prune -af --volumes
EOF
chmod +x /usr/local/bin/docker-cleanup.sh

# Create systemd service for app (will be started by GitHub Actions)
cat > /etc/systemd/system/todo-app.service << 'EOF'
[Unit]
Description=To-Do Application
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/app
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Create deployment script for GitHub Actions
cat > /home/ubuntu/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting deployment..."

# Navigate to app directory
cd /home/ubuntu/app

# Pull latest changes
git pull origin main

# Stop existing containers
docker compose down || true

# Remove old images
docker system prune -af

# Build and start containers
docker compose up -d --build

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 30

# Check if services are running
docker compose ps

echo "Deployment completed!"
echo "Application URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
EOF

chmod +x /home/ubuntu/deploy.sh
chown ubuntu:ubuntu /home/ubuntu/deploy.sh

# Setup GitHub Actions runner user (will be configured by GitHub Actions)
mkdir -p /home/ubuntu/.ssh
chown ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

# Create health check script
cat > /home/ubuntu/health-check.sh << 'EOF'
#!/bin/bash

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    echo "Docker is not running!"
    exit 1
fi

# Check if containers are running
if [ "$(docker compose ps -q | wc -l)" -eq 0 ]; then
    echo "No containers running!"
    exit 1
fi

echo "Health check passed!"
exit 0
EOF

chmod +x /home/ubuntu/health-check.sh
chown ubuntu:ubuntu /home/ubuntu/health-check.sh

# Setup cron job for health checks (optional)
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/health-check.sh >> /var/log/health-check.log 2>&1") | crontab -u ubuntu -

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log

# Signal completion
touch /var/lib/cloud/instance/boot-finished