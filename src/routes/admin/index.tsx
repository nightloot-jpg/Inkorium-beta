import { createFileRoute } from '@tanstack/react-router'
import { AdminLayout } from '@/features/admin/components/AdminLayout'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export const Route = createFileRoute('/admin/')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <AdminLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
          <p className="text-muted-foreground">
            Resumen del estado de Inkorium.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm text-muted-foreground">
                Usuarios Totales
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">12,450</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm text-muted-foreground">
                Usuarios Activos (24h)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">3,210</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm text-muted-foreground">
                Reportes Pendientes
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold text-red-500">12</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm text-muted-foreground">
                Espacio Storage
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">45.2 GB</p>
            </CardContent>
          </Card>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
          <Card className="col-span-1">
            <CardHeader>
              <CardTitle>Últimos Logs de Auditoría</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4 text-sm">
                <div className="flex justify-between border-b pb-2">
                  <span>
                    Admin <strong>jules</strong> suspendió al usuario{' '}
                    <strong>troll99</strong>
                  </span>
                  <span className="text-muted-foreground text-xs">
                    hace 5 min
                  </span>
                </div>
                <div className="flex justify-between border-b pb-2">
                  <span>
                    Admin <strong>maria</strong> eliminó el post{' '}
                    <strong>#A8F2...</strong>
                  </span>
                  <span className="text-muted-foreground text-xs">
                    hace 1 hora
                  </span>
                </div>
                <div className="flex justify-between pb-2">
                  <span>
                    Sistema asignó rol <strong>Moderador</strong> a{' '}
                    <strong>carlos_dev</strong>
                  </span>
                  <span className="text-muted-foreground text-xs">
                    hace 3 horas
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </AdminLayout>
  )
}
