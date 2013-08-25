//
//  VKMissle.h
//  HelloOpenGL
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

- (id) initWithRadius:(float) radius;
@end
