//
//  VKShip.h
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKGameObject.h"

@interface VKShip : VKGameObject
@property (nonatomic) float velocity;
@property (nonatomic,readonly) float radius;
@property (nonatomic) BOOL acceleratng;

- (id) initWithRadius:(float) radius;
@end
