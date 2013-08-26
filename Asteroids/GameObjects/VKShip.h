//
//  VKShip.h
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKGameObject.h"

@interface VKShip : VKGameObject
@property (nonatomic, readonly) float radius;
@property (nonatomic) float accelerationRate;
@property (nonatomic) float maxSpeed;
@property (nonatomic) float x_velocity;
@property (nonatomic) float y_velocity;
@property (nonatomic) BOOL accelerating;

- (void) accelerateWithTimeInterval:(NSTimeInterval) timeInterval;
- (id) initWithRadius:(float) radius;
@end
