//
//  VKStarsArray.m
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKStarsArray.h"

#define STAR_SIZE 5

@implementation VKStarsArray

- (id) init {
    self = [self initWithRadius:STAR_SIZE];
    return self;
}

- (id) initWithRadius:(float)radius {
    self = [super init];
    if (self) {
        _radius = radius;
        Vertex vertices[] = {
            {{0, radius, 0}},
            {{radius, 0, 0}},
            {{0, -radius, 0}},
            {{-radius, 0, 0}}
        };
        
        GLubyte indices[] = {0, 1, 2, 2, 3, 0};
        
        self.style = GL_TRIANGLES;
        [self setVertexBuffer:4 vertices:vertices];
        [self setIndexBuffer:6 indices:indices];
    }
    return self;
}

@end
