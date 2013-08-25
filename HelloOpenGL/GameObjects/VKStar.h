//
//  VKStar.h
//  Asteroids
//
//  Created by kovtash on 26.08.13.
//
//

#import "VKGameObject.h"

@interface VKStar : VKGameObject
@property (nonatomic,readonly) float radius;

- (id) initWithRadius:(float) radius;
@end
