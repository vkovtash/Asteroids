//
//  VKGameReusableObjectsArray.m
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKGameReusableObjectsArray.h"
#import <objc/runtime.h>


@interface VKGameReusableObjectProperties()

@end

@implementation VKGameReusableObjectProperties

@end


@interface VKGameReusableBuffers : NSObject
@property (readonly) GLuint vertexBuffer;
@property (readonly) GLuint indexBuffer;
@property (readonly) int indicesCount;

- (void) setVertexBuffer:(int)verticesCount vertices:(Vertex *)vertices;
- (void) setIndexBuffer:(int)indicesCount indices:(GLubyte *)indices;
@end

@implementation VKGameReusableBuffers
@synthesize vertexBuffer = _vertexBuffer;
@synthesize indexBuffer = _indexBuffer;
@synthesize indicesCount = _indicesCount;

- (instancetype) init {
    self = [super init];
    if (self) {
        glGenBuffers(1, &_vertexBuffer);
        glGenBuffers(1, &_indexBuffer);
    }
    return self;
}

- (void) setVertexBuffer:(int)verticesCount vertices:(Vertex *)vertices {
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, verticesCount*sizeof(Vertex), vertices, GL_STATIC_DRAW);
}

- (void) setIndexBuffer:(int)indicesCount indices:(GLubyte *)indices {
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesCount*sizeof(GLubyte), indices, GL_STATIC_DRAW);
    _indicesCount = indicesCount;
}

@end

@interface VKGameReusableObjectProperties(AssociatedBuffers)
@property (readonly, nonatomic) VKGameReusableBuffers *associatedBuffers;

- (void) associateBuffers:(VKGameReusableBuffers *)buffers;
@end

@implementation VKGameReusableObjectProperties(AssociatedBuffers)

- (VKGameReusableBuffers *) associatedBuffers {
    return objc_getAssociatedObject(self, @selector(associatedBuffers));
}

- (void) associateBuffers:(VKGameReusableBuffers *)buffers {
    if (!buffers) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(associatedBuffers), buffers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.verticiesCount > 0) {
        [buffers setVertexBuffer:self.verticiesCount vertices:self.verticies];
    }
    if (self.indicesCount > 0) {
        [buffers setIndexBuffer:self.indicesCount indices:self.indices];
    }
}
@end


@interface VKGameReusableObjectsArray()
@property (strong, nonatomic) NSMutableSet *freeBuffers;
@end

@implementation VKGameReusableObjectsArray

- (instancetype) init {
    self = [super init];
    if (self) {
        _freeBuffers = [NSMutableSet set];
    }
    return self;
}

- (VKGameReusableBuffers *) getReusableBuffers {
    VKGameReusableBuffers *buffers = [self.freeBuffers anyObject];
    
    if (buffers) {
        [self.freeBuffers removeObject:buffers];
    }
    else {
        buffers = [VKGameReusableBuffers new];
    }
    return buffers;
}

- (void) appendObjectProperties:(VKGameReusableObjectProperties *)properties {
    if (!properties) {
        return;
    }
    
    [super appendObjectProperties:properties];
    [properties associateBuffers:[self getReusableBuffers]];
}

- (void) removeObjectProperties:(VKGameReusableObjectProperties *)properties {
    if (!properties) {
        return;
    }
    
    [super removeObjectProperties:properties];
    
    VKGameReusableBuffers *buffers = [properties associatedBuffers];
    if (buffers) {
        [self.freeBuffers addObject:buffers];
    }
}

- (void) removeAllObjects {
    NSArray *objects = [self.objectsProperties copy];
    [super removeAllObjects];
    
    VKGameReusableBuffers *buffers = nil;
    for (VKGameReusableObjectProperties *properties in objects) {
        buffers = properties.associatedBuffers;
        if (buffers) {
            [self.freeBuffers addObject:buffers];
        }
    }
}

@end
