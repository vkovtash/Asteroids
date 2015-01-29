//
//  VKAsteroidsArray.m
//  Asteroids
//
//  Created by kovtash on 29.01.15.
//
//

#import "VKAsteroidsArray.h"
#import "VKAsteroid.h"

@implementation VKAsteroidsArray

- (BOOL) isObjectOffScreen:(VKAsteroid *)object {
    CGSize glViewSize = self.glView.glViewSize;
    return (object.position.x < -object.radius || object.position.x > glViewSize.width + object.radius ||
            object.position.y < -object.radius || object.position.y > glViewSize.height + object.radius);
}

@end
