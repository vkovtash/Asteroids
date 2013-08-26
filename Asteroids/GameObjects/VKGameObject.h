//
//  VKGameObject.h
//  Asteroids
//
//  Created by kovtash on 24.08.13.
//
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "CC3GLMatrix.h"
#import "VKGLObject.h"

typedef struct {
    float Position[3];
} Vertex;

@interface VKGameObject : NSObject <VKGLObject>

@property (strong, nonatomic) CC3GLMatrix *projection;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat rotation;
@property (nonatomic) GLushort style;
@property (strong, nonatomic) UIColor *color;

- (void) removeFromGLView;
- (void) compileShaders;
- (void) setVertexBuffer:(int) verticesCount Vertices:(Vertex *) vertices;
- (void) setIndexBuffer:(int) indicesCount Indices:(GLubyte *) indices;
@end
