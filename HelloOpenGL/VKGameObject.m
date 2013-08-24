//
//  VKGameObject.m
//  HelloOpenGL
//
//  Created by kovtash on 24.08.13.
//
//

#import "VKGameObject.h"

@interface VKGameObject()
@property (nonatomic) CGColorRef internalColor;
@end

@implementation VKGameObject
@synthesize position = _position;
@synthesize rotation = _rotation;
@synthesize color = _color;

- (UIColor *) color{
    if (!_color) {
        _color = [UIColor colorWithRed:_red green:_green blue:_blue alpha:_alpha];
        
    }
    return _color;
}

- (void) setColor:(UIColor *)color{
    _color = color;
    [_color getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
}

- (id) initWithViewSize:(CGSize) size Projection:(CC3GLMatrix *) projection{
    self = [self init];
    if (self) {
        _viewSize = size;
        _projection = projection;
    }
    return self;
}

- (id) init{
    self = [super init];
    if (self) {
        
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
        
        [self setVertexBuffer:4 Vertices:vertices];
        [self setIndexBuffer:6 Indices:indices];
        
        _style = GL_LINE_STRIP;
    }
    
    return self;
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)compileShaders {
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    glEnableVertexAttribArray(_positionSlot);
    
    _colorUniform = glGetUniformLocation(programHandle, "SourceColor");
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
}

- (void) setVertexBuffer:(int) verticesCount Vertices:(Vertex *) vertices{
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, verticesCount*sizeof(Vertex), vertices, GL_STATIC_DRAW);
}

- (void) setIndexBuffer:(int) indicesCount Indices:(GLubyte *) indices{
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesCount*sizeof(GLubyte), indices, GL_STATIC_DRAW);
    _indicesCount = indicesCount;
}

- (void)render {    
    glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, _projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(-_viewSize.width/2, _viewSize.height/2, 0)];
    [modelView translateByX:_position.x];
    [modelView translateByY:-_position.y];
    [modelView rotateByZ:_rotation];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glUniform4f(_colorUniform, _red, _green, _blue, _alpha);
    
    glDrawElements(_style, _indicesCount, GL_UNSIGNED_BYTE, 0);
}


@end
