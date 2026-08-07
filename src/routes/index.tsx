import { createFileRoute } from '@tanstack/react-router'
import { Feed } from '@/features/feed/components/Feed'

export const Route = createFileRoute('/')({
  component: Home,
})

function Home() {
  return (
    <div className="container mx-auto p-4 min-h-screen bg-zinc-50 dark:bg-zinc-950">
      <Feed />
    </div>
  )
}
