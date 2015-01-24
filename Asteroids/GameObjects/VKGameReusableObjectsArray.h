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
@end

@interface VKGameReusableObjectsArray : VKGameObjectsArray
- (void) appendObjectProperties:(VKGameReusableObjectProperties *)properties;
- (void) removeObjectProperties:(VKGameReusableObjectProperties *)properties;
@end
