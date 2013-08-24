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
#import "CC3GLMatrix.h"

typedef struct {
    float Position[3];
} Vertex;

@interface VKGameObject : NSObject{
    GLushort _style;
    @private
    GLuint _positionSlot;
    GLuint _colorUniform;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    int _indicesCount;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    CGSize _viewSize;
    CGFloat _red;
    CGFloat _green;
    CGFloat _blue;
    CGFloat _alpha;
}

@property (strong,nonatomic) CC3GLMatrix *projection;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat rotation;
@property (nonatomic,strong) UIColor *color;

- (id) initWithViewSize:(CGSize) size Projection:(CC3GLMatrix *) projection;
- (void) render;
- (void) compileShaders;
- (void) setVertexBuffer:(int) verticesCount Vertices:(Vertex *) vertices;
- (void) setIndexBuffer:(int) indicesCount Indices:(GLubyte *) indices;
@end
