//
//  VKAsteroid.h
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKGameObject.h"

@interface VKAsteroid : VKGameObject
@property (nonatomic) float velocity;
@property (nonatomic) float direction;
@property (nonatomic) float rotationVelocity;
@property (nonatomic) float radius;
@property (nonatomic) int parts;

- (id) initWithRadius:(float) radius;
@end
