//
//  VKGameObject.m
//  Asteroids
//
//  Created by kovtash on 24.08.13.
//
//

#import "VKGameObject.h"

@interface VKGameObject()
@property (nonatomic) CGColorRef internalColor;
@property (strong, nonatomic) CC3GLMatrix *matrix;
@end

@implementation VKGameObject{
    GLuint _positionSlot;
    GLuint _colorUniform;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
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

- (id) init{
    self = [super init];
    if (self) {
        
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
    int shaderStringLength = (int)[shaderString length];
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
    static GLuint programHandle = 0;
    
    if (! programHandle){
        programHandle = glCreateProgram();
        GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
        GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
        
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

- (void) render {
    if (!_glView) {
        return;
    }
    
    CGSize glViewSize = _glView.glViewSize;
    if (_position.x < 0 || _position.x > glViewSize.width ||
        _position.y < 0 || _position.y > glViewSize.height) {
        //offscreen
        return;
    }
    
    glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, _glView.projection.glMatrix);
    
    CC3GLMatrix *modelView = _matrix;
    [modelView populateFromTranslation:CC3VectorMake(-glViewSize.width/2, glViewSize.height/2, 0)];
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

- (void) removeFromGLView{
    [self.glView removeGLObject:self];
}
@end
