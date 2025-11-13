'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'
import Link from 'next/link'
import '@/styles/landing.css'

interface Item {
  id: number
  name: string
  description: string
  created_at: string
  updated_at: string
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export default function Dashboard() {
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
    if (!confirm('Are you sure you want to delete this item?')) return
    try {
      await axios.delete(`${API_URL}/api/items/${id}/`)
      fetchItems()
    } catch (err) {
      setError('Failed to delete item')
      console.error(err)
    }
  }

  return (
    <div style={{ minHeight: '100vh', background: '#f5f5f5' }}>
      {/* Navigation */}
      <nav className="nav" style={{ background: 'rgba(102, 126, 234, 0.95)' }}>
        <div className="nav-container">
          <Link href="/" className="logo" style={{ textDecoration: 'none' }}>
            <span className="logo-icon">📚</span>
            <span className="logo-text">Nexus Learn</span>
          </Link>
          <div className="nav-links">
            <Link href="/">Home</Link>
            <Link href="/dashboard" className="nav-button">Dashboard</Link>
          </div>
        </div>
      </nav>

      <main style={{ padding: '2rem', maxWidth: '1200px', margin: '0 auto', paddingTop: '6rem' }}>
        <div style={{ marginBottom: '2rem' }}>
          <h1 style={{ fontSize: '2.5rem', fontWeight: 800, marginBottom: '0.5rem', color: '#1a1a1a' }}>
            Dashboard
          </h1>
          <p style={{ color: '#666', fontSize: '1.125rem' }}>
            Manage your learning items and track your progress
          </p>
        </div>
        
        {/* Status Card */}
        <div style={{ 
          marginBottom: '2rem', 
          padding: '1.5rem', 
          background: 'white', 
          borderRadius: '12px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
        }}>
          <h2 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '1rem', color: '#1a1a1a' }}>
            Backend Status
          </h2>
          <div style={{ display: 'flex', gap: '2rem', flexWrap: 'wrap' }}>
            <div>
              <span style={{ color: '#666' }}>Status: </span>
              <strong style={{ 
                color: healthStatus === 'healthy' ? '#10b981' : '#ef4444',
                textTransform: 'capitalize'
              }}>
                {healthStatus}
              </strong>
            </div>
            <div>
              <span style={{ color: '#666' }}>API URL: </span>
              <code style={{ 
                background: '#f3f4f6', 
                padding: '0.25rem 0.5rem', 
                borderRadius: '4px',
                fontSize: '0.9rem'
              }}>
                {API_URL}
              </code>
            </div>
          </div>
        </div>

        {/* Add Item Form */}
        <div style={{ 
          marginBottom: '2rem', 
          padding: '2rem', 
          background: 'white', 
          borderRadius: '12px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
        }}>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '1rem', color: '#1a1a1a' }}>
            Add New Item
          </h2>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <input
              type="text"
              placeholder="Item name"
              value={newItem.name}
              onChange={(e) => setNewItem({ ...newItem, name: e.target.value })}
              required
              style={{ 
                padding: '0.75rem', 
                borderRadius: '8px', 
                border: '1px solid #e5e7eb',
                fontSize: '1rem'
              }}
            />
            <textarea
              placeholder="Description"
              value={newItem.description}
              onChange={(e) => setNewItem({ ...newItem, description: e.target.value })}
              style={{ 
                padding: '0.75rem', 
                borderRadius: '8px', 
                border: '1px solid #e5e7eb', 
                minHeight: '100px',
                fontSize: '1rem',
                fontFamily: 'inherit'
              }}
            />
            <button
              type="submit"
              className="btn btn-primary"
              style={{ alignSelf: 'flex-start' }}
            >
              Add Item
            </button>
          </form>
        </div>

        {/* Items List */}
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '1rem', color: '#1a1a1a' }}>
            Your Items
          </h2>
          {error && (
            <div style={{ 
              padding: '1rem', 
              background: '#fee2e2', 
              color: '#991b1b', 
              borderRadius: '8px', 
              marginBottom: '1rem',
              border: '1px solid #fecaca'
            }}>
              {error}
            </div>
          )}
          {loading ? (
            <div style={{ 
              padding: '3rem', 
              textAlign: 'center', 
              background: 'white', 
              borderRadius: '12px',
              color: '#666'
            }}>
              Loading...
            </div>
          ) : items.length === 0 ? (
            <div style={{ 
              padding: '3rem', 
              textAlign: 'center', 
              background: 'white', 
              borderRadius: '12px',
              color: '#666'
            }}>
              <p style={{ fontSize: '1.125rem', marginBottom: '0.5rem' }}>No items found.</p>
              <p>Create your first item above!</p>
            </div>
          ) : (
            <div style={{ display: 'grid', gap: '1rem' }}>
              {items.map((item) => (
                <div
                  key={item.id}
                  style={{
                    padding: '1.5rem',
                    border: '1px solid #e5e7eb',
                    borderRadius: '12px',
                    background: 'white',
                    boxShadow: '0 2px 4px rgba(0,0,0,0.05)',
                    transition: 'all 0.3s'
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.1)'
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.boxShadow = '0 2px 4px rgba(0,0,0,0.05)'
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                    <div style={{ flex: 1 }}>
                      <h3 style={{ 
                        marginBottom: '0.5rem', 
                        fontSize: '1.25rem',
                        fontWeight: 700,
                        color: '#1a1a1a'
                      }}>
                        {item.name}
                      </h3>
                      <p style={{ 
                        color: '#666', 
                        marginBottom: '0.75rem',
                        lineHeight: 1.6
                      }}>
                        {item.description}
                      </p>
                      <small style={{ color: '#999', fontSize: '0.875rem' }}>
                        Created: {new Date(item.created_at).toLocaleString()}
                      </small>
                    </div>
                    <button
                      onClick={() => handleDelete(item.id)}
                      style={{
                        padding: '0.5rem 1rem',
                        background: '#ef4444',
                        color: 'white',
                        border: 'none',
                        borderRadius: '8px',
                        cursor: 'pointer',
                        fontWeight: 600,
                        transition: 'all 0.3s'
                      }}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.background = '#dc2626'
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.background = '#ef4444'
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
    </div>
  )
}


