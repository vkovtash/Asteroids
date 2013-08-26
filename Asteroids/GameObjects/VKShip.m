//
//  VKShip.m
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKShip.h"
#define SHIP_SIZE 10

@implementation VKShip
- (id) init{
    self = [self initWithRadius:SHIP_SIZE];
    return self;
}

- (id) initWithRadius:(float) radius{
    self = [super init];
    if (self) {
        _radius = radius;
        Vertex vertices[4] = {
            {{-radius, -radius, 0}},
            {{0, radius, 0}},
            {{radius, -radius, 0}},
            {{0, -radius/2, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 Vertices:vertices];
        [self setIndexBuffer:6 Indices:indices];
    }
    return self;
}
@end
