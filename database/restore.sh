#!/bin/bash

# MongoDB Restore Script for To-Do Application
# Usage: ./restore.sh <backup_file.tar.gz>

# Configuration
CONTAINER_NAME="todo-database"
DB_NAME="todoapp"
BACKUP_DIR="./backups"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backup file is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo -e "${YELLOW}Usage: ./restore.sh <backup_file.tar.gz>${NC}"
    echo -e "\n${YELLOW}Available backups:${NC}"
    ls -lh $BACKUP_DIR/*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE=$1

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

# Check if container is running
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${RED}Error: Container $CONTAINER_NAME is not running${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting MongoDB Restore...${NC}"
echo -e "${YELLOW}Backup file: $BACKUP_FILE${NC}"

# Extract backup filename without extension
BACKUP_NAME=$(basename "$BACKUP_FILE" .tar.gz)

# Extract backup
echo -e "${YELLOW}Extracting backup...${NC}"
TEMP_DIR=$(mktemp -d)
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Copy extracted backup to container
echo -e "${YELLOW}Copying backup to container...${NC}"
docker cp "$TEMP_DIR/$BACKUP_NAME" $CONTAINER_NAME:/tmp/

# Restore database
echo -e "${YELLOW}Restoring database...${NC}"
docker exec $CONTAINER_NAME mongorestore --db=$DB_NAME --drop /tmp/$BACKUP_NAME/$DB_NAME

# Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
docker exec $CONTAINER_NAME rm -rf /tmp/$BACKUP_NAME
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Restore completed successfully!${NC}"

# Verify restoration
echo -e "\n${YELLOW}Verifying data...${NC}"
TODO_COUNT=$(docker exec $CONTAINER_NAME mongosh $DB_NAME --quiet --eval "db.todos.countDocuments()")
echo -e "${GREEN}Total todos in database: $TODO_COUNT${NC}"