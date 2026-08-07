import { ScrollArea } from '@/components/ui/scroll-area'
import { Button } from '@/components/ui/button'

export function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-screen border-t bg-background">
      {/* Sidebar Admin */}
      <div className="w-64 border-r flex flex-col bg-muted/30">
        <div className="p-6 border-b">
          <h2 className="font-bold tracking-tight">Panel de Control</h2>
          <p className="text-xs text-muted-foreground mt-1">Super Admin</p>
        </div>
        <ScrollArea className="flex-1">
          <div className="p-4 space-y-1">
            <Button variant="secondary" className="w-full justify-start">
              Dashboard
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Usuarios
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Grupos & Eventos
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Contenido
            </Button>

            <div className="pt-4 pb-2">
              <p className="text-xs font-semibold text-muted-foreground px-4 uppercase tracking-wider">
                Moderación
              </p>
            </div>
            <Button variant="ghost" className="w-full justify-start relative">
              Reportes
              <span className="absolute right-4 bg-red-500 text-white text-[10px] px-2 py-0.5 rounded-full">
                12
              </span>
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Auditoría (Logs)
            </Button>

            <div className="pt-4 pb-2">
              <p className="text-xs font-semibold text-muted-foreground px-4 uppercase tracking-wider">
                Sistema
              </p>
            </div>
            <Button variant="ghost" className="w-full justify-start">
              Roles y Permisos
            </Button>
            <Button variant="ghost" className="w-full justify-start">
              Ajustes
            </Button>
          </div>
        </ScrollArea>
      </div>

      {/* Área principal Admin */}
      <div className="flex-1 overflow-auto p-8">{children}</div>
    </div>
  )
}
