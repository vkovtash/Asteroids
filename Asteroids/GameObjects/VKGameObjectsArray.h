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
#import "VKGameObject.h"

@interface VKGameObjectPosition : NSObject
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat rotation;

- (instancetype) initWithPosition:(CGPoint)position rotation:(CGFloat)rotation;
- (instancetype) initWithPosition:(CGPoint)position;
+ (instancetype) newWithPosition:(CGPoint)position rotation:(CGFloat)rotation;
+ (instancetype) newWithPosition:(CGPoint)position;
@end

@interface VKGameObjectsArray : NSObject <VKGLObject>

@property (strong, nonatomic) CC3GLMatrix *projection;
@property (readonly, nonatomic) NSArray *objectsPosition;
@property (nonatomic) GLushort style;
@property (strong, nonatomic) UIColor *color;

- (void) removeFromGLView;
- (void) compileShaders;
- (void) setVertexBuffer:(int)verticesCount Vertices:(Vertex *)vertices;
- (void) setIndexBuffer:(int)indicesCount Indices:(GLubyte *)indices;
- (void) appendObjectAtPostion:(VKGameObjectPosition *)position;
- (void) removeObjectAtPostion:(VKGameObjectPosition *)position;
- (void) removeAllObjects;
@end
