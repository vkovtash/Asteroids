//
//  VKGameObject.m
//  Asteroids
//
//  Created by kovtash on 24.08.13.
//
//

#import "VKActiveGameObject.h"
#import "VKShader.h"

@interface VKActiveGameObject()
@property (nonatomic) CGColorRef internalColor;
@property (strong, nonatomic) CC3GLMatrix *matrix;
@end

@implementation VKActiveGameObject {
    VKShader _shader;
    int _indicesCount;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    CGFloat _red;
    CGFloat _green;
    CGFloat _blue;
    CGFloat _alpha;
}

@synthesize position = _position;
@synthesize rotation = _rotation;
@synthesize color = _color;
@synthesize glView = _glView;

- (UIColor *) color {
    if (!_color) {
        _color = [UIColor colorWithRed:_red green:_green blue:_blue alpha:_alpha];
        
    }
    return _color;
}

- (void) setColor:(UIColor *)color {
    _color = color;
    [_color getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
}

- (id) init {
    self = [super init];
    if (self) {
        
        glGenBuffers(1, &_vertexBuffer);
        glGenBuffers(1, &_indexBuffer);
        
        _matrix = [CC3GLMatrix matrix];
        _red = 1.0;
        _green = 1.0;
        _blue = 1.0;
        _alpha = 1.0;
        
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

- (BOOL) isOffTheScreen {
    CGSize glViewSize = _glView.glViewSize;
    return (_position.x < 0 || _position.x > glViewSize.width ||
            _position.y < 0 || _position.y > glViewSize.height);
}

- (void) render {
    if (!_glView || [self isOffTheScreen]) {
        return;
    }
    
    CGSize glViewSize = _glView.glViewSize;
    
    glUniformMatrix4fv(_shader.projectionUniform, 1, GL_FALSE, _glView.projection.glMatrix);
    
    CC3GLMatrix *modelView = _matrix;
    [modelView populateFromTranslation:CC3VectorMake(-glViewSize.width/2, glViewSize.height/2, 0)];
    [modelView translateByX:_position.x];
    [modelView translateByY:-_position.y];
    [modelView rotateByZ:_rotation];
    
    glUniformMatrix4fv(_shader.modelViewUniform, 1, 0, modelView.glMatrix);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glVertexAttribPointer(_shader.positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glUniform4f(_shader.colorUniform, _red, _green, _blue, _alpha);
    glDrawElements(_style, _indicesCount, GL_UNSIGNED_BYTE, 0);
}

- (void) removeFromGLView {
    [self.glView removeGLObject:self];
}
@end
