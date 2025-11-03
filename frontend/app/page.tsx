'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'

interface Item {
  id: number
  name: string
  description: string
  created_at: string
  updated_at: string
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export default function Home() {
  const [items, setItems] = useState<Item[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [healthStatus, setHealthStatus] = useState<string>('checking')
  const [newItem, setNewItem] = useState({ name: '', description: '' })

  useEffect(() => {
    checkHealth()
    fetchItems()
  }, [])

  const checkHealth = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/health/`)
      setHealthStatus(response.data.status === 'ok' ? 'healthy' : 'unhealthy')
    } catch (err) {
      setHealthStatus('unhealthy')
    }
  }

  const fetchItems = async () => {
    try {
      setLoading(true)
      const response = await axios.get(`${API_URL}/api/items/`)
      setItems(response.data.results || response.data)
      setError(null)
    } catch (err) {
      setError('Failed to fetch items. Make sure the backend is running.')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      await axios.post(`${API_URL}/api/items/`, newItem)
      setNewItem({ name: '', description: '' })
      fetchItems()
    } catch (err) {
      setError('Failed to create item')
      console.error(err)
    }
  }

  const handleDelete = async (id: number) => {
    try {
      await axios.delete(`${API_URL}/api/items/${id}/`)
      fetchItems()
    } catch (err) {
      setError('Failed to delete item')
      console.error(err)
    }
  }

  return (
    <main style={{ padding: '2rem', maxWidth: '1200px', margin: '0 auto' }}>
      <h1 style={{ marginBottom: '1rem' }}>Nexus Learn</h1>
      
      <div style={{ marginBottom: '2rem', padding: '1rem', background: '#f0f0f0', borderRadius: '8px' }}>
        <h2>Backend Status</h2>
        <p>
          Status: <strong>{healthStatus}</strong>
        </p>
        <p>
          API URL: <code>{API_URL}</code>
        </p>
      </div>

      <div style={{ marginBottom: '2rem' }}>
        <h2>Add New Item</h2>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem', maxWidth: '400px' }}>
          <input
            type="text"
            placeholder="Item name"
            value={newItem.name}
            onChange={(e) => setNewItem({ ...newItem, name: e.target.value })}
            required
            style={{ padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }}
          />
          <textarea
            placeholder="Description"
            value={newItem.description}
            onChange={(e) => setNewItem({ ...newItem, description: e.target.value })}
            style={{ padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc', minHeight: '100px' }}
          />
          <button
            type="submit"
            style={{ padding: '0.5rem 1rem', background: '#0070f3', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}
          >
            Add Item
          </button>
        </form>
      </div>

      <div>
        <h2>Items</h2>
        {error && (
          <div style={{ padding: '1rem', background: '#ffebee', color: '#c62828', borderRadius: '4px', marginBottom: '1rem' }}>
            {error}
          </div>
        )}
        {loading ? (
          <p>Loading...</p>
        ) : items.length === 0 ? (
          <p>No items found. Create one above!</p>
        ) : (
          <div style={{ display: 'grid', gap: '1rem' }}>
            {items.map((item) => (
              <div
                key={item.id}
                style={{
                  padding: '1rem',
                  border: '1px solid #ddd',
                  borderRadius: '8px',
                  background: 'white',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                  <div>
                    <h3 style={{ marginBottom: '0.5rem' }}>{item.name}</h3>
                    <p style={{ color: '#666', marginBottom: '0.5rem' }}>{item.description}</p>
                    <small style={{ color: '#999' }}>
                      Created: {new Date(item.created_at).toLocaleString()}
                    </small>
                  </div>
                  <button
                    onClick={() => handleDelete(item.id)}
                    style={{
                      padding: '0.25rem 0.5rem',
                      background: '#f44336',
                      color: 'white',
                      border: 'none',
                      borderRadius: '4px',
                      cursor: 'pointer',
                    }}
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  )
}

