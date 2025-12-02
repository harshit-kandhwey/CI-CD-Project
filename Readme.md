# 📝 3-Tier To-Do Application

A professional, full-stack To-Do application built with a microservices architecture using Docker containers. Perfect for DevOps demonstrations, showcasing container orchestration, persistent storage, and multi-tier application deployment.

![Architecture](https://img.shields.io/badge/Architecture-3--Tier-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)
![Node.js](https://img.shields.io/badge/Node.js-18-339933?logo=node.js)
![MongoDB](https://img.shields.io/badge/MongoDB-7.0-47A248?logo=mongodb)

## 🏗️ Architecture

This application follows a **3-tier architecture** with complete separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENT                              │
│                    (Web Browser)                            │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP (Port 80)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   TIER 1: FRONTEND                          │
│              React + Nginx Container                        │
│                    (todo-frontend)                          │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API (Port 5000)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   TIER 2: BACKEND                           │
│            Node.js + Express Container                      │
│                   (todo-backend)                            │
└────────────────────────┬────────────────────────────────────┘
                         │ MongoDB Protocol (Port 27017)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   TIER 3: DATABASE                          │
│               MongoDB Container                             │
│                  (todo-database)                            │
│            Volume: todo-app-data                            │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
todo-app/
├── frontend/                # Tier 1: Frontend Layer
│   ├── README.md            # Detailed frontend docs
│   ├── Dockerfile           # Multi-stage build with Node + Nginx
│   ├── package.json         # React dependencies
│   ├── vite.config.js       # Vite bundler configuration
│   ├── nginx.conf           # Nginx server configuration
│   └── src/
│       ├── index.html       # HTML entry point
│       ├── main.jsx         # React entry point
│       ├── App.jsx          # Main React component
│       └── styles.css       # Application styles
│
├── backend/                 # Tier 2: Backend Layer
│   ├── README.md            # Detailed backend docs
│   ├── Dockerfile           # Node.js Alpine container
│   ├── package.json         # Express, Mongoose dependencies
│   ├── server.js            # Express API server
│   └── .env                 # Environment variables
│
├── database/                # Tier 3: Database Layer
│   ├── init-db.js           # MongoDB initialization script
│   ├── backup.sh            # Database backup script
│   ├── restore.sh           # Database restore script
│   ├── mongod.conf          # MongoDB configuration (optional)
│   └── README.md            # Database documentation
│
├── docker-compose.yml        # Container orchestration
└── README.md                 # This file
```

## ✨ Features

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

## 🚀 Quick Start

### Prerequisites
- Docker (20.10+)
- Docker Compose (2.0+)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd todo-app
   ```

2. **Build and start all containers**
   ```bash
   docker-compose up --build
   ```

3. **Access the application**
   - **Frontend**: http://localhost
   - **Backend API**: http://localhost:5000/api
   - **Health Check**: http://localhost:5000/api/health

4. **Stop the application**
   ```bash
   docker-compose down
   ```

5. **Stop and remove all data**
   ```bash
   docker-compose down -v
   ```

## 🔧 Development

### Run in Development Mode

**Frontend Development:**
```bash
cd frontend
npm install
npm run dev
# Access at http://localhost:3000
```

**Backend Development:**
```bash
cd backend
npm install
npm run dev
# API runs at http://localhost:5000
```

### Environment Variables

**Backend (.env):**
```env
PORT=5000
MONGODB_URI=mongodb://database:27017/todoapp
```

**Frontend:**
```env
VITE_API_URL=http://localhost/api
```

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check endpoint |
| GET | `/api/todos` | Get all todos |
| POST | `/api/todos` | Create a new todo |
| PUT | `/api/todos/:id` | Update a todo |
| DELETE | `/api/todos/:id` | Delete a todo |

### Example API Requests

**Create a Todo:**
```bash
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"text":"Buy groceries"}'
```

**Get All Todos:**
```bash
curl http://localhost:5000/api/todos
```

**Update a Todo:**
```bash
curl -X PUT http://localhost:5000/api/todos/<todo-id> \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

**Delete a Todo:**
```bash
curl -X DELETE http://localhost:5000/api/todos/<todo-id>
```

## 🐳 Docker Commands

### Container Management

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f backend

# Restart a service
docker-compose restart backend

# Rebuild a specific service
docker-compose up -d --build frontend

# Stop all containers
docker-compose down

# Remove all containers, networks, and volumes
docker-compose down -v
```

### Individual Container Commands

```bash
# Build frontend only
docker build -t todo-frontend ./frontend

# Build backend only
docker build -t todo-backend ./backend

# Run database only
docker run -d -p 27017:27017 -v todo-data:/data/db mongo:7.0
```

## 💾 Database Management

### Backup Database

```bash
# Make script executable (first time only)
chmod +x database/backup.sh

# Run backup
./database/backup.sh
```

Backups are stored in `./backups/` directory with timestamp.

### Restore Database

```bash
# Make script executable (first time only)
chmod +x database/restore.sh

# List available backups
ls -lh backups/

# Restore from backup
./database/restore.sh ./backups/todoapp_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Access MongoDB Shell

```bash
# Connect to MongoDB shell
docker exec -it todo-database mongosh

# Use the todoapp database
use todoapp

# View all todos
db.todos.find().pretty()

# Count todos
db.todos.countDocuments()

# Clear all todos
db.todos.deleteMany({})
```

## 🔍 Monitoring & Debugging

### Health Checks

```bash
# Check backend health
curl http://localhost:5000/api/health

# Check if all containers are healthy
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f database

# Last 50 lines
docker-compose logs --tail=50 backend
```

### Inspect Containers

```bash
# Execute command in container
docker exec -it todo-backend sh

# View container details
docker inspect todo-backend

# View network details
docker network inspect todo-network

# View volume details
docker volume inspect todo-app-data
```

## 🧪 Testing

### Manual Testing

1. **Create a todo** - Add a new task
2. **Mark as complete** - Click checkbox
3. **Filter tasks** - Use All/Active/Completed filters
4. **Delete todo** - Click trash icon
5. **Restart containers** - Verify data persistence

### API Testing with curl

```bash
# Health check
curl http://localhost:5000/api/health

# Get all todos
curl http://localhost:5000/api/todos

# Create todo
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"text":"Test todo"}'

# Update todo (replace <id> with actual ID)
curl -X PUT http://localhost:5000/api/todos/<id> \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'

# Delete todo
curl -X DELETE http://localhost:5000/api/todos/<id>
```

## 🛠️ Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :5000
sudo lsof -i :27017

# Kill the process or change ports in docker-compose.yml
```

**Container fails to start:**
```bash
# Check logs
docker-compose logs <service-name>

# Rebuild without cache
docker-compose build --no-cache
docker-compose up -d
```

**Database connection fails:**
```bash
# Check if database is running
docker-compose ps database

# Check database logs
docker-compose logs database

# Restart database
docker-compose restart database
```

**Frontend can't connect to backend:**
```bash
# Check nginx configuration
docker exec -it todo-frontend cat /etc/nginx/conf.d/default.conf

# Check backend is accessible
curl http://localhost:5000/api/health
```

**Data not persisting:**
```bash
# Check volume exists
docker volume ls | grep todo-app-data

# Inspect volume
docker volume inspect todo-app-data

# Don't use -v flag when stopping
docker-compose down  # ✅ Keeps data
docker-compose down -v  # ❌ Removes data
```

## 📊 Performance Optimization

### Production Recommendations

1. **Enable MongoDB authentication**
2. **Use environment-specific builds**
3. **Implement rate limiting in backend**
4. **Add Redis caching layer**
5. **Use CDN for static assets**
6. **Implement monitoring (Prometheus/Grafana)**
7. **Add SSL/TLS certificates**

## 🔒 Security Considerations

- MongoDB runs without authentication (development only)
- CORS is enabled for all origins (configure for production)
- No rate limiting implemented (add for production)
- Passwords should be stored in secrets (for production)
- Use HTTPS in production
- Implement input sanitization
- Add authentication/authorization

## 📈 Scaling

### Horizontal Scaling

```yaml
# Scale backend instances
docker-compose up -d --scale backend=3

# Add load balancer (nginx/traefik)
# Configure sticky sessions for WebSocket support
```

### Vertical Scaling

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Created for DevOps demonstrations and learning purposes.

## 🙏 Acknowledgments

- React team for the amazing frontend library
- Express.js for the lightweight backend framework
- MongoDB for the flexible NoSQL database
- Docker for containerization technology
- Nginx for high-performance web serving

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [React Documentation](https://react.dev/)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Manual](https://docs.mongodb.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

---


**⭐ Star this repository if you found it helpful!**

