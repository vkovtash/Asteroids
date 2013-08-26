//
//  VKMissle.h
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKGameObject.h"

@interface VKMissle : VKGameObject
@property (nonatomic) float velocity;
@property (nonatomic) float direction;
@property (nonatomic) float leftDistance;
@property (nonatomic,readonly) float radius;
@property (nonatomic, readonly) float x_velocity;
@property (nonatomic, readonly) float y_velocity;

- (void) decreaseLeftDistanceWithTimeInterval:(NSTimeInterval) timeInterval;
- (id) initWithRadius:(float) radius;
@end
