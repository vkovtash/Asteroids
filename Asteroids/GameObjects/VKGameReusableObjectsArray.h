//
//  VKGameReusableObjectsArray.h
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKGameObjectsArray.h"

@interface VKGameReusableObjectProperties : VKGameObjectProperties
@property (readonly, nonatomic) int verticiesCount;
@property (readonly, nonatomic) int indicesCount;
@property (readonly, nonatomic) Vertex *verticies;
@property (readonly, nonatomic) GLubyte *indices;
@property (nonatomic) GLushort style;
@property (strong, nonatomic) UIColor *color;
@end

@interface VKGameReusableObjectsArray : NSObject <VKGLObject>
@property (strong, nonatomic) CC3GLMatrix *projection;
@property (readonly, nonatomic) NSArray *objectsProperties;

- (void) appendObjectProperties:(VKGameReusableObjectProperties *)properties;
- (void) removeObjectProperties:(VKGameReusableObjectProperties *)properties;
- (void) removeAllObjects;
- (void) removeFromGLView;
- (void) compileShaders;
@end
