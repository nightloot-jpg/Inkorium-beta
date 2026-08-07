import { createRootRoute, Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/router-devtools'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { useState, useEffect } from 'react'
import '../styles.css'

export const Route = createRootRoute({
  component: RootComponent,
})

function RootComponent() {
  // Dark mode logic (simple)
  const [isDark, setIsDark] = useState(false)

  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }, [isDark])

  return (
    <>
      {/* Navbar simplificada para navegación general */}
      <nav className="border-b bg-background sticky top-0 z-50">
        <div className="container mx-auto p-4 flex justify-between items-center">
          <a href="/" className="font-bold text-xl tracking-tighter">
            Inkorium
          </a>
          <div className="flex items-center gap-4 text-sm font-medium text-muted-foreground">
            <a href="/" className="hover:text-foreground">
              Feed
            </a>
            <a href="/chat" className="hover:text-foreground">
              Chat
            </a>
            <a href="/admin" className="hover:text-foreground">
              Admin
            </a>
            <a href="/settings/privacy" className="hover:text-foreground">
              Ajustes
            </a>
            <button
              onClick={() => setIsDark(!isDark)}
              className="p-1 rounded-full hover:bg-muted"
            >
              {isDark ? '☀️' : '🌙'}
            </button>
          </div>
        </div>
      </nav>

      <Outlet />

      {import.meta.env.DEV && (
        <>
          <TanStackRouterDevtools position="bottom-right" />
          <ReactQueryDevtools buttonPosition="bottom-left" />
        </>
      )}
    </>
  )
}
