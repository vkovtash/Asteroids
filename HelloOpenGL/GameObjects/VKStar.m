//
//  VKStar.m
//  Asteroids
//
//  Created by kovtash on 26.08.13.
//
//

#import "VKStar.h"

#define STAR_SIZE 5

@interface VKStar(){
    Vertex *vertices;
    GLubyte *indices;
}
@end

@implementation VKStar
- (id) init{
    self = [self initWithRadius:STAR_SIZE];
    return self;
}

- (id) initWithRadius:(float) radius{
    self = [super init];
    if (self) {
        _radius = radius;
        int sides = 4;
        float step = 2 * M_PI / sides;
        
        vertices = malloc(sizeof(Vertex)*sides);
        indices = malloc(sizeof(GLubyte)*sides + 1);
        
        for(int i = 0; i < sides; i++)
        {
            vertices[i] = (Vertex){
                cos(i * step) * radius,
                sin(i * step) * radius, 0};
            indices[i] = i;
        }
        indices[sides] = 0;
        
        self.style = GL_TRIANGLES;
        [self setVertexBuffer:sides Vertices:vertices];
        [self setIndexBuffer:sides + 1 Indices:indices];
    }
    return self;
}

- (void) dealloc{
    free(vertices);
    free(indices);
}

@end
