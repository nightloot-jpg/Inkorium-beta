import { Button } from '@/components/ui/button'

type ProfileProps = {
  profile: any
  isOwnProfile: boolean
  friendshipStatus?: 'pending' | 'accepted' | 'rejected' | null
  isFollowing?: boolean
}

export function ProfileHeader({
  profile,
  isOwnProfile,
  friendshipStatus,
  isFollowing,
}: ProfileProps) {
  return (
    <div className="flex flex-col bg-card rounded-lg overflow-hidden border">
      {/* Banner */}
      <div
        className="h-48 w-full bg-muted object-cover bg-center"
        style={{
          backgroundImage: profile.banner_url
            ? `url(${profile.banner_url})`
            : undefined,
        }}
      />

      <div className="flex flex-col md:flex-row px-6 pb-6 relative">
        {/* Avatar */}
        <div className="h-32 w-32 rounded-full border-4 border-card bg-muted -mt-16 overflow-hidden flex-shrink-0 z-10">
          {profile.avatar_url ? (
            <img
              src={profile.avatar_url}
              alt={profile.full_name}
              className="h-full w-full object-cover"
            />
          ) : (
            <div className="h-full w-full bg-zinc-200 flex items-center justify-center text-4xl text-zinc-500">
              {profile.full_name?.charAt(0) ||
                profile.username?.charAt(0) ||
                '?'}
            </div>
          )}
        </div>

        {/* Info & Actions */}
        <div className="mt-4 md:mt-0 md:ml-6 flex-1 flex flex-col md:flex-row md:items-start justify-between">
          <div>
            <h1 className="text-2xl font-bold">
              {profile.full_name || profile.username}
            </h1>
            <p className="text-muted-foreground">@{profile.username}</p>
            {profile.bio && <p className="mt-2 text-sm">{profile.bio}</p>}

            <div className="flex gap-4 mt-4 text-sm">
              <div className="flex gap-1">
                <span className="font-bold">120</span>{' '}
                <span className="text-muted-foreground">Amigos</span>
              </div>
              <div className="flex gap-1">
                <span className="font-bold">45K</span>{' '}
                <span className="text-muted-foreground">Seguidores</span>
              </div>
            </div>
          </div>

          <div className="mt-4 md:mt-0 flex gap-2">
            {isOwnProfile ? (
              <Button variant="outline">Editar Perfil</Button>
            ) : (
              <>
                {/* Friend logic */}
                {friendshipStatus === 'accepted' ? (
                  <Button variant="secondary">Amigos</Button>
                ) : friendshipStatus === 'pending' ? (
                  <Button variant="secondary" disabled>
                    Solicitud Enviada
                  </Button>
                ) : (
                  <Button>Añadir a mis amigos</Button>
                )}

                {/* Follow logic */}
                <Button variant={isFollowing ? 'secondary' : 'outline'}>
                  {isFollowing ? 'Siguiendo' : 'Seguir'}
                </Button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
