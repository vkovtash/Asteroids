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
    self = [super init];
    if (self) {
        Vertex vertices[4] = {
            {{-SHIP_SIZE, -SHIP_SIZE, 0}},
            {{0, SHIP_SIZE, 0}},
            {{SHIP_SIZE, -SHIP_SIZE, 0}},
            {{0, -SHIP_SIZE/2, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 Vertices:vertices];
        [self setIndexBuffer:6 Indices:indices];
    }
    return self;
}
@end
