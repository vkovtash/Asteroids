//
//  VKMisslesArray.h
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKStaticObjectsArray.h"

@interface VKMissle : VKStaticGameObject
@property (nonatomic) float velocity;
@property (nonatomic) float direction;
@property (nonatomic) float leftDistance;
@property (nonatomic) float x_velocity;
@property (nonatomic) float y_velocity;

- (void) decreaseLeftDistanceWithTimeInterval:(NSTimeInterval)timeInterval;
@end

@interface VKMisslesArray : VKStaticObjectsArray
@property (nonatomic, readonly) float radius;

- (id) initWithRadius:(float)radius;
@end
