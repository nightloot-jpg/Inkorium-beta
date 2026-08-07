import { createFileRoute } from '@tanstack/react-router'
import { ChatLayout } from '@/features/chat/components/ChatLayout'

export const Route = createFileRoute('/chat')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div className="container mx-auto p-4 max-w-6xl">
      <ChatLayout />
    </div>
  )
}
