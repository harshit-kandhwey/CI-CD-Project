#!/bin/bash

# MongoDB Backup Script for To-Do Application
# Usage: ./backup.sh

# Configuration
CONTAINER_NAME="todo-database"
DB_NAME="todoapp"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="todoapp_backup_${TIMESTAMP}"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting MongoDB Backup...${NC}"

# Check if container is running
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${RED}Error: Container $CONTAINER_NAME is not running${NC}"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Perform backup
echo -e "${YELLOW}Creating backup: $BACKUP_NAME${NC}"
docker exec $CONTAINER_NAME mongodump --db=$DB_NAME --out=/tmp/$BACKUP_NAME

# Copy backup from container to host
echo -e "${YELLOW}Copying backup to host...${NC}"
docker cp $CONTAINER_NAME:/tmp/$BACKUP_NAME $BACKUP_DIR/

# Clean up temporary backup in container
docker exec $CONTAINER_NAME rm -rf /tmp/$BACKUP_NAME

# Compress backup
echo -e "${YELLOW}Compressing backup...${NC}"
cd $BACKUP_DIR
tar -czf ${BACKUP_NAME}.tar.gz $BACKUP_NAME
rm -rf $BACKUP_NAME
cd ..

echo -e "${GREEN}✅ Backup completed successfully!${NC}"
echo -e "${GREEN}Backup location: $BACKUP_DIR/${BACKUP_NAME}.tar.gz${NC}"

# List all backups
echo -e "\n${YELLOW}Available backups:${NC}"
ls -lh $BACKUP_DIR/*.tar.gz