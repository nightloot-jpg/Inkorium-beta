import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'

type GroupProps = {
  group: any
  memberStatus?: 'pending' | 'accepted' | 'banned' | null
  isAdmin?: boolean
}

export function GroupHeader({ group, memberStatus, isAdmin }: GroupProps) {
  return (
    <div className="flex flex-col bg-card rounded-lg overflow-hidden border">
      {/* Banner */}
      <div
        className="h-48 w-full bg-muted object-cover bg-center relative"
        style={
          group.banner_url
            ? { backgroundImage: `url(${group.banner_url})` }
            : undefined
        }
      >
        <div className="absolute top-4 right-4 flex gap-2">
          <Badge
            variant="secondary"
            className="backdrop-blur-md bg-background/50"
          >
            {group.privacy_level === 'public'
              ? 'Público'
              : group.privacy_level === 'private'
                ? 'Privado'
                : 'Secreto'}
          </Badge>
          <Badge
            variant="secondary"
            className="backdrop-blur-md bg-background/50"
          >
            {group.category_name || 'Comunidad'}
          </Badge>
        </div>
      </div>

      <div className="flex flex-col md:flex-row px-6 pb-6 relative">
        {/* Avatar */}
        <div className="h-32 w-32 rounded-xl border-4 border-card bg-muted -mt-16 overflow-hidden flex-shrink-0 z-10 shadow-sm">
          {group.avatar_url ? (
            <img
              src={group.avatar_url}
              alt={group.name}
              className="h-full w-full object-cover"
            />
          ) : (
            <div className="h-full w-full bg-zinc-200 flex items-center justify-center text-4xl text-zinc-500 font-bold">
              {group.name?.charAt(0)}
            </div>
          )}
        </div>

        {/* Info & Actions */}
        <div className="mt-4 md:mt-0 md:ml-6 flex-1 flex flex-col md:flex-row md:items-start justify-between">
          <div>
            <h1 className="text-2xl font-bold">{group.name}</h1>
            <p className="text-muted-foreground">/{group.slug}</p>
            {group.description && (
              <p className="mt-2 text-sm max-w-xl">{group.description}</p>
            )}

            <div className="flex gap-4 mt-4 text-sm">
              <div className="flex gap-1">
                <span className="font-bold">{group.member_count}</span>{' '}
                <span className="text-muted-foreground">Miembros</span>
              </div>
            </div>
          </div>

          <div className="mt-4 md:mt-0 flex gap-2">
            {isAdmin ? (
              <Button variant="outline">Administrar Grupo</Button>
            ) : (
              <>
                {memberStatus === 'accepted' ? (
                  <>
                    <Button variant="secondary">Chat del Grupo</Button>
                    <Button variant="outline">Miembro</Button>
                  </>
                ) : memberStatus === 'pending' ? (
                  <Button variant="secondary" disabled>
                    Solicitud Pendiente
                  </Button>
                ) : (
                  <Button>Unirme al Grupo</Button>
                )}
              </>
            )}
          </div>
        </div>
      </div>

      {/* Group Navigation Tabs */}
      <div className="px-6 border-t pt-2">
        <Tabs defaultValue="feed" className="w-full">
          <TabsList className="bg-transparent h-12 w-full justify-start gap-4">
            <TabsTrigger
              value="feed"
              className="data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:shadow-none rounded-none px-4 pb-3 pt-3"
            >
              Feed
            </TabsTrigger>
            <TabsTrigger
              value="about"
              className="data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:shadow-none rounded-none px-4 pb-3 pt-3"
            >
              Información
            </TabsTrigger>
            <TabsTrigger
              value="members"
              className="data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:shadow-none rounded-none px-4 pb-3 pt-3"
            >
              Miembros
            </TabsTrigger>
            <TabsTrigger
              value="events"
              className="data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:shadow-none rounded-none px-4 pb-3 pt-3"
            >
              Eventos
            </TabsTrigger>
          </TabsList>
        </Tabs>
      </div>
    </div>
  )
}
