//
//  VKStarsArray.h
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKGameObjectsArray.h"

@interface VKStarsArray : VKGameObjectsArray
@property (nonatomic, readonly) float radius;

- (id) initWithRadius:(float)radius;
@end
