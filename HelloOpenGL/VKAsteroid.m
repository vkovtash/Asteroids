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
    self = [self initWithRadius:ASTEROID_SIZE];
    return self;
}

- (id) initWithRadius:(float) radius{
    self = [super init];
    if (self) {
        self.radius = radius;
        Vertex vertices[4] = {
            {{-self.radius, -self.radius, 0}},
            {{0, self.radius, 0}},
            {{self.radius, -self.radius, 0}},
            {{0, -self.radius/2, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 Vertices:vertices];
        [self setIndexBuffer:6 Indices:indices];
    }
    return self;
}
@end
