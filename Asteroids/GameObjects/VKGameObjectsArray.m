//
//  VKGameReusableObjectsArray.m
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKGameObjectsArray.h"
#import <objc/runtime.h>
#import "VKShader.h"


@interface VKObject()
@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat alpha;
@end

@implementation VKObject
@synthesize color = _color;

- (instancetype) initWithPosition:(CGPoint)position rotation:(CGFloat)rotation {
    self = [super initWithPosition:position rotation:rotation];
    if (self) {
        _red = 1.0;
        _green = 1.0;
        _blue = 1.0;
        _alpha = 1.0;
        _style = GL_LINE_STRIP;
    }
    return self;
}

- (UIColor *) color {
    if (!_color) {
        _color = [UIColor colorWithRed:_red green:_green blue:_blue alpha:_alpha];
    }
    return _color;
}

- (void) setColor:(UIColor *)color{
    _color = color;
    [_color getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
}

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
    glBufferData(GL_ARRAY_BUFFER, verticesCount * sizeof(Vertex), vertices, GL_STATIC_DRAW);
}

- (void) setIndexBuffer:(int)indicesCount indices:(GLubyte *)indices {
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesCount * sizeof(GLubyte), indices, GL_STATIC_DRAW);
    _indicesCount = indicesCount;
}

@end


@interface VKObject(AssociatedBuffers)
@property (readonly, nonatomic) VKGameReusableBuffers *associatedBuffers;

- (void) associateBuffers:(VKGameReusableBuffers *)buffers;
@end

@implementation VKObject(AssociatedBuffers)

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


@interface VKGameObjectsArray()
@property (strong, nonatomic) CC3GLMatrix *matrix;
@property (strong, nonatomic) NSMutableSet *freeBuffers;
@property (strong, nonatomic) NSMutableArray *privateObjectsPosition;
@end

@implementation VKGameObjectsArray {
    VKShader _shader;
}

@synthesize glView = _glView;

- (instancetype) init {
    self = [super init];
    if (self) {
        _freeBuffers = [NSMutableSet set];
        _privateObjectsPosition = [NSMutableArray array];
        _matrix = [CC3GLMatrix new];
        [self compileShaders];
    }
    return self;
}

- (void) compileShaders {
    _shader = defailt_shader();
}

- (NSArray *) objects {
    return _privateObjectsPosition;
}

- (void) render {
    if (!_glView || self.objects.count == 0) {
        return;
    }
    
    VKGameReusableBuffers *buffers = nil;
    
    CC3GLMatrix *modelView = _matrix;
    
    for (VKObject *objProperties in self.objects) {
        CGSize glViewSize = _glView.glViewSize;
        buffers = objProperties.associatedBuffers;
        if (!buffers) {
            continue; //nothing to render
        }
        
        if (objProperties.position.x < 0 || objProperties.position.x > glViewSize.width ||
            objProperties.position.y < 0 || objProperties.position.y > glViewSize.height) {
            //offscreen
            continue;
        }
        
        glBindBuffer(GL_ARRAY_BUFFER, buffers.vertexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffers.indexBuffer);
        glUniform4f(_shader.colorUniform, objProperties.red, objProperties.green, objProperties.blue, objProperties.alpha);
        
        glUniformMatrix4fv(_shader.projectionUniform, 1, GL_FALSE, _glView.projection.glMatrix);
        
        [modelView populateFromTranslation:CC3VectorMake(-glViewSize.width/2, glViewSize.height/2, 0)];
        [modelView translateByX:objProperties.position.x];
        [modelView translateByY:-objProperties.position.y];
        [modelView rotateByZ:objProperties.rotation];
        
        glUniformMatrix4fv(_shader.modelViewUniform, 1, 0, modelView.glMatrix);
        glVertexAttribPointer(_shader.positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
        glDrawElements(objProperties.style, buffers.indicesCount, GL_UNSIGNED_BYTE, 0);
    }
}

- (void) removeFromGLView {
    [self.glView removeGLObject:self];
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

- (void) appendObject:(VKObject *)properties {
    if (!properties) {
        return;
    }
    
    [self.privateObjectsPosition addObject:properties];
    [properties associateBuffers:[self getReusableBuffers]];
}

- (void) removeObject:(VKObject *)properties {
    if (!properties) {
        return;
    }
    
    [self.privateObjectsPosition removeObject:properties];
    
    VKGameReusableBuffers *buffers = [properties associatedBuffers];
    if (buffers) {
        [self.freeBuffers addObject:buffers];
    }
}

- (void) removeAllObjects {
    NSArray *objects = [self.objects copy];
    [self.privateObjectsPosition removeAllObjects];
    
    VKGameReusableBuffers *buffers = nil;
    for (VKObject *properties in objects) {
        buffers = properties.associatedBuffers;
        if (buffers) {
            [self.freeBuffers addObject:buffers];
        }
    }
}

@end
