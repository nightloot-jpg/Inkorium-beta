import { PostCard } from './PostCard'

export function Feed() {
  const mockPosts = [
    {
      id: '1',
      content:
        '¡Añadiendo el sistema de feed y arquitectura relacional completa a Inkorium! 🚀',
      visibility: 'public',
      author: {
        full_name: 'Jules AI',
        username: 'jules',
      },
      likes_count: 42,
    },
    {
      id: '2',
      content: 'Hoy salimos a tomar algo, ¡apuntaos! 🍻',
      visibility: 'friends_only',
      author: {
        full_name: 'María García',
        username: 'mariag',
      },
      likes_count: 5,
    },
  ]

  return (
    <div className="w-full max-w-2xl mx-auto py-6">
      {/* Create Post Input would go here */}
      <div className="mb-6 p-4 bg-card rounded-lg border shadow-sm">
        <p className="text-muted-foreground">¿Qué estás pensando?</p>
      </div>

      <div className="flex flex-col gap-2">
        {mockPosts.map((post) => (
          <PostCard key={post.id} post={post} />
        ))}
      </div>
    </div>
  )
}
