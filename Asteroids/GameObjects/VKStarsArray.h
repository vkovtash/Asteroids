//
//  VKStarsArray.h
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKStaticObjectsArray.h"

@interface VKStarsArray : VKStaticObjectsArray
@property (nonatomic, readonly) float radius;

- (id) initWithRadius:(float)radius;
@end
