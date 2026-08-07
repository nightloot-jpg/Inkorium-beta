import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Heart, MessageCircle, Share2, MoreHorizontal } from 'lucide-react'

// Mapearemos este type cuando tengamos los verdaderos tipos generados desde supabase
type PostCardProps = {
  post: any
}

export function PostCard({ post }: PostCardProps) {
  // Manejo defensivo en caso de que author sea null en un mock o BD sin relacion aun
  const author = post.author || {
    full_name: 'Usuario',
    username: 'usuario',
    avatar_url: null,
  }

  return (
    <Card className="mb-4">
      <CardHeader className="flex flex-row items-center justify-between pb-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-muted overflow-hidden">
            {author.avatar_url ? (
              <img
                src={author.avatar_url}
                alt={author.username}
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full bg-zinc-200 flex items-center justify-center text-zinc-500 font-bold">
                {author.full_name?.charAt(0)}
              </div>
            )}
          </div>
          <div>
            <p className="font-semibold">{author.full_name}</p>
            <p className="text-xs text-muted-foreground">hace 2 horas</p>
          </div>
        </div>
        <Button variant="ghost" size="icon" className="h-8 w-8">
          <MoreHorizontal className="h-5 w-5" />
        </Button>
      </CardHeader>

      <CardContent>
        {post.content && <p className="whitespace-pre-wrap">{post.content}</p>}

        {/* Aquí renderizaríamos iterando sobre post_images si existieran */}
        {post.images && post.images.length > 0 && (
          <div className="mt-4 rounded-md overflow-hidden border">
            <img
              src={post.images[0].storage_path}
              alt="Post content"
              className="w-full h-auto object-cover"
            />
          </div>
        )}
      </CardContent>

      <CardFooter className="flex justify-between border-t pt-3">
        <Button variant="ghost" size="sm" className="gap-2">
          <Heart className="h-4 w-4" />{' '}
          <span className="hidden sm:inline">Me gusta</span>{' '}
          {post.likes_count > 0 && `(${post.likes_count})`}
        </Button>
        <Button variant="ghost" size="sm" className="gap-2">
          <MessageCircle className="h-4 w-4" />{' '}
          <span className="hidden sm:inline">Comentar</span>
        </Button>
        <Button variant="ghost" size="sm" className="gap-2">
          <Share2 className="h-4 w-4" />{' '}
          <span className="hidden sm:inline">Compartir</span>
        </Button>
      </CardFooter>
    </Card>
  )
}
