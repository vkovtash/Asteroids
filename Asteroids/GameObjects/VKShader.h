//
//  VKShader.h
//  Asteroids
//
//  Created by kovtash on 25.01.15.
//
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
    GLuint positionSlot;
    GLuint colorUniform;
    GLuint projectionUniform;
    GLuint modelViewUniform;
} VKShader;

VKShader defailt_shader();