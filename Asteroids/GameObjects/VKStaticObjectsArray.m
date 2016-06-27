//
//  VKGameObject.m
//  Asteroids
//
//  Created by kovtash on 24.08.13.
//
//

#import "VKStaticObjectsArray.h"
#import "VKShader.h"


@implementation VKStaticGameObject

- (instancetype) initWithPosition:(CGPoint)position rotation:(CGFloat)rotation {
    self = [super init];
    if (self) {
        _position = position;
        _rotation = rotation;
    }
    return self;
}

- (instancetype) initWithPosition:(CGPoint)position {
    self = [self initWithPosition:position rotation:0];
    return self;
}

+ (instancetype) objectWithPosition:(CGPoint)position rotation:(CGFloat)rotation {
    return [[[self class] alloc] initWithPosition:position rotation:rotation];
}

+ (instancetype) objectWithPosition:(CGPoint)position {
    return [[[self class] alloc] initWithPosition:position];
}

@end


@interface VKStaticObjectsArray()
@property (strong, nonatomic) CC3GLMatrix *matrix;
@property (strong, nonatomic) NSMutableArray *privateObjectsPosition;
@end

@implementation VKStaticObjectsArray {
    VKShader _shader;
    int _indicesCount;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    CGFloat _red;
    CGFloat _green;
    CGFloat _blue;
    CGFloat _alpha;
}

@synthesize color = _color;
@synthesize glView = _glView;

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

- (id) init {
    self = [super init];
    if (self) {
        glGenBuffers(1, &_indexBuffer);
        glGenBuffers(1, &_vertexBuffer);
        
        _privateObjectsPosition = [NSMutableArray array];
        _red = 1.0;
        _green = 1.0;
        _blue = 1.0;
        _alpha = 1.0;
        
        _matrix = [CC3GLMatrix new];
        
        [self compileShaders];
        
        Vertex vertices[4] = {
            {{-50, -50, 0}},
            {{0, 50, 0}},
            {{50, -50, 0}},
            {{0, -25, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 vertices:vertices];
        [self setIndexBuffer:6 indices:indices];
        
        _style = GL_LINE_STRIP;
    }
    
    return self;
}

- (void) compileShaders {
    _shader = defailt_shader();
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

- (NSArray *) objects {
    return _privateObjectsPosition;
}

- (void) appendObject:(VKStaticGameObject *)object {
    if (object) {
        [self.privateObjectsPosition addObject:object];
    }
}

- (void) removeObject:(VKStaticGameObject *)object {
    if (object) {
        [self.privateObjectsPosition removeObject:object];
    }
}

- (void) removeAllObjects {
    [self.privateObjectsPosition removeAllObjects];
}

- (void) render {
    if (!_glView || self.objects.count == 0) {
        return;
    }

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glUniform4f(_shader.colorUniform, _red, _green, _blue, _alpha);
    
    CC3GLMatrix *modelView = _matrix;
    CGSize glViewSize = _glView.glViewSize;
    
    for (VKStaticGameObject *objProperties in self.objects) {
        if (objProperties.position.x < 0 || objProperties.position.x > glViewSize.width ||
            objProperties.position.y < 0 || objProperties.position.y > glViewSize.height) {
            //offscreen
            continue;
        }
        
        glUniformMatrix4fv(_shader.projectionUniform, 1, GL_FALSE, _glView.projection.glMatrix);
        
        [modelView populateFromTranslation:CC3VectorMake(-glViewSize.width/2, glViewSize.height/2, 0)];
        [modelView translateByX:objProperties.position.x];
        [modelView translateByY:-objProperties.position.y];
        [modelView rotateByZ:objProperties.rotation];
        
        glUniformMatrix4fv(_shader.modelViewUniform, 1, 0, modelView.glMatrix);
        glVertexAttribPointer(_shader.positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
        glDrawElements(_style, _indicesCount, GL_UNSIGNED_BYTE, 0);
    }
}

- (void) removeFromGLView {
    [self.glView removeGLObject:self];
}

@end
