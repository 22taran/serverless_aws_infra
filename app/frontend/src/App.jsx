import React, { useState, useEffect } from 'react'
import TaskList from './components/TaskList'
import AddTask from './components/AddTask'
import './App.css'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

function App() {
  const [tasks, setTasks] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchTasks()
  }, [])

  const fetchTasks = async () => {
    try {
      setLoading(true)
      setError(null)
      const response = await fetch(`${API_URL}/tasks`)
      const result = await response.json()
      
      if (result.success) {
        setTasks(result.data || [])
      } else {
        setError(result.error || 'Failed to fetch tasks')
      }
    } catch (err) {
      console.error('Error fetching tasks:', err)
      setError('Failed to connect to API. Please check your API URL.')
    } finally {
      setLoading(false)
    }
  }

  const handleAddTask = async (title, description) => {
    try {
      const response = await fetch(`${API_URL}/tasks`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ title, description }),
      })

      const result = await response.json()

      if (result.success) {
        setTasks([...tasks, result.data])
        return true
      } else {
        setError(result.error || 'Failed to create task')
        return false
      }
    } catch (err) {
      console.error('Error creating task:', err)
      setError('Failed to create task')
      return false
    }
  }

  const handleUpdateTask = async (taskId, updates) => {
    try {
      const response = await fetch(`${API_URL}/tasks/${taskId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(updates),
      })

      const result = await response.json()

      if (result.success) {
        setTasks(tasks.map(task => 
          task.taskId === taskId ? result.data : task
        ))
        return true
      } else {
        setError(result.error || 'Failed to update task')
        return false
      }
    } catch (err) {
      console.error('Error updating task:', err)
      setError('Failed to update task')
      return false
    }
  }

  const handleDeleteTask = async (taskId) => {
    try {
      const response = await fetch(`${API_URL}/tasks/${taskId}`, {
        method: 'DELETE',
      })

      const result = await response.json()

      if (result.success) {
        setTasks(tasks.filter(task => task.taskId !== taskId))
        return true
      } else {
        setError(result.error || 'Failed to delete task')
        return false
      }
    } catch (err) {
      console.error('Error deleting task:', err)
      setError('Failed to delete task')
      return false
    }
  }

  return (
    <div className="app">
      <header className="app-header">
        <h1>🚀 Serverless TODO App</h1>
        <p className="subtitle">Built with AWS Lambda, API Gateway, DynamoDB & React</p>
      </header>

      {error && (
        <div className="error-banner">
          <span>{error}</span>
          <button onClick={() => setError(null)}>×</button>
        </div>
      )}

      <AddTask onAdd={handleAddTask} />

      {loading ? (
        <div className="loading">Loading tasks...</div>
      ) : (
        <TaskList
          tasks={tasks}
          onUpdate={handleUpdateTask}
          onDelete={handleDeleteTask}
        />
      )}

      <footer className="app-footer">
        <p>API URL: {API_URL}</p>
      </footer>
    </div>
  )
}

export default App

