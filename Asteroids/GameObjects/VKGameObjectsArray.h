//
//  VKGameReusableObjectsArray.h
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKStaticObjectsArray.h"

@interface VKObject : VKStaticGameObject
@property (readonly, nonatomic) int verticiesCount;
@property (readonly, nonatomic) int indicesCount;
@property (readonly, nonatomic) Vertex *verticies;
@property (readonly, nonatomic) GLubyte *indices;
@property (nonatomic) GLushort style;
@property (strong, nonatomic) UIColor *color;
@end

@interface VKGameObjectsArray : NSObject <VKGLObject>
@property (strong, nonatomic) CC3GLMatrix *projection;
@property (readonly, nonatomic) NSArray *objects;

- (void) appendObject:(VKObject *)properties;
- (void) removeObject:(VKObject *)properties;
- (void) removeAllObjects;
- (void) removeFromGLView;
- (void) compileShaders;
@end
