// MongoDB initialization script
// This script runs automatically when the database container starts for the first time

db = db.getSiblingDB('todoapp');

// Create todos collection with sample data
db.todos.insertMany([
  {
    text: "Welcome to your To-Do App! 👋",
    completed: false,
    createdAt: new Date()
  },
  {
    text: "Click the checkbox to mark tasks as complete ✅",
    completed: false,
    createdAt: new Date()
  },
  {
    text: "Click the trash icon to delete tasks 🗑️",
    completed: false,
    createdAt: new Date()
  },
  {
    text: "Use filters to view All, Active, or Completed tasks 🔍",
    completed: false,
    createdAt: new Date()
  },
  {
    text: "This is a sample completed task",
    completed: true,
    createdAt: new Date()
  }
]);

// Create indexes for better performance
db.todos.createIndex({ createdAt: -1 });
db.todos.createIndex({ completed: 1 });

print('✅ Database initialized successfully!');
print('📊 Collection: todoapp.todos');
print('📝 Sample todos inserted: ' + db.todos.countDocuments());