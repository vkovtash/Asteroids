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
@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat alpha;
@end

@implementation VKGameReusableObjectProperties
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
@property (nonatomic) CGColorRef internalColor;
@property (strong, nonatomic) CC3GLMatrix *matrix;
@property (strong, nonatomic) NSMutableArray *privateObjectsPosition;
@end

@implementation VKGameReusableObjectsArray {
    GLuint _positionSlot;
    GLuint _colorUniform;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
}

@synthesize glView = _glView;

- (instancetype) init {
    self = [super init];
    if (self) {
        _freeBuffers = [NSMutableSet set];
        _privateObjectsPosition = [NSMutableArray array];
        _matrix = [CC3GLMatrix matrix];
    }
    return self;
}

- (GLuint) compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
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

- (void) compileShaders {
    static GLuint programHandle = 0;
    
    if (! programHandle) {
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

- (NSArray *) objectsProperties {
    return _privateObjectsPosition;
}

- (void) render {
    if (!_glView || self.objectsProperties.count == 0) {
        return;
    }
    
    for (VKGameReusableObjectProperties *objProperties in self.objectsProperties) {
        CGSize glViewSize = _glView.glViewSize;
        if (!objProperties.associatedBuffers) {
            continue; //nothing to render
        }
        
        if (objProperties.position.x < 0 || objProperties.position.x > glViewSize.width ||
            objProperties.position.y < 0 || objProperties.position.y > glViewSize.height) {
            //offscreen
            continue;
        }
        
        glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, _glView.projection.glMatrix);
        
        CC3GLMatrix *modelView = _matrix;
        [modelView populateFromTranslation:CC3VectorMake(-glViewSize.width/2, glViewSize.height/2, 0)];
        [modelView translateByX:objProperties.position.x];
        [modelView translateByY:-objProperties.position.y];
        [modelView rotateByZ:objProperties.rotation];
        
        glBindBuffer(GL_ARRAY_BUFFER, objProperties.associatedBuffers.vertexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, objProperties.associatedBuffers.indexBuffer);
        glUniform4f(_colorUniform, objProperties.red, objProperties.green, objProperties.blue, objProperties.alpha);
        
        glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
        glDrawElements(objProperties.style, objProperties.associatedBuffers.indicesCount, GL_UNSIGNED_BYTE, 0);
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

- (void) appendObjectProperties:(VKGameReusableObjectProperties *)properties {
    if (!properties) {
        return;
    }
    
    [self.privateObjectsPosition addObject:properties];
    [properties associateBuffers:[self getReusableBuffers]];
}

- (void) removeObjectProperties:(VKGameReusableObjectProperties *)properties {
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
    NSArray *objects = [self.objectsProperties copy];
    [self.privateObjectsPosition removeAllObjects];
    
    VKGameReusableBuffers *buffers = nil;
    for (VKGameReusableObjectProperties *properties in objects) {
        buffers = properties.associatedBuffers;
        if (buffers) {
            [self.freeBuffers addObject:buffers];
        }
    }
}

@end
