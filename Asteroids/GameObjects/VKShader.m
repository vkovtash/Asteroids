//
//  VKShader.m
//  Asteroids
//
//  Created by kovtash on 25.01.15.
//
//

#import "VKShader.h"

GLuint compile_shader(NSString *shaderName, GLenum shaderType) {
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
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

VKShader defailt_shader() {
    static GLuint programHandle = 0;
    
    if (!programHandle){
        programHandle = glCreateProgram();
        GLuint vertexShader = compile_shader(@"SimpleVertex", GL_VERTEX_SHADER);
        GLuint fragmentShader = compile_shader(@"SimpleFragment", GL_FRAGMENT_SHADER);
        
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
    
    VKShader shader;
    
    glUseProgram(programHandle);
    shader.positionSlot = glGetAttribLocation(programHandle, "Position");
    glEnableVertexAttribArray(shader.positionSlot);
    
    shader.colorUniform = glGetUniformLocation(programHandle, "SourceColor");
    shader.projectionUniform = glGetUniformLocation(programHandle, "Projection");
    shader.modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    
    return shader;
}