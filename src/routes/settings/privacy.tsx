import { createFileRoute } from '@tanstack/react-router'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Button } from '@/components/ui/button'

export const Route = createFileRoute('/settings/privacy')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div className="container mx-auto p-4 max-w-2xl py-8">
      <h1 className="text-3xl font-bold mb-6">Configuración de Privacidad</h1>

      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Visibilidad del Perfil</CardTitle>
            <CardDescription>
              Controla quién puede ver tu perfil completo.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <select className="w-full p-2 border rounded-md bg-background">
              <option value="public">Público (Todos)</option>
              <option value="friends">Solo Amigos</option>
              <option value="private">Privado (Nadie)</option>
            </select>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Interacciones</CardTitle>
            <CardDescription>
              Quién puede interactuar contigo en la plataforma.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium">
                Enviarme solicitudes de amistad
              </span>
              <select className="p-2 border rounded-md bg-background text-sm">
                <option value="everyone">Todos</option>
                <option value="nobody">Nadie</option>
              </select>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium">
                Enviarme mensajes privados
              </span>
              <select className="p-2 border rounded-md bg-background text-sm">
                <option value="everyone">Todos</option>
                <option value="friends">Solo Amigos</option>
                <option value="nobody">Nadie</option>
              </select>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-red-500">Usuarios Bloqueados</CardTitle>
            <CardDescription>
              Gestiona las personas que has bloqueado.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="text-sm text-muted-foreground mb-4">
              No tienes ningún usuario bloqueado actualmente.
            </div>
            <Button variant="outline" className="w-full">
              Añadir usuario a la lista negra
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
