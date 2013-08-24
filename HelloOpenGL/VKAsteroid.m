//
//  VKAsteroid.m
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKAsteroid.h"
#define ASTEROID_SIZE 20

@implementation VKAsteroid
- (id) init{
    self = [super init];
    if (self) {
        Vertex vertices[4] = {
            {{-ASTEROID_SIZE, -ASTEROID_SIZE, 0}},
            {{0, ASTEROID_SIZE, 0}},
            {{ASTEROID_SIZE, -ASTEROID_SIZE, 0}},
            {{0, -ASTEROID_SIZE/2, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 Vertices:vertices];
        [self setIndexBuffer:6 Indices:indices];
    }
    return self;
}
@end
