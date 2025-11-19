import React, { useState } from 'react'
import './TaskList.css'

function TaskList({ tasks, onUpdate, onDelete }) {
  const [editingId, setEditingId] = useState(null)
  const [editTitle, setEditTitle] = useState('')
  const [editDescription, setEditDescription] = useState('')

  const handleEdit = (task) => {
    setEditingId(task.taskId)
    setEditTitle(task.title)
    setEditDescription(task.description || '')
  }

  const handleSave = async (taskId) => {
    const updates = {
      title: editTitle.trim(),
      description: editDescription.trim(),
    }

    if (!updates.title) {
      return
    }

    const success = await onUpdate(taskId, updates)
    if (success) {
      setEditingId(null)
      setEditTitle('')
      setEditDescription('')
    }
  }

  const handleCancel = () => {
    setEditingId(null)
    setEditTitle('')
    setEditDescription('')
  }

  const handleToggleComplete = async (task) => {
    await onUpdate(task.taskId, { completed: !task.completed })
  }

  if (tasks.length === 0) {
    return (
      <div className="task-list-container">
        <div className="empty-state">
          <p>📝 No tasks yet. Add one above to get started!</p>
        </div>
      </div>
    )
  }

  return (
    <div className="task-list-container">
      <h2 className="task-list-header">Your Tasks ({tasks.length})</h2>
      <div className="tasks">
        {tasks.map((task) => (
          <div
            key={task.taskId}
            className={`task-item ${task.completed ? 'completed' : ''}`}
          >
            {editingId === task.taskId ? (
              <div className="task-edit-form">
                <input
                  type="text"
                  value={editTitle}
                  onChange={(e) => setEditTitle(e.target.value)}
                  className="edit-input"
                  placeholder="Task title"
                />
                <textarea
                  value={editDescription}
                  onChange={(e) => setEditDescription(e.target.value)}
                  className="edit-textarea"
                  placeholder="Task description"
                  rows="2"
                />
                <div className="edit-actions">
                  <button
                    onClick={() => handleSave(task.taskId)}
                    className="save-button"
                    disabled={!editTitle.trim()}
                  >
                    Save
                  </button>
                  <button
                    onClick={handleCancel}
                    className="cancel-button"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            ) : (
              <>
                <div className="task-content">
                  <div className="task-header">
                    <input
                      type="checkbox"
                      checked={task.completed || false}
                      onChange={() => handleToggleComplete(task)}
                      className="task-checkbox"
                    />
                    <h3 className="task-title">{task.title}</h3>
                  </div>
                  {task.description && (
                    <p className="task-description">{task.description}</p>
                  )}
                  <div className="task-meta">
                    <span className="task-date">
                      Created: {new Date(task.createdAt).toLocaleDateString()}
                    </span>
                  </div>
                </div>
                <div className="task-actions">
                  <button
                    onClick={() => handleEdit(task)}
                    className="edit-button"
                    title="Edit task"
                  >
                    ✏️
                  </button>
                  <button
                    onClick={() => onDelete(task.taskId)}
                    className="delete-button"
                    title="Delete task"
                  >
                    🗑️
                  </button>
                </div>
              </>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}

export default TaskList

