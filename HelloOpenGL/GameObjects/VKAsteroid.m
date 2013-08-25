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
        Vertex vertices[] = {
            {{0, self.radius, 0}},
            {{-self.radius/2, self.radius/2, 0}},
            {{-self.radius, 0, 0}},
            {{-self.radius/2, -self.radius/2, 0}},
            {{0, -self.radius, 0}},
            {{self.radius/2, -self.radius/2, 0}},
            {{self.radius, 0, 0}},
            {{self.radius/2, self.radius/2, 0}}
        };
        
        GLubyte indices[] = {1, 2, 3, 4, 5, 6, 7, 0, 1};
        
        [self setVertexBuffer:8 Vertices:vertices];
        [self setIndexBuffer:9 Indices:indices];
    }
    return self;
}
@end
