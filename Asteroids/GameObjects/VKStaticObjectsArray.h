//
//  VKGameObject.h
//  Asteroids
//
//  Created by kovtash on 24.08.13.
//
//

#import <Foundation/Foundation.h>
#import "VKGLObject.h"
#import "VKActiveGameObject.h"


@interface VKStaticGameObject : NSObject
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat rotation;

- (instancetype) initWithPosition:(CGPoint)position rotation:(CGFloat)rotation;
- (instancetype) initWithPosition:(CGPoint)position;
+ (instancetype) objectWithPosition:(CGPoint)position rotation:(CGFloat)rotation;
+ (instancetype) objectWithPosition:(CGPoint)position;
@end


@interface VKStaticObjectsArray : NSObject <VKGLObject>

@property (readonly, nonatomic) NSArray *objects;
@property (nonatomic) GLushort style;
@property (strong, nonatomic) UIColor *color;

- (void) removeFromGLView;
- (void) compileShaders;
- (void) setVertexBuffer:(int)verticesCount vertices:(Vertex *)vertices;
- (void) setIndexBuffer:(int)indicesCount indices:(GLubyte *)indices;
- (void) appendObject:(VKStaticGameObject *)object;
- (void) removeObject:(VKStaticGameObject *)object;
- (void) removeAllObjects;
@end
