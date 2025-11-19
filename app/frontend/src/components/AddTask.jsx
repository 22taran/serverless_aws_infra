import React, { useState } from 'react'
import './AddTask.css'

function AddTask({ onAdd }) {
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    
    if (!title.trim()) {
      return
    }

    setIsSubmitting(true)
    const success = await onAdd(title.trim(), description.trim())
    
    if (success) {
      setTitle('')
      setDescription('')
    }
    
    setIsSubmitting(false)
  }

  return (
    <div className="add-task-container">
      <form onSubmit={handleSubmit} className="add-task-form">
        <div className="form-group">
          <input
            type="text"
            placeholder="Enter task title..."
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="task-input"
            disabled={isSubmitting}
            required
          />
        </div>
        <div className="form-group">
          <textarea
            placeholder="Enter task description (optional)..."
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="task-textarea"
            disabled={isSubmitting}
            rows="3"
          />
        </div>
        <button
          type="submit"
          className="add-button"
          disabled={isSubmitting || !title.trim()}
        >
          {isSubmitting ? 'Adding...' : '+ Add Task'}
        </button>
      </form>
    </div>
  )
}

export default AddTask

