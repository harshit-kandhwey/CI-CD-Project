import React, { useState, useEffect } from 'react';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

function App() {
    const [todos, setTodos] = useState([]);
    const [newTodo, setNewTodo] = useState('');
    const [filter, setFilter] = useState('all');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchTodos();
    }, []);

    const fetchTodos = async () => {
        setLoading(true);
        try {
            const response = await fetch(`${API_URL}/todos`);
            const data = await response.json();
            setTodos(data);
        } catch (error) {
            console.error('Error fetching todos:', error);
        }
        setLoading(false);
    };

    const addTodo = async (e) => {
        e.preventDefault();
        if (!newTodo.trim()) return;

        try {
            const response = await fetch(`${API_URL}/todos`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ text: newTodo })
            });
            const data = await response.json();
            setTodos([...todos, data]);
            setNewTodo('');
        } catch (error) {
            console.error('Error adding todo:', error);
        }
    };

    const toggleTodo = async (id, completed) => {
        try {
            const response = await fetch(`${API_URL}/todos/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ completed: !completed })
            });
            const data = await response.json();
            setTodos(todos.map(todo => todo._id === id ? data : todo));
        } catch (error) {
            console.error('Error updating todo:', error);
        }
    };

    const deleteTodo = async (id) => {
        try {
            await fetch(`${API_URL}/todos/${id}`, { method: 'DELETE' });
            setTodos(todos.filter(todo => todo._id !== id));
        } catch (error) {
            console.error('Error deleting todo:', error);
        }
    };

    const filteredTodos = todos.filter(todo => {
        if (filter === 'active') return !todo.completed;
        if (filter === 'completed') return todo.completed;
        return true;
    });

    const stats = {
        total: todos.length,
        active: todos.filter(t => !t.completed).length,
        completed: todos.filter(t => t.completed).length
    };

    return (
        <div className="app-container">
            <div className="todo-card">
                <header className="header">
                    <h1>📝 To-Do Application</h1>
                    <p className="subtitle">Organize your tasks efficiently</p>
                </header>

                <form onSubmit={addTodo} className="input-form">
                    <input
                        type="text"
                        value={newTodo}
                        onChange={(e) => setNewTodo(e.target.value)}
                        placeholder="What needs to be done?"
                        className="todo-input"
                    />
                    <button type="submit" className="add-button">Add Task</button>
                </form>

                <div className="stats-bar">
                    <div className="stat">
                        <span className="stat-label">Total</span>
                        <span className="stat-value">{stats.total}</span>
                    </div>
                    <div className="stat">
                        <span className="stat-label">Active</span>
                        <span className="stat-value active">{stats.active}</span>
                    </div>
                    <div className="stat">
                        <span className="stat-label">Completed</span>
                        <span className="stat-value completed">{stats.completed}</span>
                    </div>
                </div>

                <div className="filter-buttons">
                    <button
                        className={filter === 'all' ? 'active' : ''}
                        onClick={() => setFilter('all')}
                    >
                        All
                    </button>
                    <button
                        className={filter === 'active' ? 'active' : ''}
                        onClick={() => setFilter('active')}
                    >
                        Active
                    </button>
                    <button
                        className={filter === 'completed' ? 'active' : ''}
                        onClick={() => setFilter('completed')}
                    >
                        Completed
                    </button>
                </div>

                {loading ? (
                    <div className="loading">Loading tasks...</div>
                ) : (
                    <ul className="todo-list">
                        {filteredTodos.length === 0 ? (
                            <li className="empty-state">
                                {filter === 'all' ? 'No tasks yet. Add one above!' :
                                    filter === 'active' ? 'No active tasks!' :
                                        'No completed tasks!'}
                            </li>
                        ) : (
                            filteredTodos.map(todo => (
                                <li key={todo._id} className={`todo-item ${todo.completed ? 'completed' : ''}`}>
                                    <div className="todo-content">
                                        <input
                                            type="checkbox"
                                            checked={todo.completed}
                                            onChange={() => toggleTodo(todo._id, todo.completed)}
                                            className="checkbox"
                                        />
                                        <span className="todo-text">{todo.text}</span>
                                    </div>
                                    <button
                                        onClick={() => deleteTodo(todo._id)}
                                        className="delete-button"
                                    >
                                        🗑️
                                    </button>
                                </li>
                            ))
                        )}
                    </ul>
                )}
            </div>
        </div>
    );
}

export default App;