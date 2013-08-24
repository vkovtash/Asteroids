//
//  VKGameObject.h
//  HelloOpenGL
//
//  Created by kovtash on 24.08.13.
//
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

@interface VKGameObject : NSObject{
    @private
    GLfloat *_glProjectionMatrix;
    GLfloat _glModelMatrix [16];
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    int _indicesCount;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    CGSize _viewSize;
}

@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat rotation;

- (id) initWithViewSize:(CGSize) size;
- (void) render;
- (void) compileShaders;
- (void) setVertexBuffer:(int) verticesCount Vertices:(Vertex *) vertices;
- (void) setIndexBuffer:(int) indicesCount Indices:(GLubyte *) indices;
@end
