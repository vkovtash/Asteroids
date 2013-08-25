//
//  VKMissle.m
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKMissle.h"
#define MISSLE_SIZE 5

@implementation VKMissle
- (id) init{
    self = [super init];
    if (self) {
        Vertex vertices[4] = {
            {{-MISSLE_SIZE, -MISSLE_SIZE, 0}},
            {{0, MISSLE_SIZE, 0}},
            {{MISSLE_SIZE, -MISSLE_SIZE, 0}},
            {{0, -MISSLE_SIZE/2, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 Vertices:vertices];
        [self setIndexBuffer:6 Indices:indices];
    }
    return self;
}
@end
