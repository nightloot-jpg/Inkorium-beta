import { createFileRoute } from '@tanstack/react-router'
import { ProfileHeader } from '@/features/profile/components/ProfileHeader'

export const Route = createFileRoute('/$username')({
  component: RouteComponent,
})

function RouteComponent() {
  const { username } = Route.useParams()

  // En la implementación real usaríamos TanStack Query para obtener los datos
  // basados en el username desde Supabase.
  const mockProfile = {
    username,
    full_name: 'Usuario de Prueba',
    bio: 'Hola, esta es mi biografía al estilo Tuenti.',
  }

  return (
    <div className="container mx-auto p-4 max-w-4xl">
      <ProfileHeader
        profile={mockProfile}
        isOwnProfile={false}
        friendshipStatus={null}
        isFollowing={false}
      />
    </div>
  )
}
