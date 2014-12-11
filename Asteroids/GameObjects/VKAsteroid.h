//
//  VKAsteroid.h
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKGameObject.h"

@interface VKAsteroid : VKGameObject
@property (nonatomic) float velocity;
@property (nonatomic) float direction;
@property (nonatomic) float rotationVelocity;
@property (nonatomic, readonly) float radius;
@property (nonatomic) int parts;
@property (nonatomic, readonly) float x_velocity;
@property (nonatomic, readonly) float y_velocity;
@property (nonatomic) float distance; //distance from the ship

- (void) rotateWithTimeInterval:(NSTimeInterval) timeInterval;
- (id) initWithRadius:(float) radius;
@end
