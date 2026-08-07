import { ScrollArea } from '@/components/ui/scroll-area'

export function ChatLayout() {
  return (
    <div className="flex h-[calc(100vh-4rem)] border rounded-lg overflow-hidden bg-background">
      {/* Sidebar de canales/chats */}
      <div className="w-1/3 border-r flex flex-col">
        <div className="p-4 border-b font-semibold">Mensajes</div>
        <ScrollArea className="flex-1">
          <div className="p-2 space-y-2">
            {[1, 2, 3].map((i) => (
              <div
                key={i}
                className="flex items-center gap-3 p-2 rounded-lg hover:bg-muted cursor-pointer transition-colors"
              >
                <div className="w-10 h-10 rounded-full bg-zinc-200"></div>
                <div className="flex-1 overflow-hidden">
                  <div className="flex justify-between items-center">
                    <p className="font-medium text-sm">Amigo {i}</p>
                    <span className="text-xs text-muted-foreground">12:30</span>
                  </div>
                  <p className="text-xs text-muted-foreground truncate">
                    Último mensaje recibido por aquí...
                  </p>
                </div>
              </div>
            ))}
          </div>
        </ScrollArea>
      </div>

      {/* Área principal del chat */}
      <div className="flex-1 flex flex-col">
        <div className="p-4 border-b flex items-center gap-3 shadow-sm z-10">
          <div className="w-8 h-8 rounded-full bg-zinc-200"></div>
          <span className="font-semibold">Amigo 1</span>
        </div>

        <ScrollArea className="flex-1 p-4">
          <div className="space-y-4">
            {/* Simulación de mensajes (izquierda = otro, derecha = yo) */}
            <div className="flex justify-start">
              <div className="bg-muted p-3 rounded-lg rounded-tl-none max-w-[70%]">
                <p className="text-sm">¡Hola! ¿Qué tal estás?</p>
                <span className="text-[10px] text-muted-foreground mt-1 block">
                  12:28
                </span>
              </div>
            </div>
            <div className="flex justify-end">
              <div className="bg-primary text-primary-foreground p-3 rounded-lg rounded-tr-none max-w-[70%]">
                <p className="text-sm">
                  ¡Todo bien! Implementando el chat en tiempo real 🚀
                </p>
                <span className="text-[10px] text-primary-foreground/70 mt-1 block">
                  12:30
                </span>
              </div>
            </div>
          </div>
        </ScrollArea>

        <div className="p-4 border-t">
          <div className="flex gap-2">
            <input
              type="text"
              placeholder="Escribe un mensaje..."
              className="flex-1 bg-muted rounded-full px-4 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20"
            />
            <button className="bg-primary text-primary-foreground p-2 rounded-full w-10 h-10 flex items-center justify-center">
              →
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
