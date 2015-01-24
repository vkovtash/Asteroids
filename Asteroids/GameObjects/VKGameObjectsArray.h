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

@interface VKGameObjectProperties : NSObject
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat rotation;

- (instancetype) initWithPosition:(CGPoint)position rotation:(CGFloat)rotation;
- (instancetype) initWithPosition:(CGPoint)position;
+ (instancetype) propertiesWithPosition:(CGPoint)position rotation:(CGFloat)rotation;
+ (instancetype) propertiesWithPosition:(CGPoint)position;
@end

@interface VKGameObjectsArray : NSObject <VKGLObject>

@property (strong, nonatomic) CC3GLMatrix *projection;
@property (readonly, nonatomic) NSArray *objectsProperties;
@property (nonatomic) GLushort style;
@property (strong, nonatomic) UIColor *color;

- (void) removeFromGLView;
- (void) compileShaders;
- (void) setVertexBuffer:(int)verticesCount Vertices:(Vertex *)vertices;
- (void) setIndexBuffer:(int)indicesCount Indices:(GLubyte *)indices;
- (void) appendObjectProperties:(VKGameObjectProperties *)position;
- (void) removeObjectProperties:(VKGameObjectProperties *)position;
- (void) removeAllObjects;
@end
