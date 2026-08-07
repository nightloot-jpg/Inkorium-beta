import { createFileRoute } from '@tanstack/react-router'
import { GroupHeader } from '@/features/groups/components/GroupHeader'

export const Route = createFileRoute('/groups/$slug')({
  component: RouteComponent,
})

function RouteComponent() {
  const { slug } = Route.useParams()

  const mockGroup = {
    name: 'Desarrolladores React',
    slug: slug,
    description:
      'Comunidad para hablar sobre React, TanStack y desarrollo frontend moderno.',
    privacy_level: 'public',
    category_name: 'Tecnología',
    member_count: 1250,
  }

  return (
    <div className="container mx-auto p-4 max-w-5xl space-y-6">
      <GroupHeader group={mockGroup} memberStatus="accepted" isAdmin={false} />

      {/* Aquí iría el componente Feed pasándole group_id */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
        <div className="md:col-span-2">
          <div className="p-12 text-center text-muted-foreground border rounded-lg bg-card">
            Feed del grupo (Reutilizando PostCard con post.group_id)
          </div>
        </div>
        <div className="md:col-span-1 space-y-4">
          <div className="p-4 border rounded-lg bg-card">
            <h3 className="font-semibold mb-2">Acerca del grupo</h3>
            <p className="text-sm text-muted-foreground">
              {mockGroup.description}
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
