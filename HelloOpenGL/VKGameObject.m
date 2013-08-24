//
//  VKGameObject.m
//  HelloOpenGL
//
//  Created by kovtash on 24.08.13.
//
//

#import "VKGameObject.h"
#import "CC3GLMatrix.h"

@interface VKGameObject()
@end

@implementation VKGameObject
@synthesize position = _position;
@synthesize rotation = _rotation;

- (id) initWithViewSize:(CGSize)size{
    self = [self init];
    if (self) {
        _viewSize = size;
        
        CC3GLMatrix *projection = [CC3GLMatrix matrix];
        float h = 4.0f * _viewSize.height / _viewSize.width;
        [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
        _glProjectionMatrix = projection.glMatrix;
    }
    return self;
}

- (id) init{
    self = [super init];
    if (self) {
        
        /*_glProjectionMatrix[0] = 2.0;
        _glProjectionMatrix[1] = 0.0;
        _glProjectionMatrix[2] = 0.0;
        _glProjectionMatrix[3] = 0.0;
        _glProjectionMatrix[4] = 0.0;
        _glProjectionMatrix[5] = 1.33;
        _glProjectionMatrix[6] = 0.0;
        _glProjectionMatrix[7] = 0.0;
        _glProjectionMatrix[8] = 0.0;
        _glProjectionMatrix[9] = 0.0;
        _glProjectionMatrix[10] = -2.33;
        _glProjectionMatrix[11] = -1.33;
        _glProjectionMatrix[12] = 0.0;
        _glProjectionMatrix[13] = 0.0;
        _glProjectionMatrix[14] = -13.0;
        _glProjectionMatrix[15] = 0.0;*/
    
        
        _glModelMatrix[0] = 1.0;
        _glModelMatrix[1] = 0.0;
        _glModelMatrix[2] = 0.0;
        _glModelMatrix[3] = 0.0;
        _glModelMatrix[4] = 0.0;
        _glModelMatrix[5] = 1.0;
        _glModelMatrix[6] = 0.0;
        _glModelMatrix[7] = 0.0;
        _glModelMatrix[8] = 0.0;
        _glModelMatrix[9] = 0.0;
        _glModelMatrix[10] = 1.0;
        _glModelMatrix[11] = 0.0;
        _glModelMatrix[12] = 0.0;
        _glModelMatrix[13] = 0.0;
        _glModelMatrix[14] = -4.0;
        _glModelMatrix[15] = 1.0;
        
        [self compileShaders];
        
        Vertex vertices[4] = {
            {{-50, -50, 0}, {1, 1, 1, 1}},
            {{0, 50, 0}, {1, 1, 1, 1}},
            {{50, -50, 0}, {1, 1, 1, 1}},
            {{0, -25, 0}, {1, 1, 1, 1}}
        };
        [self setVertexBuffer:4 Vertices:vertices];
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        [self setIndexBuffer:6 Indices:indices];
    }
    
    return self;
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
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
    
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
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
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    //float h = 100.0f * _viewSize.height / _viewSize.width;
    //[projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:1 andFar:10];
    [projection populateOrthoFromFrustumLeft:-_viewSize.width/2
                                    andRight:_viewSize.width/2
                                   andBottom:-_viewSize.height/2
                                      andTop:_viewSize.height/2
                                     andNear:1
                                      andFar:10];
    //[projection populateOrthoFromFrustumLeft:0 andRight:8 andBottom:h/8 andTop:0 andNear:1 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, projection.glMatrix);
    
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(-_viewSize.width/2, _viewSize.height/2, -7)];
    [modelView translateByX:_position.x];
    [modelView translateByY:-_position.y];
    [modelView rotateByZ:90];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    //_glModelMatrix[12] = sin(CACurrentMediaTime());
    //_glModelMatrix[13] = sin(CACurrentMediaTime());
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    // 3
    glDrawElements(GL_LINE_STRIP, _indicesCount, GL_UNSIGNED_BYTE, 0);
}


@end
