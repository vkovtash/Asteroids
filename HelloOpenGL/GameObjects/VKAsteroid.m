//
//  VKAsteroid.m
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKAsteroid.h"
#define ASTEROID_SIZE 20

@interface VKAsteroid(){
    Vertex *vertices;
    GLubyte *indices;
}
@end

@implementation VKAsteroid
- (id) init{
    self = [self initWithRadius:ASTEROID_SIZE];
    return self;
}

- (id) initWithRadius:(float) radius{
    self = [super init];
    if (self) {
        _radius = radius;
        int sides = 6 + arc4random_uniform(6);
        float step = 2 * M_PI / sides;
        
        vertices = malloc(sizeof(Vertex)*sides);
        indices = malloc(sizeof(GLubyte)*sides + 1);
            
        for(int i = 0; i < sides; i++)
        {
            vertices[i] = (Vertex){
                cos(i * step) * radius * ((float)arc4random_uniform(10)/20 + 0.5),
                sin(i * step) * radius * ((float)arc4random_uniform(10)/20 + 0.5), 0};
            indices[i] = i;
        }
        indices[sides] = 0;
        
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
